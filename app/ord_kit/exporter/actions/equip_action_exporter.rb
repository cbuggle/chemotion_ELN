# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class EquipActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          {
            equip: ReactionActionEquip.new(
              mount_action: mount_action,
              equipment: equipment,
            ),
          }
        end

        def mount_action
          OrdKit::ReactionActionEquip::EquipActionType.const_get(workup['mount_action'].to_s)
        rescue StandardError
          nil
        end

        def equipment
          OrdKit::Equipment.new(
            type: equipment_type,
            details: nil,  # Currently not present in ELN Editor.
          )
        end

        def equipment_type
          OrdKit::Equipment::EquipmentType.const_get(workup['equipment'].to_s)
        rescue NameError
          OrdKit::Equipment::EquipmentType::UNSPECIFIED
        end
      end
    end
  end
end
