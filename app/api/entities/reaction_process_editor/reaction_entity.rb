# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class ReactionEntity < Grape::Entity
      expose(:id, :short_label, :reaction_svg_file)

      expose(:value)

      private

      def reaction_svg_link
        object.reaction_svg_file
      end

      def value
        object.id
      end
    end
  end
end
