# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Uploader do
  subject(:upload) { described_class.new(reaction_process, http_client: http_client).call }

  let(:reaction_process) { build_stubbed(:reaction_process) }
  let(:clap) { Clap::Reaction.new(reaction_id: reaction_process.id) }
  let(:http_client) { class_double(HTTParty) }
  let(:response) { instance_double(HTTParty::Response, code: 201, success?: true) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:[]).with('CLAP_UPLOAD_USERNAME').and_return('example-user')
    allow(ENV).to receive(:[]).with('CLAP_UPLOAD_PASSWORD').and_return('example-password')
    allow(ENV).to receive(:fetch).with('CLAP_UPLOAD_USERNAME').and_return('example-user')
    allow(ENV).to receive(:fetch).with('CLAP_UPLOAD_PASSWORD').and_return('example-password')
    allow(ENV).to receive(:fetch).with('CLAP_UPLOAD_TIMEOUT', 15).and_return('12')
    allow(Clap::Exporter::ReactionProcessExporter).to receive(:new).with(reaction_process).and_return(
      instance_double(Clap::Exporter::ReactionProcessExporter, to_clap: clap),
    )
  end

  it 'uploads the CLAP JSON as a basic-authenticated multipart file' do
    allow(http_client).to receive(:post) do |url, options|
      expect(url).to eq('https://localhost:5000/api/v1/clap/files')
      expect(options[:basic_auth]).to eq(username: 'example-user', password: 'example-password')
      expect(options[:timeout]).to eq(12)
      expect(JSON.parse(options.dig(:body, :file).read)).to include('reactionId' => reaction_process.id)
      response
    end

    expect(upload).to eq(response)
  end

  it 'raises a request error for a failed upstream response' do
    failed_response = instance_double(HTTParty::Response, code: 401, success?: false)
    allow(http_client).to receive(:post).and_return(failed_response)

    expect { upload }.to raise_error(Clap::Uploader::RequestError, /HTTP 401/)
  end

  it 'requires both credentials' do
    allow(ENV).to receive(:[]).with('CLAP_UPLOAD_PASSWORD').and_return(nil)

    expect { upload }.to raise_error(Clap::Uploader::ConfigurationError, /CLAP_UPLOAD_PASSWORD/)
  end
end
