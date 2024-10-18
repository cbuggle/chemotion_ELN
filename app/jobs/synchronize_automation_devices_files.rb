# frozen_string_literal: true

# Job to sync with an SFTP server
# Downloads Devices CSV files defining the Devices currently available in the automation lab.

# module ReactionProcessEditor
class SynchronizeAutomationDevicesFiles < ApplicationJob
  def perform
    Rails.logger.info("SynchronizeAutomationDevicesFiles running at #{Time.zone.now}")
    Usecases::ReactionProcessEditor::SFTP::SynchronizeDevices.execute!
  end
end
# end
