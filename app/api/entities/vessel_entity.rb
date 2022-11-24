# frozen_string_literal: true

module Entities
  class VesselEntity < ApplicationEntity
    expose(:id, :name, :details, :vessel_type,
           :volume_unit, :environment_type, :material_type,
           :automation_type, :environment_details, :material_details,
           :volume_amount, :preparations, :attachments, :attachment_details)
  end
end
