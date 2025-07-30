# frozen_string_literal: true

module ReactionProcessEditor
  class Fraction < ApplicationRecord
    belongs_to :reaction_process_activity, class_name: '::ReactionProcessEditor::ReactionProcessActivity',
                                           inverse_of: :fractions
    belongs_to :followup_activity, class_name: '::ReactionProcessEditor::ReactionProcessActivity', optional: true,
                                   dependent: :destroy, inverse_of: :followup_fraction
  end
end
