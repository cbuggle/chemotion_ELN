# frozen_string_literal: true

FactoryBot.define do
  factory :medium_sample do
    sum_formula { 'O2' }
    sample_name { 'Oxygen' }
    molecule_name { 'Molecular Oxygen' }
  end
end
