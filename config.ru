require 'dotenv/load'
require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'

  helpers do
    def protected!
      # Put any authentication code you want in here.
      # This method is run before accessing any resource.

      # Define whitelisted ips
      @ips = ['127.0.0.1'] # Localhost only!

      # If request ip not included
      if not @ips.include? request.ip
        # Deny request
        throw(:halt, [401, "Not authorized\n"])
      end
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
