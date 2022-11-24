# frozen_string_literal: true

module OrdKit
  module Exporter
    module Reactions
      class ReactionActionExporter < OrdKit::Exporter::Base
        ACTION_EXPORTER = {
          ADD: OrdKit::Exporter::Actions::AddActionExporter,
          REMOVE: OrdKit::Exporter::Actions::RemoveActionExporter,
          EQUIP: OrdKit::Exporter::Actions::EquipActionExporter,
          CONDITION: OrdKit::Exporter::Actions::ConditionsActionExporter,
          MOTION: OrdKit::Exporter::Actions::MotionActionExporter,
          PURIFY: OrdKit::Exporter::Actions::PurifyActionExporter,
          TRANSFER: OrdKit::Exporter::Actions::TransferActionExporter,
          ANALYSIS: OrdKit::Exporter::Actions::AnalysisActionExporter,
          WAIT: OrdKit::Exporter::Actions::WaitActionExporter,
          SAVE: OrdKit::Exporter::Actions::SaveSampleActionExporter,
        }.stringify_keys

        def to_ord
          return unless ACTION_EXPORTER[model.action_name]  # TODO: What to do with unknown actions?

          ACTION_EXPORTER[model.action_name].new(model).to_ord
        end
      end
    end
  end
end
