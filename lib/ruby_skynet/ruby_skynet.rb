require 'sync_attr'

module RubySkynet
  include SyncAttr
  @@config = nil

  # Returns the default region for all Ruby Skynet Clients and Services
  def self.region
    @@region ||= 'Development'
  end

  # Sets the default region to use for Skynet Clients and Services
  def self.region=(region)
    @@region = region
  end

  # Returns the service_path where services are located
  def self.services_path
    @@services_path ||= 'app/services'
  end

  # Sets the service_path where services are located
  def self.services_path=(services_path)
    @@services_path = services_path
  end

  # Returns the starting port for the server to listen on
  # If this port is in use the next available port will be used
  # upto 999 above the server_port value
  def self.server_port
    @@server_port ||= 2000
  end

  def self.server_port=(server_port)
    @@server_port = server_port
  end

  # The ip address at which this server instance can be reached
  # by remote Skynet clients
  # Note: Must be an IP address, not the hostname
  def self.local_ip_address
    @@local_ip_address ||= Common::local_ip_address
  end

  def self.local_ip_address=(local_ip_address)
    @@local_ip_address = local_ip_address
  end

  # Returns the services registry which holds the service names
  # and the hosts on which they are running
  #
  # By default it connects to a local ZooKeeper instance
  # Use .configure! to supply a configuration file with any other settings
  sync_cattr_reader :service_registry do
    ServiceRegistry.new(registry: {})
  end

  # Returns the current Registry Config information
  #
  # By default it connects to a local ZooKeeper instance
  # Use .configure! to supply a configuration file with any other settings
  def self.registry_config
    @@config.dup if @@config
  end

  # Set the services registry
  #   It is recommended to call RubySkynet.configure! rather than calling this
  #   method directly
  def self.service_registry=(service_registry)
    @@service_registry = service_registry
  end

  # Load the Configuration information from a YAML file
  #  filename:
  #    Name of file to read.
  #        Mandatory for non-Rails apps
  #        Default: Rails.root/config/ruby_skynet.yml
  #  environment:
  #    Which environment config to load. Usually: production, development, etc.
  #    Default: Rails.env
  def self.configure!(filename=nil, environment=nil)
    config_file = filename.nil? ? Rails.root.join('config', 'ruby_skynet.yml') : Pathname.new(filename)
    raise "ruby_skynet config not found. Create a config file at: config/ruby_skynet.yml" unless config_file.file?

    config = YAML.load(ERB.new(File.new(config_file).read).result)[environment || Rails.env]
    raise("Environment #{Rails.env} not defined in config/ruby_skynet.yml") unless config

    @@config = config.dup

    RubySkynet.region           = config.delete(:region)           || 'Development'
    RubySkynet.services_path    = config.delete(:services_path)    || 'app/services'
    RubySkynet.server_port      = config.delete(:server_port)      || 2000
    RubySkynet.local_ip_address = config.delete(:local_ip_address) || Common::local_ip_address

    # Extract the registry configuration element
    RubySkynet.service_registry = ServiceRegistry.new(
      :registry => config.delete(:registry)
    )

    config.each_pair {|k,v| warn "Ignoring unknown RubySkynet config option #{k} => #{v}"}
  end

  # Returns [Boolean] whether the RubySkynet.configure! method has already been called
  def self.configured?
    !@@config.nil?
  end
end
