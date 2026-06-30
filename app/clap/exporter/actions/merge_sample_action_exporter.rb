# frozen_string_literal: true

module Clap
  module Exporter
    module Actions
      class MergeSampleActionExporter < Clap::Exporter::Actions::Base
        private

        def action_type_attributes
          {
            merge_samples: Clap::ReactionProcessAction::ActionMergeSamples.new(
              source_sample: sample(source_sample),
              target_sample: sample(target_sample),
              amount: amount,
            ),
          }
        end

        def sample(sample)
          return unless sample

          Clap::Sample.new(
            reaction_role: Clap::ReactionRole::ReactionRoleType::SAMPLE,
            label: sample.preferred_label || sample.short_label,
            name: sample.name,
            purity: Clap::Percentage.new(value: (sample.purity || 1) * 100),
            location: sample.location,
          )
        end

        def source_sample
          sample_from_workup('source_sample_id')
        end

        def target_sample
          sample_from_workup('target_sample_id')
        end

        def sample_from_workup(workup_key)
          ::Sample.find_by(id: workup[workup_key])
        end

        def amount
          Clap::Exporter::Metrics::AmountExporter.new(workup['amount']).to_clap
        end
      end
    end
  end
end
