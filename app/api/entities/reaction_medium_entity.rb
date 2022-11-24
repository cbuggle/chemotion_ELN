# frozen_string_literal: true

module Entities
  # wraps a ReactionsSample object
  class ReactionMediumEntity < ApplicationEntity
    expose(
      :id, :sum_formula, :label, :sample_name, :molecule_name
    )
  end
end
