namespace :ruby_skynet do

  desc "Start the Ruby Skynet Server.\n Rails Example: rake ruby_skynet:server\n Without Rails: SKYNET_ENV=production SKYNET_CONFIG=config/ruby_skynet.yml rake ruby_skynet:server"
  task :server => :environment do
    # Configuration is automatically loaded when running under Rails
    # so skip it here under Rails
    unless defined?(Rails)
      # Environment to use in config file
      # Defaults to Rails.env
      environment = ENV['SKYNET_ENV']

      # Environment to use in config file
      # Defaults to config/ruby_skynet.yml
      cfg_file = ENV['SKYNET_CONFIG']

      # Load the configuration file
      RubySkynet.configure!(cfg_file, environment)
    end

    server = nil
    begin
      server = RubySkynet::Server.new
      server.register_services_in_path
      server.wait_until_server_stops
    ensure
      server.close if server
    end
  end

end
