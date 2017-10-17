require 'jsonapi_rspec/version'
require 'jsonapi_rspec/be_json_api_response_for'

module JsonapiRspec
  class << self
    attr_accessor :configuration

    def root
      Pathname.new(File.dirname(__FILE__)).parent
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end

  autoload :Configuration, 'jsonapi_rspec/configuration'
end

JsonapiRspec.configure {} # initialize the configuration
