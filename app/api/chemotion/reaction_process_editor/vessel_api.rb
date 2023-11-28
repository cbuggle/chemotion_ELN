module Chemotion
  module ReactionProcessEditor
    class VesselAPI < Grape::API
      rescue_from :all

      namespace :vessels do
        get do
          vessels = current_user.created_vessels + current_user.vessels

          present vessels, with: Entities::ReactionProcessEditor::VesselEntity, root: :vessels
        end
      end
    end
  end
end
