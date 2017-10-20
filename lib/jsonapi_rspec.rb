require 'jsonapi_rspec/version'
require 'jsonapi_rspec/failure_messages'
require 'jsonapi_rspec/be_json_api_response'
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

  def failure_message
    "#{@failure_message} - parsed response: #{pretty_response}"
  end

  def failure_message_when_negated
    @failure_message = "handle method 'failure_message_when_negated' in custom_matchers.rb"
    "#{@failure_message}: #{pretty_response}"
  end

  private

  def pretty_response
    JSON.pretty_generate(@parsed_response)
  rescue JSON::GeneratorError
    @parsed_response.to_s
  end

  def valid_response?(response)
    return set_failure_message(FailureMessages::EMPTY) if response.body == ''
    return set_failure_message(FailureMessages::NIL) if response.body.nil?
    true
  end

  def required_top_level_sections?
    valid = @parsed_response.dig('data') || @parsed_response.dig('errors') || @parsed_response.dig('meta')
    return set_failure_message(FailureMessages::MISSING_REQ_TOP_LVL) unless valid
    true
  end

  def conflicting_sections?
    conflicting = false
    if @parsed_response.dig('included')
      # must have a data section
      if @parsed_response.dig('data').nil?
        conflicting = true
        set_failure_message(FailureMessages::CONFLICTING_TOP_LVL)
      end
    end
    conflicting
  end

  def valid_meta_section?
    meta = @parsed_response.dig('meta')
    return set_failure_message(FailureMessages::MISSING_META) unless meta.is_a?(Hash)
    true
  end

  def response_is_error?
    is_error = !@parsed_response.dig('errors').nil?
    set_failure_message(FailureMessages::ERROR) if is_error
    is_error
  end

  def valid_data_section?
    data_section = @parsed_response.dig('data')
    valid = data_section.is_a?(Hash) || data_section.is_a?(Array)
    unless valid
      return set_failure_message(FailureMessages::INVALID_DATA_SECTION)
    end
    true
  end

  # Autoload Section
  autoload :Configuration, 'jsonapi_rspec/configuration'
end

JsonapiRspec.configure {} # initialize the configuration
