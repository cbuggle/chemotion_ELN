# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class ConditionsActionExporter < Base
        private

        def step_action
          {
            condition: ReactionActionCondition.new(
              conditions: conditions,
              tendency: tendency,
              details: description,
            ),
          }
        end

        def conditions
          ReactionConditions.new(
            temperature: temperature,
            pressure: pressure,
            stirring: stirring,
            illumination: illumination,
            electrochemistry: electrochemistry,
            ph: ph,
            conditions_are_dynamic: conditions_are_dynamic,
            details: condition_details,
          )
        end

        def tendency
          ReactionActionCondition::TendencyType.const_get workup['condition_tendency'].to_s
        rescue NameError
          ReactionActionCondition::TendencyType::UNSPECIFIED
        end

        # The ORD ReactionConditions knows all types of condition in a single message.
        # ELN only sets one at a time (which is a perfectly valid ORD usecase).

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
          nil # n/a unkown in ELN Editor.s
        end
      end
    end
  end
end
