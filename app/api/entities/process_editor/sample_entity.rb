# frozen_string_literal: true

module Entities
  module ProcessEditor
    class SampleEntity < ApplicationEntity
      expose :id
      expose :short_label
      expose :sample_svg_file
      expose :target_amount_unit
      expose :target_amount_value
      expose :amount_mmol
      expose :amount_mg
      expose :amount_g
      expose :amount_ml
      expose :metrics
      expose :location
      expose :hide_in_eln
    end
  end
end
