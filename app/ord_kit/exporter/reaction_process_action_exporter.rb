# frozen_string_literal: true

module OrdKit
  module Exporter
    class ReactionProcessActionExporter < OrdKit::Exporter::Base
      ACTION_EXPORTER = {
        ADD: OrdKit::Exporter::Actions::AddActionExporter,
        REMOVE: OrdKit::Exporter::Actions::RemoveActionExporter,
        CONDITION: OrdKit::Exporter::Actions::ConditionsActionExporter,
        PURIFY: OrdKit::Exporter::Actions::PurifyActionExporter,
        TRANSFER: OrdKit::Exporter::Actions::TransferActionExporter,
        ANALYSIS: OrdKit::Exporter::Actions::AnalysisActionExporter,
        PAUSE: OrdKit::Exporter::Actions::WaitActionExporter,
        WAIT: OrdKit::Exporter::Actions::WaitActionExporter,
        SAVE: OrdKit::Exporter::Actions::SaveSampleActionExporter,
      }.stringify_keys

      def to_ord(starts_at:)
        return unless ACTION_EXPORTER[model.action_name]  # TODO: What to do with unknown actions?

        ACTION_EXPORTER[model.action_name].new(model).to_ord(starts_at: starts_at)
      end
    end
  end
end
