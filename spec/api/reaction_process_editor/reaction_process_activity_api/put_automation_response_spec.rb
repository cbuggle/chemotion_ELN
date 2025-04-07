# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::ReactionProcessActivityAPI, '.put /automation_response' do
  include RequestSpecHelper

  subject(:put_activity_request) do
    put("/api/v1/reaction_process_editor/reaction_process_activities/#{activity.id}/automation_response",
        params: { response_csv: response_csv }.to_json,
        headers: authorization_header)
  end

  let(:activity) { create(:reaction_process_activity) }
  let(:response_csv) { 2 }

  let(:authorization_header) { authorized_header(activity.creator) }

  #  TODO change authorization, needs to be sent by technical user.
  it_behaves_like 'authorization restricted API call'

  it 'executes HandleAutomationResponse' do
    allow(Usecases::ReactionProcessEditor::ReactionProcessActivities::HandleAutomationResponse)
      .to receive(:execute!)

    put_activity_request

    expect(Usecases::ReactionProcessEditor::ReactionProcessActivities::HandleAutomationResponse)
      .to have_received(:execute!)
      .with(activity: activity, response_csv: response_csv)
  end
end
