# frozen_string_literal: true

module Entities
  class ReactionProcessEntity < ApplicationEntity
    expose(:id, :reaction_id, :short_label, :duration, :starts_at)

    expose_timestamps

    expose! :vessels, using: 'Entities::VesselEntity'
    expose! :user_vessels, using: 'Entities::VesselEntity'
    expose! :reaction_process_steps, using: 'Entities::ReactionProcessStepEntity'

    expose! :starting_materials, using: 'Entities::ReactionMaterialEntity'
    expose! :reactants, using: 'Entities::ReactionMaterialEntity'
    expose! :solvents, using: 'Entities::ReactionMaterialEntity'
    expose! :purification_solvents, using: 'Entities::ReactionMaterialEntity'
    expose! :products, using: 'Entities::ReactionMaterialEntity'
    expose! :intermediate_samples, using: 'Entities::ReactionMaterialEntity'

    expose! :samples_preparations, using: 'Entities::SamplePreparationEntity'

    expose! :additives
    expose! :diverse_solvents
    expose! :provenance, using: 'Entities::ProvenanceEntity'

    expose! :select_options

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

    def vessels
      object.vessels.order(:created_at)
    end

    def user_vessels
      object.creator.vessels
    end

    def starting_materials
      object.reaction.reactions_starting_material_samples
    end

    def reactants
      object.reaction.reactions_reactant_samples
    end

    def solvents
      object.reaction.reactions_solvent_samples
    end

    def purification_solvents
      object.reaction.reactions_purification_solvent_samples
    end

    def products
      object.reaction.reactions_product_samples
    end

    def intermediate_samples
      object.reaction.reactions_intermediate_samples
    end

    def additives
      Medium::Additive.all.map { |s| { value: s.id, label: s.label.to_s } }
    end

    def diverse_solvents
      Medium::DiverseSolvent.all.map { |s| { value: s.id, label: s.label.to_s } }
    end

    def provenance
      object.provenance || Provenance.new(reaction_process: object, email: object.creator.email,
                                          username: object.creator.name)
    end

    def select_options
      {
        # solvents: solvents,
        # additives: additives,
        # diverse_solvents: diverse_solvents,
        vessels: vessel_options,
        samples_preparations: {
          prepared_samples: samples_options(prepared_samples),
          unprepared_samples: samples_options(unprepared_samples),
          preparations: sample_preparation_options,
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

    def vessel_options
      {
        vessel_types: options_from_ord_constants(OrdKit::Vessel::VesselType.constants),
        material_types: options_from_ord_constants(OrdKit::VesselMaterial::VesselMaterialType.constants),
        volume_units: options_from_ord_constants(OrdKit::Volume::VolumeUnit.constants),
        environment_types: options_from_ord_constants(OrdKit::ReactionSetup::ReactionEnvironment::ReactionEnvironmentType.constants),
        automation_types: options_from_ord_constants(OrdKit::Automation::AutomationType.constants),
        attachments: options_from_ord_constants(OrdKit::VesselAttachment::VesselAttachmentType.constants),
      }.stringify_keys
    end

    def preparable_samples
      (object.reaction.reactions_starting_material_samples +
      object.reaction.reactions_reactant_samples +
      object.reaction.reactions_solvent_samples +
      object.reaction.reactions_purification_solvent_samples +
      object.reaction.reactions_product_samples +
      object.reaction.reactions_intermediate_samples).map(&:sample).uniq
    end

    def prepared_samples
      object.samples_preparations.map(&:sample)
    end

    def unprepared_samples
      preparable_samples - prepared_samples
    end

    def samples_options(samples)
      samples.map { |s| { value: s.id, label: s.preferred_label || s.short_label.to_s } }
    end

    def sample_preparation_options
      # A well defined subset of OrdKit::CompoundPreparation::CompoundPreparationTypes
      options_from_ord_constants(%w[DISSOLVED HOMOGENIZED TEMPERATURE_ADJUSTED
                                    DEGASSED]).push({ label: 'Drying', value: 'DRIED' })
    end

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
