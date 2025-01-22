ReactionProcessEditor::ReactionProcessActivity
  .where(activity_name: 'PURIFY')
  .each do |action|
    action.activity_name = 'PURIFICATION'
    action.workup['purification_steps'] ||= action.workup['purify_steps']
    action.workup.delete('purify_steps')

    action.workup['purification_type'] ||= action.workup['purify_type']
    action.workup.delete('purify_type')
    action.save
  end

ReactionProcessEditor::ReactionProcessActivity
  .where(activity_name: 'MEASUREMENT')
  .each do |action|
    action.activity_name = 'ANALYSIS'

    action.workup['purification_steps'] ||= action.workup['purify_steps']
    action.workup.delete('purify_steps')

    action.workup['analysis_type'] ||= action.workup['measurement_type']
    action.workup.delete('measurement_type')
    action.save
  end
