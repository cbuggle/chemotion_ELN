# frozen_string_literal: true

module Entities
  module ProcessEditor
    class ProvenanceEntity < ApplicationEntity
      expose(:reaction_process_id,
             :starts_at,
             :city,
             :doi,
             :patent,
             :publication_url,
             :username,
             :name,
             :orcid,
             :organization,
             :email)
    end
  end
end
