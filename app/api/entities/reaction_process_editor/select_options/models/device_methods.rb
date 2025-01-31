# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class DeviceMethods < Base
          def select_options_for(device_methods)
            device_methods.map do |method|
              method.attributes
                    .slice(*%w[label device_name detectors description steps default_inject_volume
                               active])
                    .merge({ value: method.label,
                             stationary_phase: stationary_phase_options(method),
                             mobile_phase: mobile_phase_options_for(method) })
            end
          end

          private

          def stationary_phase_options(method)
            method.stationary_phase&.map do |stationary_phase|
              ontology_field_option_for(base_ontology: method.ontology,
                                        role: 'stationary_phase',
                                        value: stationary_phase)
            end

            # option_for(stationary_phase).merge(
            #   { active: ontology.active,
            #     ontology_id: stationary_phase,
            #     roles: { stationary_phase: [{}] } },
            # )
          end

          def mobile_phase_options_for(method)
            method.mobile_phase.map do |mobile_phase|
              ontology_field_option_for(base_ontology: method.ontology,
                                        role: 'mobile_phase',
                                        value: mobile_phase)
              # options_for(mobile_phase)
            end
          end
        end
      end
    end
  end
end
