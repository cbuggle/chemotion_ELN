# frozen_string_literal: true

module Entities
  module ProcessEditor
    # wraps a ReactionsSample object
    class ReactionMaterialEntity < ApplicationEntity
      expose :sample, using: 'Entities::ProcessEditor::SampleEntity', merge: true
    end
  end
end
