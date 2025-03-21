# frozen_string_literal: true

RSpec.describe Usecases::ReactionProcessEditor::ReactionProcessActivities::HandleAutomationResponse do
  subject(:handle_automation_response) { described_class.execute!(activity: activity, response_csv: response_csv) }

  let(:response_csv){ file_fixture('reaction_process_editor/automation_responses/hs_15_response.csv').read }

  let(:expected_automation_response){
    { vial_plate: "HS_15",
      vials: [11568,9646,nil,16165,56161,619619,nil,1196,nil,196,nil,nil,nil,nil,956191]}.stringify_keys
  }

  let(:activity) { create(:reaction_process_activity) }

  it "updates field automation_response from CSV" do
    expect { handle_automation_response }.to change(activity, :automation_response).to(expected_automation_response)
  end

  it "updates workup['automation_status']" do
    expect { handle_automation_response }.to change { activity.workup['AUTOMATION_STATUS'] }.to('AUTOMATION_RESPONDED')
  end
end
