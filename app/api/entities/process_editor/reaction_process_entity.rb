# frozen_string_literal: true

module Entities
  module ProcessEditor
    class ReactionProcessEntity < ApplicationEntity
      expose(:id, :reaction_id, :short_label, :duration, :starts_at)

      expose_timestamps

      #  expose :vessels, using: 'Entities::ProcessEditor::VesselEntity'  # TODO reinsert once Vessel model is in main.
      #  expose :user_vessels, using: 'Entities::ProcessEditor::VesselEntity' # TODO reinsert once Vessel model is in main.
      expose :reaction_process_steps, using: 'Entities::ProcessEditor::ReactionProcessStepEntity'

      expose :samples_preparations, using: 'Entities::ProcessEditor::SamplePreparationEntity'

      expose :provenance, using: 'Entities::ProcessEditor::ProvenanceEntity'

      expose :select_options

      expose :reaction_svg_file

      private

      def duration
        object.duration || 0
      end

      def reaction_process_steps
        # ActiveModel::Serializer#has_many lacks method `order`, or it didn't work.
        # This was the easiest workaround. cbuggle. 09.07.2021
        object.reaction_process_steps.order('position')
      end

      def short_label
        object.reaction.short_label
      end

      # TODO: reinsert once Vessel model is in main.
      # def vessels
      #   object.vessels.order(:created_at)
      # end

      # def user_vessels
      #   object.creator.vessels
      # end

      def provenance
        object.provenance || Provenance.new(reaction_process: object, email: object.creator.email,
                                            username: object.creator.name)
      end

      def select_options
        {
          #   vessels: vessel_options,  # TODO reinsert once Vessel model is in main.
          samples_preparations: {
            prepared_samples: samples_options(prepared_samples),
            unprepared_samples: samples_options(unprepared_samples),
            # preparations: sample_preparation_options,
            equipment: sample_equipment_options,
          },
          step_name_suggestions: step_name_suggestion_options,
        }
      end

      def step_name_suggestion_options
        reaction_ids = Reaction.where(creator: object.reaction.creator).ids

        procedure_ids = ReactionProcess.where(reaction_id: reaction_ids).ids

        process_steps = ReactionProcessStep.where(reaction_process_id: procedure_ids).all

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
        (object.reaction.reactions_starting_material_samples +
        object.reaction.reactions_reactant_samples +
        object.reaction.reactions_solvent_samples +
        object.reaction.reactions_purification_solvent_samples +
        object.reaction.reactions_product_samples +
        object.reaction.reactions_intermediate_samples).map(&:sample).uniq
      end

      def prepared_samples
        object.samples_preparations.order(:created_at).includes([:sample]).map(&:sample)
      end

      def unprepared_samples
        preparable_samples - prepared_samples
      end

      def samples_options(samples)
        samples.map { |s| { value: s.id, label: s.preferred_label || s.short_label.to_s } }
      end

      # def sample_preparation_options
      #   # We deliver all PreparationType from ORD constants.
      #   # The ReactionProcessEditor does not use them but has a well defined subset as required by KIT.
      #   # Subsequentally this might be obsolete.
      #   options_from_ord_constants(OrdKit::CompoundPreparation::PreparationType.constants)
      # end

      def sample_equipment_options
        options_from_ord_constants(OrdKit::Equipment::EquipmentType.constants)
      end

      def options_from_ord_constants(ord_constants)
        ord_constants.map do |option|
          { label: option.to_s.titlecase, value: option.to_s }
        end
      end
    end
  end
end
