# frozen_string_literal: true

module Entities
  module ProcessEditor
    class ReactionProcessStepEntity < ApplicationEntity
      expose(
        :id, :name, :position, :locked, :reaction_process_id, :reaction_id,
        :materials_options, :added_materials_options, :removable_materials_options, :equipment_options,
        :mounted_equipment_options, :transfer_to_options, :transfer_sample_options,
        :action_equipment_options, :label, :final_conditions
      )

      expose_timestamps

      expose :actions, using: 'Entities::ProcessEditor::ReactionProcessActionEntity'
      # expose :vessel, using: 'Entities::ProcessEditor::VesselEntity'

      private

      def actions
        object.reaction_process_actions.order('position')
      end

      def reaction_process_id
        object.reaction_process_id
      end

      # We piggyback the reaction_id, samples_options, added_samples_options, equipment_options, mounted_equipment_options,
      # transfer_sample_options onto each process_step for convenient usage in UI Selects. cbuggle, 24.8.2021.

      def reaction_id
        object.reaction.id
      end

      def materials_options
        # We assemble the material options as required in the Frontend.
        # It's a hodgepodge of samples of different origin merged assigned to certain keys, where the differing
        # materials also have differing attributes to cope with. This has been discussed with and defined by NJung
        # though I'm not entirely certain it's 100% correct yet, as technical class_names differ from colloquial.
        samples = object.reaction.starting_materials + object.reaction.reactants
        solvents = (object.reaction.solvents + object.reaction.purification_solvents).uniq
        diverse_solvents = Medium::DiverseSolvent.all
        additives = Medium::Additive.all
        media = Medium::MediumSample.all
        intermediates = object.reaction.intermediate_samples

        # solvents are to be defined terminally as bespoken with NJung, cbuggle, 06.10.2021
        {
          SAMPLE: samples_options(samples, 'SAMPLE'),
          SOLVENT: samples_options(solvents, 'SOLVENT') + samples_options(diverse_solvents, 'DIVERSE_SOLVENT'),
          MEDIUM: samples_options(media, 'MEDIUM'),
          ADDITIVE: samples_options(additives, 'ADDITIVE'),
          DIVERSE_SOLVENT: samples_options(diverse_solvents, 'DIVERSE_SOLVENT'),
          INTERMEDIATE: samples_options(intermediates, 'SAMPLE'),
        }
      end

      def removable_materials_options
        # For UI selects to REMOVE select with previously added materials, scoped to acts_as.
        {
          # Delivering SOLVENT, MEDIUM und ADDITIVE as bespoken with NJung, 06.10.2021.
          SOLVENT: samples_options(object.added_materials('SOLVENT'), 'SOLVENT'),
          MEDIUM: samples_options(object.added_materials('MEDIUM'), 'MEDIUM'),
          ADDITIVE: samples_options(object.added_materials('ADDITIVE'), 'ADDITIVE'),
          DIVERSE_SOLVENT: samples_options(object.added_materials('DIVERSE_SOLVENT'), 'DIVERSE_SOLVENT'),
        }
      end

      def added_materials_options
        # For the ProcessStepHeader in the UI, in order of actions.
        object.reaction_process_actions.map do |action|
          sample_option(action.sample || action.medium, action.workup['acts_as']) if action.action_name == 'ADD'
        end.compact.uniq
      end

      def samples_options(samples, acts_as)
        samples.map do |sample|
          sample_option(sample, acts_as)
        end
      end

      # This is too big for "options" and should probably move to its own entity ("SampleOptionEntity")?
      # We also have sample_options in the ReactionProcessEntity which contain only :value, :label.
      def sample_option(sample, acts_as)
        {
          id: sample.id,
          value: sample.id,
          # Can we unify this? Using preferred_labels as in most ELN which in turn is an attribute derived from `external_label` but
          # when a sample is saved it gets it's "short_label" set. This is quite irritating.
          label: sample.preferred_label || sample.short_label,
          amount: sample.target_amount_value,
          unit: sample.target_amount_unit,
          unit_amounts: {
            'mmol': sample.amount_mmol,
            'mg': sample.amount_mg,
            'ml': sample.amount_ml
          },
          sample_svg_file: sample&.sample_svg_file,
          acts_as: acts_as }
      end

      def equipment_options
        @equipment_options ||= OrdKit::Equipment::EquipmentType.constants.map do |equipment|
          { value: equipment.to_s, label: equipment.to_s.titlecase }
        end
      end

      def mounted_equipment_options
        options_for(mounted_equipment)
      end

      def transfer_sample_options
        @transfer_sample_options ||= Sample.where(id: transferable_sample_ids).includes(%i[molecule
                                                                                           molecule_name]).map do |s|
          { value: s.id, label: (s.preferred_label || s.short_label).to_s }
        end
      end

      def transfer_to_options
        process_steps = object.reaction_process.reaction_process_steps.order(:position)

        process_steps.map { |process_step| { value: process_step.id, label: process_step.label } }
      end

      def transferable_sample_ids
        @transferable_sample_ids ||= object.reaction_process.saved_sample_ids
      end

      # This is just hardcoded definining the available equipment depending on action type.
      # These are subsets of OrdKit::Equipment::EquipmentType. It's important to have each constant in the ORD as well (else ORD export will write 'UNSEPCIFIED')
      # It might move to a dedicated class when too much clutter. We need to define this backend as the equipment

      def action_equipment_options
        {
          ADD: equipment_options,
          SAVE: [],
          TRANSFER: [],
          EQUIP: equipment_options,
          CONDITION: {
            TEMPERATURE: options_for(
              %w[HEATING_MANTLE BLOW_DRYER OIL_BATH ICE_BATH
                 ALUMINIUM_BLOCK WATER_BATH SAND_BATH],
            ),
            PH: options_for(['PIPET']),
            PRESSURE: options_for(['REACTOR']),
            IRRADIATION: options_for(%w[ULTRA_SOUND_BATH UV_LAMP LED]),
            MOTION: options_for(%w[STIRRER SHAKER HEATING_SHAKER TUBE BALL_MILLING])
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

      def mounted_equipment
        object.reaction_process_actions.map do |action|
          if action.action_name == 'CONDITION'
            action.workup['EQUIPMENT'].try(:[], :value)
          else
            action.workup['equipment']
          end
        end.flatten.uniq.compact
      end
    end
  end
end
