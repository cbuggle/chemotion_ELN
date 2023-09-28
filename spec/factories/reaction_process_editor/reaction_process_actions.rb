# frozen_string_literal: true

FactoryBot.define do
  factory :reaction_process_action, class: 'ReactionProcessEditor::ReactionProcessAction' do
    reaction_process_step { ReactionProcessStep.first || create(:reaction_process_step) }
    workup do
      { target_amount_value: '500',
        target_amount_unit: 'ml' }
    end

    factory :reaction_process_action_add do
      action_name { 'ADD' }

      transient do
        acts_as { 'SAMPLE' }
        sample { create(:sample) }
      end

      after :build do |action, obj|
        action.workup = action.workup.merge({
                                              acts_as: obj.acts_as,
                                              sample_id: obj.sample.id,
                                            })
      end

      factory :reaction_process_action_add_solvent do
        transient do
          acts_as { 'SOLVENT' }
          sample { create(:sample) }
        end
      end

      factory :reaction_process_action_add_medium do
        transient do
          sample { create(:medium_sample) }
          acts_as { 'MEDIUM' }
        end
      end
    end

    factory :reaction_process_action_equip do
      action_name { 'EQUIP' }

      transient do
        mount_action { 'MOUNT' }
        equipment { 'STIRRER' }
      end

      after :build do |action, obj|
        action.workup = {
          mount_action: obj.mount_action,
          equipment: obj.equipment,
        }.stringify_keys
      end
    end

    factory :reaction_process_action_motion do
      action_name { 'MOTION' }
      workup do
        { motion_type: 'STIR',
          motion_mode: 'AUTOMATIC',
          motion_speed: '1',
          motion_unit: 'RPM' }
      end
    end

    factory :reaction_process_action_condition do
      action_name { 'CONDITION' }
      workup do
        { condition_type: 'TEMPERATURE',
          condition_tendency: 'INCREASE',
          condition_value: '20',
          condition_unit: '°C' }
      end
    end

    factory :reaction_process_action_remove do
      action_name { 'REMOVE' }
    end

    factory :reaction_process_action_remove_medium do
      action_name { 'REMOVE' }
      workup { { acts_as: 'MEDIUM' } }
    end

    factory :reaction_process_action_purify do
      action_name { 'PURIFY' }
    end
  end
end
