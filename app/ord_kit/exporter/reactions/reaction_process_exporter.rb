# frozen_string_literal: true

module OrdKit
  module Exporter
    module Reactions
      class ReactionProcessExporter < OrdKit::Exporter::Base
        def to_ord
          model.reaction_process_steps.order(:position).map { |rps| ReactionStepExporter.new(rps).to_ord }
        end
      end
    end
  end
end
