# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module Provenances
      class FindOrCreate
        def self.execute!(reaction_process:)
          reaction_process.provenance || reaction_process.create_provenance(
            email: reaction_process.user&.email,
            username: reaction_process.user&.name,
          )
        end
      end
    end
  end
end
