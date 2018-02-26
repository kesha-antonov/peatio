Rails.application.config.middleware.use OmniAuth::Builder do
  provider :identity, fields: [:email], on_failed_registration: IdentitiesController.action(:new)

  case ENV['OAUTH2_SIGN_IN_PROVIDER']
    when 'auth0'
      provider :auth0,
               ENV.fetch('AUTH0_OAUTH2_CLIENT_ID'),
               ENV.fetch('AUTH0_OAUTH2_CLIENT_SECRET'),
               ENV.fetch('AUTH0_OAUTH2_DOMAIN'),
               { authorize_params: {
                   scope: ENV.fetch('AUTH0_OAUTH2_SCOPE', 'openid profile email')
                 }
               }
    when 'google'
      provider :google_oauth2, ENV.fetch('GOOGLE_CLIENT_ID'), ENV.fetch('GOOGLE_CLIENT_SECRET')

    when 'barong'
      provider :barong,
               ENV.fetch('BARONG_CLIENT_ID'),
               ENV.fetch('BARONG_CLIENT_SECRET'),
               domain: ENV.fetch('BARONG_DOMAIN')
  end
end

OmniAuth.config.on_failure = lambda do |env|
  SessionsController.action(:failure).call(env)
end

OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies
   class Identity
     def request_phase
       redirect '/signin'
     end

     def registration_form
       redirect '/signup'
     end
   end
 end
end
