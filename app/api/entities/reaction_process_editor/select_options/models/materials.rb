# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class Materials < Base
          def select_options_for(reaction_process:)
            # We assemble the material options as required in the Frontend.
            # It's a hodgepodge of samples of different origin merged assigned to certain keys, where the differing
            # materials also have differing attributes to cope with.

            reaction = reaction_process.reaction || reaction_process.sample_reaction

            return [reaction_process.sample] unless reaction

            samples_options_for_reaction(reaction.reload)
          end

          def sample_options_for_user(user:)
            return [] unless user&.samples

            sample_minimal_options(user.samples, 'SAMPLE')
          end

          private

          def samples_options_for_reaction(reaction)
            samples = reaction.starting_materials + reaction.reactants + reaction.products
            samples = samples_with_merged_samples(reaction, samples)
            solvents = (reaction.solvents + reaction.purification_solvents).uniq
            diverse_solvents = Medium::DiverseSolvent.all

            intermediates = reaction.intermediate_samples
            molecular_entities = reaction.sample_molecules
            {
              MOLECULAR_ENTITY: molecular_entity_options(molecular_entities),
              ADDITIVE: samples_info_options(Medium::Additive.all, 'ADDITIVE'),
              DIVERSE_SOLVENT: samples_info_options(diverse_solvents, 'DIVERSE_SOLVENT'),
              INTERMEDIATE: samples_info_options(intermediates, 'SAMPLE'),
              MEDIUM: samples_info_options(Medium::MediumSample.all, 'MEDIUM'),
              SAMPLE: samples_info_options(samples, 'SAMPLE'),
              SOLVENT: samples_info_options(solvents,
                                            'SOLVENT') + samples_info_options(diverse_solvents,
                                                                              'DIVERSE_SOLVENT'),
            }
          end

          def samples_with_merged_samples(reaction, samples)
            sample_ids = samples.map(&:id).compact
            return samples if sample_ids.empty?

            merged_sample_ids = reaction.sample_merges
                                        .where('source_sample_id IN (?) OR target_sample_id IN (?)',
                                               sample_ids, sample_ids)
                                        .pluck(:source_sample_id, :target_sample_id)
                                        .flatten

            (samples + Sample.where(id: merged_sample_ids).to_a).uniq
          end
        end
      end
    end
  end
end
