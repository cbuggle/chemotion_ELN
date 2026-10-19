# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessEditor::Automation::ClapUploadAPI do
  include_context 'api request authorization context'

  let(:reaction_process) { create(:reaction_process, user: user) }
  let(:upstream_response) { instance_double(HTTParty::Response, code: 201) }
  let(:uploader) { instance_double(Clap::Uploader, call: upstream_response) }

  before do
    allow(Clap::Uploader).to receive(:new).with(reaction_process).and_return(uploader)
  end

  it 'triggers the configured CLAP upload' do
    post "/api/v1/reaction_process_editor/reaction_processes/#{reaction_process.id}/clap/upload"

    expect(response).to have_http_status(:created)
    expect(parsed_json_response).to include('uploaded' => true, 'upstream_status' => 201)
    expect(uploader).to have_received(:call)
  end

  it 'does not upload another users reaction process' do
    other_reaction_process = create(:reaction_process)

    post "/api/v1/reaction_process_editor/reaction_processes/#{other_reaction_process.id}/clap/upload"

    expect(response).to have_http_status(:forbidden)
    expect(uploader).not_to have_received(:call)
  end
end
