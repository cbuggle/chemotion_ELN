# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Uploader do
  subject(:upload) { described_class.new(reaction_process, http_client: http_client).call }

  let(:reaction_process) { build_stubbed(:reaction_process) }
  let(:clap) { Clap::Reaction.new(reaction_id: reaction_process.id) }
  let(:http_client) { class_double(HTTParty) }
  let(:response) { instance_double(HTTParty::Response, code: 201, success?: true) }

  before do
    stub_const('Clap::Uploader::ENDPOINT', 'https://localhost:5000/api/v1/clap/files')
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
    allow(http_client).to receive(:post).and_return(response)
  end

  it 'returns the receiver response' do
    expect(upload).to eq(response)
  end

  it 'uploads to the configured endpoint' do
    upload

    expect(http_client).to have_received(:post).with('https://localhost:5000/api/v1/clap/files', anything)
  end

  it 'uses basic authentication' do
    upload

    expect(http_client).to have_received(:post).with(
      anything,
      hash_including(basic_auth: { username: 'example-user', password: 'example-password' }),
    )
  end

  it 'uses the configured timeout' do
    upload

    expect(http_client).to have_received(:post).with(anything, hash_including(timeout: 12))
  end

  it 'uploads the encoded CLAP JSON as a multipart file' do
    uploaded_clap = nil
    allow(http_client).to receive(:post) do |_url, options|
      uploaded_clap = JSON.parse(options.dig(:body, :file).read)
      response
    end
    upload

    expect(uploaded_clap).to include('reactionId' => reaction_process.id)
  end

  it 'raises a request error for a failed upstream response' do
    failed_response = instance_double(HTTParty::Response, code: 401, success?: false)
    allow(http_client).to receive(:post).and_return(failed_response)

    expect { upload }.to raise_error(Clap::Uploader::RequestError, /HTTP 401/)
  end

  it 'raises a request error when the receiver refuses the connection' do
    allow(http_client).to receive(:post).and_raise(Errno::ECONNREFUSED)

    expect { upload }.to raise_error(
      Clap::Uploader::RequestError,
      %r{Could not reach the CLAP receiver at https://localhost:5000/api/v1/clap/files},
    )
  end

  it 'preserves a connection exception as the request error cause' do
    connection_error = Errno::ECONNREFUSED.new
    allow(http_client).to receive(:post).and_raise(connection_error)

    upload
  rescue Clap::Uploader::RequestError => e
    expect(e.cause).to equal(connection_error)
  end

  it 'raises a request error when the receiver times out' do
    allow(http_client).to receive(:post).and_raise(Net::ReadTimeout)

    expect { upload }.to raise_error(Clap::Uploader::RequestError, /Could not reach the CLAP receiver/)
  end

  it 'raises a request error for an HTTP client exception' do
    allow(http_client).to receive(:post).and_raise(HTTParty::Error, 'invalid HTTP response')

    expect { upload }.to raise_error(Clap::Uploader::RequestError, /invalid HTTP response/)
  end

  it 'requires both credentials' do
    allow(ENV).to receive(:[]).with('CLAP_UPLOAD_PASSWORD').and_return(nil)

    expect { upload }.to raise_error(Clap::Uploader::ConfigurationError, /CLAP_UPLOAD_PASSWORD/)
  end
end
