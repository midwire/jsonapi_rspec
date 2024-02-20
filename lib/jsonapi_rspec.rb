# frozen_string_literal: true

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

  # Called by RSpec when an the json:api response doesn't match the object instance
  #
  # @return [String] The failure message to display in the RSpec output
  #
  def failure_message
    "#{@failure_message} - parsed response: #{pretty_response}"
  end

  def failure_message_when_negated
    @failure_message = "handle method 'failure_message_when_negated' in custom_matchers.rb"
    "#{@failure_message}: #{pretty_response}"
  end

  private

  # Generate a nicely formatted version of the json:api response for output
  #
  # @return [String] Formatted JSON
  #
  def pretty_response
    JSON.pretty_generate(@parsed_response)
  rescue JSON::GeneratorError
    @parsed_response.to_s
  end

  # Determine if the passed response is empty or nil.
  #
  # @param [Rack::Response] response Any object that responds to the :body method
  #
  # @return [Boolean] True if valid, false if not
  #
  def valid_response?(response)
    return set_failure_message(FailureMessages::EMPTY) if response.body == ''
    return set_failure_message(FailureMessages::NIL) if response.body.nil?

    true
  end

  # Determine if the json:api response contains the required top-level sections.
  #
  # @return [Boolean] True if the required sections exist, false if not
  #
  def required_top_level_sections?
    valid = @parsed_response['data'] || @parsed_response['errors'] || @parsed_response['meta']
    return set_failure_message(FailureMessages::MISSING_REQ_TOP_LVL) unless valid

    true
  end

  # Determine if the json:api response contains conflicting top-level sections
  #
  # @return [Boolean] True if the response has an 'included' section but no 'data', false if not
  #
  def conflicting_sections?
    conflicting = false
    # must have a data section
    if @parsed_response['included'] && @parsed_response['data'].nil?
      conflicting = true
      set_failure_message(FailureMessages::CONFLICTING_TOP_LVL)
    end
    conflicting
  end

  # Check the json:api response for a 'meta' section. This is configurable.
  #
  # @return [Boolean] True if the meta section exists and is a Hash, false if not
  #
  def valid_meta_section?
    meta = @parsed_response['meta']
    return set_failure_message(FailureMessages::MISSING_META) unless meta.is_a?(Hash)

    true
  end

  # Determine if the json:api response is an error response.
  #
  # @return [Boolean] True if the response is an error response, false if not
  #
  def response_is_error?
    is_error = !@parsed_response['errors'].nil?
    set_failure_message(FailureMessages::ERROR) if is_error
    is_error
  end

  # Determine if the json:api response contains a valid 'data' section.
  #
  # @return [Boolean] True if the section exists and is value, false if not.
  #
  def valid_data_section?
    data_section = @parsed_response['data']
    valid = data_section.is_a?(Hash) || data_section.is_a?(Array)
    return set_failure_message(FailureMessages::INVALID_DATA_SECTION) unless valid

    true
  end

  # Autoload Section
  autoload :Configuration, 'jsonapi_rspec/configuration'
end

JsonapiRspec.configure {} # initialize the configuration
