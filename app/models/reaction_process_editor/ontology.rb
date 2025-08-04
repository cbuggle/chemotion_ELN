# frozen_string_literal: true

# == Schema Information
#
# Table name: ontologies
#
#  id               :uuid             not null, primary key
#  active           :boolean          default(TRUE), not null
#  detectors        :string           default([]), is an Array
#  label            :string
#  link             :string
#  name             :string
#  ontology_type    :string
#  roles            :jsonb
#  solvents         :string           default([]), is an Array
#  stationary_phase :string           is an Array
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ontology_id      :string
#

module ReactionProcessEditor
  class Ontology < ApplicationRecord
    validates :ontology_id, presence: true, uniqueness: true
    has_many :device_methods, class_name: '::ReactionProcessEditor::OntologyDeviceMethod',
                              inverse_of: :ontology, dependent: :nullify

    scope :active, -> { where(active: true) }
  end
end
