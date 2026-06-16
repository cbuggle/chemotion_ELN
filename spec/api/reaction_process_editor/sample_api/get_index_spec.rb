# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::SampleAPI, '.get /samples' do
  include RequestSpecHelper

  subject(:api_call) do
    get('/api/v1/reaction_process_editor/samples',
        headers: authorization_header)
  end

  let(:user) { create(:person) }
  let(:authorization_header) { authorized_header(user) }

  it 'returns samples from readable collections' do
    collection = create(:collection, user: user)
    sample = create(:valid_sample)
    CollectionsSample.create!(collection: collection, sample: sample)

    api_call

    expect(parsed_json_response['samples'].pluck('id')).to include(sample.id)
  end
end
