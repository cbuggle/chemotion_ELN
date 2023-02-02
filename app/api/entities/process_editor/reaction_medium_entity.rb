# frozen_string_literal: true

module Entities
  module ProcessEditor
    # wraps a ReactionsSample object
    class ReactionMediumEntity < ApplicationEntity
      expose(
        :id, :sum_formula, :label, :short_label, :preferred_label, :sample_name, :molecule_name
      )

      # :label, :short_label, :preferred_label for compatibitility with SampleEntity.
      # We would need probably only one of them.
    end
  end
end
