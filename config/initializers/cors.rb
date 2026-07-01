# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do

    chemdev_editor = ENV.fetch(REACT_APP_CHEMOTION_ELN_HOSTNAME, '')

    origins(['localhost:4000', chemdev_editor])

    resource '/api/v1/public/*', headers: :any, methods: %i[get post options]

    resource '/api/v1/reaction_process_editor/*', headers: :any, methods: %i[get post patch put delete options],
                                                  expose: %w[Authorization Access-Control-Allow-Origin Content-Disposition Content-Filename],
                                                  credentials: false
  end

  if Rails.env.development?
    allow do
      # Allow requests from Storybook (default port 6006)
      origins 'http://localhost:6006'
      resource '/assets/*',
               headers: :any,
               methods: %i[get options]
    end
  end
end
