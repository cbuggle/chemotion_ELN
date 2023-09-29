# frozen_string_literal: true

class Entities::ReactionProcessEditor::ReactionEntity < Grape::Entity
  expose(:id, :short_label, :reaction_svg_file)

  expose(:value)

  private

  def value
    object.id
  end
end
