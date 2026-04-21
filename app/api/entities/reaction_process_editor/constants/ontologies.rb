# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module Constants
      class Ontologies
        DEFAULT_AUTOMATION_MODE = 'NCIT:C70669'

        AUTOMATION_MANUAL_MODES = ['NCIT:C63513'].freeze
        AUTOMATION_AUTOMATED_MODES = ['NCIT:C172484', 'NCIT:C70669'].freeze

        ACTION_ONTOLOGIES =	{
          CHROMATOGRAPHY: { class: 'CHMO:0001000', action: 'CHMO:0002231' },
          ANALYSIS_CHROMATOGRAPHY: { class: 'CHMO:0001000', action: 'OBI:0000070' },
          ANALYSIS_SPECTROSCOPY: { class: 'CHMO:0000228', action: 'OBI:0000070' },
        }.deep_stringify_keys.freeze

        def self.motion_modes
          [{ value: 'NCIT:C63513', label: 'Manual' },
           { value: 'NCIT:C70669', label: 'Automated' }]
        end

        def self.automation_mode_manual?(ontology_id)
          AUTOMATION_MANUAL_MODES.include?(ontology_id)
        end

        def self.automation_mode_automated?(ontology_id)
          AUTOMATION_AUTOMATED_MODES.include?(ontology_id)
        end

        def self.action_ontology_workup(action_name)
          ACTION_ONTOLOGIES[action_name] || {}
        end
      end
    end
  end
end
