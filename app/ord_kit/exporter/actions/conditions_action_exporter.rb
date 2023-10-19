# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class ConditionsActionExporter < Base
        private

        def equipment
          return unless workup['EQUIPMENT'] && workup['EQUIPMENT']['value']

          workup['EQUIPMENT']['value'].map do |equipment|
            OrdKit::Equipment.new(
              type: equipment_type(equipment),
              details: '', # Currently n/a in ELN.
            )
          end
        end

        def step_action
          { conditions: conditions }
        end

        def conditions
          ReactionConditions.new(
            temperature: temperature,
            ph: ph,
            pressure: pressure,
            stirring: stirring,
            illumination: illumination,
            electrochemistry: electrochemistry,
            conditions_are_dynamic: conditions_are_dynamic,
            details: condition_details,
          )
        end

        def temperature
          return unless workup['TEMPERATURE']

          Conditions::TemperatureConditionsExporter.new(workup['TEMPERATURE']).to_ord
        end

        def pressure
          return unless workup['PRESSURE']

          Conditions::PressureConditionsExporter.new(workup['PRESSURE']).to_ord
        end

        def stirring
          return unless workup['MOTION']

          Conditions::MotionConditionsExporter.new(workup['MOTION']).to_ord
        end

        def illumination
          return unless workup['IRRADIATION']

          Conditions::IrradiationConditionsExporter.new(workup['IRRADIATION']).to_ord
        end

        def electrochemistry
          nil # n/a. Electrochemistry unknown in ELN Editor.
        end

        def ph
          return unless workup['PH']

          Conditions::PhAdjustConditionsExporter.new(workup['PH']).to_ord
        end

        def conditions_are_dynamic
          false # n/a. Unknown in ELN Editor
        end

        def condition_details
          nil # n/a unkown in ELN Editor.
        end
      end
    end
  end
end
