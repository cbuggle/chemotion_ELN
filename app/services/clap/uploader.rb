# frozen_string_literal: true

require 'tempfile'

module Clap
  class Uploader
    ENDPOINT = ENV.fetch('CLAP_UPLOAD_ENDPOINT')
    DEFAULT_TIMEOUT = 15

    class ConfigurationError < StandardError; end

    class RequestError < StandardError
      attr_reader :status

      def initialize(status = nil, message: nil)
        @status = status
        super(message || "CLAP receiver responded with HTTP #{status}")
      end
    end

    def initialize(reaction_process, http_client: HTTParty)
      @reaction_process = reaction_process
      @http_client = http_client
    end

    def call
      validate_configuration!

      Tempfile.create([safe_filename, '.json']) do |file|
        file.write(clap_json)
        file.rewind

        response = upload(file)
        raise RequestError, response.code unless response.success?

        response
      end
    end

    private

    attr_reader :http_client, :reaction_process

    def upload(file)
      http_client.post(
        ENDPOINT,
        basic_auth: credentials,
        body: { file: file },
        timeout: timeout,
      )
    rescue HTTParty::Error, SocketError, SystemCallError, Timeout::Error => e
      message = "Could not reach the CLAP receiver at #{ENDPOINT}: #{e.message}"
      raise RequestError.new(message: message), cause: e
    end

    def clap_json
      clap = Clap::Exporter::ReactionProcessExporter.new(reaction_process).to_clap
      Google::Protobuf.encode_json(clap)
    end

    def credentials
      {
        username: ENV.fetch('CLAP_UPLOAD_USERNAME'),
        password: ENV.fetch('CLAP_UPLOAD_PASSWORD'),
      }
    end

    def safe_filename
      reaction_process.clap_filename.gsub(/[^0-9A-Za-z._-]/, '_')
    end

    def timeout
      Integer(ENV.fetch('CLAP_UPLOAD_TIMEOUT', DEFAULT_TIMEOUT), 10)
    rescue ArgumentError
      raise ConfigurationError, 'CLAP_UPLOAD_TIMEOUT must be an integer'
    end

    def validate_configuration!
      missing = %w[CLAP_UPLOAD_USERNAME CLAP_UPLOAD_PASSWORD].select { |name| ENV[name].blank? }
      return if missing.empty?

      raise ConfigurationError, "Missing CLAP upload configuration: #{missing.join(', ')}"
    end
  end
end
