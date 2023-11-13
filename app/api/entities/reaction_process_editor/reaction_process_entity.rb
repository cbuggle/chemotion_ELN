# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class ReactionProcessEntity < Grape::Entity
      SELECT_OPTIONS = ::ReactionProcessEditor::SelectOptions.instance

      expose :id, :short_label

      #  expose :vessels, using: 'Entities::ReactionProcessEditor::VesselEntity'  # TODO reinsert once Vessel model is in main.
      #  expose :user_vessels, using: 'Entities::ReactionProcessEditor::VesselEntity' # TODO reinsert once Vessel model is in main.
      expose :reaction_process_steps, using: 'Entities::ReactionProcessEditor::ReactionProcessStepEntity'
      expose :samples_preparations, using: 'Entities::ReactionProcessEditor::SamplePreparationEntity'
      expose :provenance, using: 'Entities::ReactionProcessEditor::ProvenanceEntity'

      expose :reaction_svg_file
      expose :reaction_default_conditions, :user_default_conditions

      expose :select_options

      private

      delegate :reaction, to: :object

      def reaction_process_steps
        # ActiveModel::Serializer#has_many lacks method `order`, or it didn't work.
        # This was the easiest workaround. cbuggle. 09.07.2021
        object.reaction_process_steps.order('position')
      end

      def samples_preparations
        object.samples_preparations.includes([:sample]).order('created_at')
      end

      def provenance
        object.provenance || ::ReactionProcessEditor::Provenance.new(reaction_process: object,
                                                                     email: object.creator.email,
                                                                     username: object.creator.name)
      end

      def reaction_default_conditions
        #  Piggyback reaction_process_id for convenience in UI Forms.
        object.reaction_default_conditions.merge({ reaction_process_id: object.id })
      end

      def user_default_conditions
        SELECT_OPTIONS
          .global_default_conditions
          .merge(object.user_default_conditions)
      end

      def select_options
        {
          #   vessels: vessel_options,  # TODO reinsert once Vessel model is in main.
          samples_preparations: {
            prepared_samples: samples_options(prepared_samples, 'SAMPLE'),
            unprepared_samples: samples_options(unprepared_samples, 'SAMPLE'),
            equipment: SELECT_OPTIONS.equipment_types,
            preparation_types: SELECT_OPTIONS.preparation_types,
          },
          step_name_suggestions: step_name_suggestion_options,
          action_type_equipment: SELECT_OPTIONS.action_type_equipment,
          filtration_modes: SELECT_OPTIONS.filtration_modes,
          condition_additional_information: SELECT_OPTIONS.condition_additional_information,
          addition_speed_types: SELECT_OPTIONS.addition_speed_types,
          materials: materials_options,
          equipment: SELECT_OPTIONS.all_ord_equipment,
          automation_modes: SELECT_OPTIONS.automation_modes,
          motion_types: SELECT_OPTIONS.motion_types,
          remove_types: SELECT_OPTIONS.remove_types,
          save_sample_types: SELECT_OPTIONS.save_sample_types,
          analysis_types: SELECT_OPTIONS.analysis_types,
        }
      end

      def materials_options
        # We assemble the material options as required in the Frontend.
        # It's a hodgepodge of samples of different origin merged assigned to certain keys, where the differing
        # materials also have differing attributes to cope with. This has been discussed with and defined by NJung
        # though I'm not entirely certain it's 100% correct yet, as colloquial naming differs from technical keys.
        samples = reaction.starting_materials + reaction.reactants
        solvents = (reaction.solvents + reaction.purification_solvents).uniq
        diverse_solvents = Medium::DiverseSolvent.all

        intermediates = reaction.intermediate_samples

        {
          SAMPLE: samples_options(samples, 'SAMPLE'),
          SOLVENT: samples_options(solvents, 'SOLVENT') + samples_options(diverse_solvents, 'DIVERSE_SOLVENT'),
          MEDIUM: samples_options(Medium::MediumSample.all, 'MEDIUM'),
          ADDITIVE: samples_options(Medium::Additive.all, 'ADDITIVE'),
          DIVERSE_SOLVENT: samples_options(diverse_solvents, 'DIVERSE_SOLVENT'),
          INTERMEDIATE: samples_options(intermediates, 'SAMPLE'),
        }
      end

      def addition_speed_type_options; end

      # TODO: reinsert once Vessel model is in main.
      # def vessels
      #   object.vessels.order(:created_at)
      # end

      # def user_vessels
      #   object.creator.vessels
      # end

      def step_name_suggestion_options
        reaction_ids = Reaction.where(creator: object.reaction.creator).ids

        procedure_ids = ::ReactionProcessEditor::ReactionProcess.where(reaction_id: reaction_ids).ids

        process_steps = ::ReactionProcessEditor::ReactionProcessStep.where(reaction_process_id: procedure_ids).all

        process_step_names = process_steps.filter_map(&:name).uniq

        process_step_names.map.with_index { |name, idx| { value: idx, label: name } }
      end

      # TODO: reinsert once Vessel model is in main.

      # def vessel_options
      #   {
      #     vessel_types: options_from_ord_constants(OrdKit::Vessel::VesselType.constants),
      #     material_types: options_from_ord_constants(OrdKit::VesselMaterial::VesselMaterialType.constants),
      #     volume_units: options_from_ord_constants(OrdKit::Volume::VolumeUnit.constants),
      #     environment_types: options_from_ord_constants(OrdKit::ReactionSetup::ReactionEnvironment::ReactionEnvironmentType.constants),
      #     automation_types: options_from_ord_constants(OrdKit::Automation::AutomationType.constants),
      #     attachments: options_from_ord_constants(OrdKit::VesselAttachment::VesselAttachmentType.constants),
      #   }.stringify_keys
      # end

      def preparable_samples
        (reaction.reactions_starting_material_samples +
        reaction.reactions_reactant_samples +
        reaction.reactions_solvent_samples +
        reaction.reactions_purification_solvent_samples +
        reaction.reactions_product_samples +
        reaction.reactions_intermediate_samples).map(&:sample).uniq
      end

      def prepared_samples
        object.samples_preparations.order(:created_at).includes(sample: [:molecule]).map(&:sample)
      end

      def unprepared_samples
        preparable_samples - prepared_samples
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
          # Can we unify this? Using preferred_labels as in most ELN which in turn is an attribute derived from
          # `external_label` but when a sample is saved it gets it's "short_label" set. This is quite irritating.
          label: sample.preferred_label || sample.short_label,
          amount: {
            value: sample.target_amount_value,
            unit: sample.target_amount_unit,
          },
          unit_amounts: {
            mmol: sample.amount_mmol,
            mg: sample.amount_mg,
            ml: sample.amount_ml,
          },
          sample_svg_file: sample&.sample_svg_file,
          acts_as: acts_as,
        }
      end

      # def sample_preparation_options
      #   # We deliver all PreparationType from ORD constants.
      #   # The ReactionProcessEditor does not use them but has a well defined subset as required by KIT.
      #   # Subsequentally this might be obsolete.
      #   options_from_ord_constants(OrdKit::CompoundPreparation::PreparationType.constants)
      # end

      # def sample_equipment_options; end

      # def preparation_types_options; end

      # def metrics_equipment_options
      #   SELECT_OPTIONS.action_type_equipment['CONDITION']
      # end

      def options_from_ord_constants(ord_constants)
        ord_constants.map do |option|
          { label: option.to_s.titlecase, value: option.to_s }
        end
      end
    end
  end
end
