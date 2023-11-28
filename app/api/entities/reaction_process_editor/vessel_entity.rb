# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class VesselEntity < Grape::Entity
      expose(:id,
             :name,
             :description,
             :short_label,
             :details,
             :material_details,
             :material_type,
             :vessel_type,
             :volume_amount,
             :volume_unit)
    end
  end
end
