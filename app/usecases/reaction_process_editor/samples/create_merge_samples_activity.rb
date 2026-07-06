# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module Samples
      class CreateMergeSamplesActivity
        ACTION_NAME = 'MERGE_SAMPLES'
        STEP_NAME = 'Merge Samples'

        def self.execute!(current_user:, reaction:, source_sample:, target_sample:)
          new(
            current_user: current_user,
            reaction: reaction,
            source_sample: source_sample,
            target_sample: target_sample,
          ).execute!
        end

        def initialize(current_user:, reaction:, source_sample:, target_sample:)
          @current_user = current_user
          @reaction = reaction
          @source_sample = source_sample
          @target_sample = target_sample
        end

        def execute!
          validate!

          ActiveRecord::Base.transaction do
            reaction_process = ReactionProcesses::FindOrCreateByReaction.execute!(
              current_user: current_user,
              reaction: reaction,
            )
            process_step = reaction_process.reaction_process_steps.create!(
              name: STEP_NAME,
              position: reaction_process.reaction_process_steps.count,
              automation_mode: Entities::ReactionProcessEditor::Constants::Ontologies::DEFAULT_AUTOMATION_MODE,
            )

            process_step.reaction_process_activities.create!(
              activity_name: ACTION_NAME,
              automation_ordinal: reaction_process.next_automation_ordinal,
              workup: workup,
            )

            process_step
          end
        end

        private

        attr_reader :current_user, :reaction, :source_sample, :target_sample

        def validate!
          raise ArgumentError, 'current_user is required' if current_user.blank?
          raise ArgumentError, 'reaction is required' if reaction.blank?
          raise ArgumentError, 'source_sample is required' if source_sample.blank?
          raise ArgumentError, 'target_sample is required' if target_sample.blank?
          raise ArgumentError, 'source_sample equals target_sample' if source_sample.id == target_sample.id

          validate_reaction_sample!(source_sample, 'source_sample')
          validate_reaction_product!(target_sample, 'target_sample')
        end

        def validate_reaction_sample!(sample, name)
          return if reaction.reactions_product_samples.exists?(sample_id: sample.id)
          return if reaction.sample_merges.exists?(source_sample_id: sample.id, target_sample_id: target_sample.id)

          raise ArgumentError, "#{name} must be a product of this reaction"
        end

        def validate_reaction_product!(sample, name)
          return if reaction.reactions_product_samples.exists?(sample_id: sample.id)

          raise ArgumentError, "#{name} must be a product of this reaction"
        end

        def workup
          {
            source_sample_id: source_sample.id,
            target_sample_id: target_sample.id,
            amount: amount,
          }.deep_stringify_keys
        end

        def amount
          if target_sample.density.to_f.positive?
            { value: target_sample.amount_ml(:real), unit: 'ml' }
          else
            { value: target_sample.amount_g(:real), unit: 'g' }
          end
        end
      end
    end
  end
end
