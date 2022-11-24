# frozen_string_literal: true

module Entities
  class ReactionProcessStepEntity < ApplicationEntity
    expose(
      :id, :name, :position, :label, :locked, :start_time, :duration, :reaction_process_id, :reaction_id,
      :step_name_suggestions_options, :samples_options, :added_samples_options, :equipment_options,
      :mounted_equipment_options, :transfer_to_options, :transfer_sample_options,
      :action_equipment_options
    )

    expose_timestamps

    expose! :reaction_process_actions, using: 'Entities::ReactionProcessActionEntity'
    expose! :vessel, using: 'Entities::VesselEntity'

    private

    def reaction_process_actions
      object.reaction_process_actions.order('position')
    end

    def reaction_process_id
      object.reaction_process_id || 'None'
    end

    # We piggyback the reaction_id, samples_options, added_samples_options, equipment_options, mounted_equipment_options
    # onto each process_step for convenient usage in UI Selects. cbuggle, 24.8.2021.

    def reaction_id
      object.reaction.id
    end

    def start_time
      object.start_time || 0
    end

    def duration
      object.duration || 0
    end

    def step_name_suggestions_options
      reaction_ids = Reaction.where(creator: object.reaction.creator).ids

      procedure_ids = ReactionProcess.where(reaction_id: reaction_ids).ids

      process_steps = ReactionProcessStep.where(reaction_process_id: procedure_ids).all

      process_step_names = process_steps.filter_map(&:name).uniq.reject { |name| name == object.name }

      process_step_names.map.with_index { |name, idx| { value: idx, label: name } }
    end

    def samples_options
      samples = object.reaction.starting_materials + object.reaction.reactants
      solvents = object.reaction.solvents + object.reaction.purification_solvents
      intermediates = object.reaction.intermediate_samples

      # solvents are to be defined terminally as bespoken with NJung, cbuggle, 06.10.2021

      {
        SAMPLE: samples.map do |s|
                  { value: s.id, label: s.preferred_label.to_s, amount: s.preferred_volume_amount,
                    unit: s.preferred_volume_unit }
                end,
        SOLVENT: solvents.map do |s|
                   { value: s.id, label: s.preferred_label.to_s, amount: s.target_amount_value,
                     unit: s.target_amount_unit }
                 end,
        MEDIUM: Medium::MediumSample.all.map { |s| { value: s.id, label: s.label.to_s } },
        ADDITIVE: Medium::Additive.all.map { |s| { value: s.id, label: s.label.to_s } },
        DIVERSE_SOLVENT: Medium::DiverseSolvent.all.map { |s| { value: s.id, label: s.label.to_s } },
        INTERMEDIATE: intermediates.map do |s|
                        { value: s.id, label: s.short_label.to_s, amount: s.target_amount_value,
                          unit: s.target_amount_unit }
                      end,
      }
    end

    def added_samples_options
      {
        # Delivering SOLVENT, MEDIUM und ADDITIVE as bespoken with NJung, 06.10.2021.
        SOLVENT: Sample.find(added_solvent_ids).map { |s| { value: s.id, label: s.preferred_label.to_s } },
        MEDIUM: Medium::MediumSample.find(added_medium_sample_ids).map { |s| { value: s.id, label: s.label.to_s } },
        ADDITIVE: Medium::Additive.find(added_additive_ids).map { |s| { value: s.id, label: s.label.to_s } },
        DIVERSE_SOLVENT: Medium::DiverseSolvent.find(added_diverse_solvent_ids).map do |s|
                           { value: s.id, label: s.label.to_s }
                         end,
      }
    end

    def equipment_options
      OrdKit::Equipment::EquipmentType.constants.map do |equipment|
        { value: equipment.to_s, label: equipment.to_s.titlecase }
      end
    end

    def mounted_equipment_options
      options_for(mounted_equipment)
    end

    def transfer_sample_options
      Sample.where(id: saved_sample_ids).includes(%i[molecule molecule_name]).map do |s|
        { value: s.id, label: (s.preferred_label || s.short_label).to_s }
      end
    end

    def transfer_to_options
      process_steps = object.reaction_process.reaction_process_steps.reject { |s| s == object }

      process_steps.map { |process_step| { value: process_step.id, label: process_step.label.to_s } }
    end

    # This is just hardcoded definining the available equipment depending on action type.
    # These are subsets of OrdKit::Equipment::EquipmentType. It's important to have each constant in the ORD as well (else ORD export will write 'UNSEPCIFIED')
    # It might move to a dedicated class when too much clutter.

    def action_equipment_options
      {
        ADD: equipment_options,
        SAVE: [],
        TRANSFER: [],
        MOTION: options_for(%w[
                              STIRRER SHAKER HEATING_SHAKER TUBE BALL_MILLING
                            ]),
        EQUIP: equipment_options,
        CONDITION: {
          TEMPERATURE: options_for(
            %w[HEATING_MANTLE BLOW_DRYER OIL_BATH ICE_BATH
               ALUMINIUM_BLOCK WATER_BATH SAND_BATH],
          ),
          PH: options_for(['PIPET']),
          PRESSURE: options_for(['REACTOR']),
          IRRADIATION: options_for(%w[ULTRA_SOUND_BATH UV_LAMP LED]),
        },
        REMOVE: options_for(%w[PUMP TUBE COIL]),
        PURIFY: options_for(%w[FILTER SEPARATION_FILTER EXTRACTOR
                               SPE_COLUMN FSPE_COLUMN FLASH_COLUMN DISTILLATION_APPARATUS SEPARATION_FUNNEL BUCHNER_FUNNEL]),
      }
    end

    def options_for(string_array)
      string_array.map do |string|
        { value: string, label: string.titlecase }
      end
    end

    def added_sample_ids
      add_actions_acting_as('SAMPLE').map { |action| action.workup['sample_id'] }
    end

    def saved_sample_ids
      add_actions_acting_as('SAMPLE').map { |action| action.workup['sample_id'] }
    end

    def added_solvent_ids
      add_actions_acting_as('SOLVENT').map { |action| action.workup['sample_id'] }
    end

    def added_diverse_solvent_ids
      add_actions_acting_as('DIVERSE_SOLVENT').map { |action| action.workup['sample_id'] }
    end

    def added_medium_sample_ids
      add_actions_acting_as('MEDIUM').map { |action| action.workup['sample_id'] }
    end

    def added_additive_ids
      add_actions_acting_as('ADDITIVE').map { |action| action.workup['sample_id'] }
    end

    def mounted_equipment
      object.reaction_process_actions.select { |action| action.workup['mount_action'] == 'MOUNT' }
            .map do |action|
        action.workup['equipment'].to_s
      end
    end

    def add_actions_acting_as(acts_as)
      add_actions.select { |action| action.workup['acts_as'] == acts_as }
    end

    def add_actions
      object.reaction_process_actions.select { |action| action.action_name == 'ADD' }
    end

    def saved_sample_ids
      save_sample_actions.map { |action| action.workup['sample_id'] }
    end

    def save_sample_actions
      object.reaction_process_actions.select { |action| action.action_name == 'SAVE' }
    end
  end
end
