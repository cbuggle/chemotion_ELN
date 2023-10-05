# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class Base < OrdKit::Exporter::Base
        # Defines base structure of ReactionProcessAction Export
        # Provides implementation for the common methods details, duration,
        # Provides empty implementation step_action which needs to be implemented in subclasses.

        def to_ord
          OrdKit::ReactionAction.new(
            {
              description: description,
              position: position,
              start_time: start_time,
              duration: duration,
              extra_equipment: extra_equipment,
            }.merge(step_action),
          )
        end

        private

        delegate :workup, to: :model
        # def workup
        #   model.workup
        # end

        # ORD attributes in order of ORD definition by convention (they are numbered).

        def description
          workup['description']
        end

        def position
          model.position
        end

        def start_time
          OrdKit::Time.new(
            value: 0, # TODO: We have removed redundant attribute start_time;
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def duration
          # We deliver all Times in seconds per convention
          # (this is the finest granularity, milliseconds not available). cbuggle, 6.1.2022
          OrdKit::Time.new(
            value: model.workup['duration'].to_i,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def extra_equipment
          return unless workup['apply_extra_equipment']

          workup['equipment'].map do |equipment|
            OrdKit::Equipment.new(
              type: equipment_type(equipment),
              details: '',  # Currently n/a in ELN.
            )
          end
        end

        def equipment_type(equipment)
          OrdKit::Equipment::EquipmentType.const_get(equipment)
        rescue NameError
          OrdKit::Equipment::EquipmentType::UNSPECIFIED
        end

        def step_action
          raise 'OrdKit::Exporter::Actions::Base is abstract. Please subclass and provide an implementation.'
        end
      end
    end
  end
end
