# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class Base < OrdKit::Exporter::Base
        # Defines base structure of ReactionProcessAction Export
        # Provides implementation for the common methods details, duration,
        # Provides empty implementation action_type_attributes which needs to be implemented in subclasses.

        def to_ord(starts_at:)
          OrdKit::ReactionAction.new(
            {
              description: description,
              position: position,
              start_time: start_time(starts_at),
              duration: duration,
              equipment: equipment,
            }.merge(action_type_attributes),
          )
        end

        private

        delegate :workup, :reaction_process,to: :model

        # ORD attributes in order of ORD definition by convention (they are numbered).
        def description
          workup['description']
        end

        def position
          model.position + 1
        end

        def start_time(starts_at)
          OrdKit::Time.new(
            value: starts_at.to_i / 1000,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def duration
          # We deliver all Times in seconds per convention. However currently we store milliseconds.
          # (this is the finest granularity, milliseconds not available in ORD). cbuggle, 6.1.2022
          OrdKit::Time.new(
            value: workup['duration'].to_i / 1000,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def equipment
          return unless workup['equipment']

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

        def action_type_attributes
          raise 'OrdKit::Exporter::Actions::Base is abstract. Please subclass and provide an implementation.'
        end
      end
    end
  end
end
