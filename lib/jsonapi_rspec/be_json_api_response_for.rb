require_relative 'string'
require 'active_support/all'

# Class BeJsonApiResponseFor provides custom RSpec matching for json:api
# responses for a given object instance. It checks attributes and elements
# iteratively and fails on the first mismatch that it finds.
#
# It expects a Rack::Response (or similar) object to be passed as the left-side
# of the comparison and a regular Object-derived instance as the right-side.
#
# Usage:
#   expect(response).to BeJsonApiResponseFor.new(object_instance)
#
# @author Chris Blackburn <87a1779b@opayq.com>
#
class BeJsonApiResponseFor
  def initialize(object_instance)
    @object_instance = object_instance
  end

  def matches?(response)
    return false unless valid_response?(response)

    @parsed_response = JSON.parse(response.body)

    return false if response_is_error?
    return false unless valid_data_section?
    if JsonapiRspec.configuration.meta_required
      return false unless valid_meta_section?
    end

    @parsed_response.each do |key, value|
      case key.to_sym
      when :data
        return false unless match_object?(value)
      when :meta
        return false unless valid_meta_section?
      when :jsonapi
        next # this can legally be anything
      when :included
        next # TODO: handle included objects
      else
        return set_failure_message("Unexpected key in response: '#{key}'")
      end
    end

    true
  end

  def failure_message
    @failure_message ||= "Expected object [#{@object_instance}] to match"
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

  # Set the failure message
  #
  # @param [String] msg Failure message
  #
  # @return [Boolean] always returns false
  #
  def set_failure_message(msg)
    @failure_message = msg
    false
  end

  def valid_response?(response)
    if response.body == ''
      return set_failure_message('Expected response to match an object instance but it is an empty string')
    end
    true
  end

  def valid_data_section?
    unless @parsed_response.dig('data').is_a?(Hash)
      return set_failure_message("The 'data' section is missing or invalid")
    end
    true
  end

  def valid_type?(data_type)
    object_type = @object_instance.class.name.underscore.dasherize.pluralize
    unless data_type == object_type
      return set_failure_message("Expected data:type '#{data_type}' to match: '#{object_type}'")
    end
    true
  end

  def valid_meta_section?
    meta = @parsed_response.dig('meta')
    return set_failure_message("The 'meta' section is missing or invalid") unless meta.is_a?(Hash)
    return set_failure_message("The 'meta:version' is missing") if meta.dig('version').nil?
    unless meta.dig('copyright') =~ /^Copyright.+\d{4}/
      return set_failure_message("The 'meta:copyright' is missing or invalid - regex: '/^Copyright.+\\d{4}/'")
    end
    true
  end

  def response_is_error?
    is_error = !@parsed_response.dig('errors').nil?
    set_failure_message('Response is an error') if is_error
    is_error
  end

  def match_attribute?(attr_name, json_val)
    obj_val = @object_instance.send(attr_name.to_sym)
    obj_val_class_name = obj_val.class.name

    case obj_val_class_name
    when 'Float'
      matched = obj_val == json_val.to_f
    when 'DateTime'
      matched = obj_val.to_i == DateTime.parse(json_val).to_i
    when 'Time'
      matched = obj_val.to_i == Time.parse(json_val).to_i
    when 'String', 'NilClass', 'TrueClass', 'FalseClass', 'Fixnum', 'Integer', 'Bignum'
      matched = obj_val == json_val
    else
      return set_failure_message("Fix 'match_attribute?' method to handle: '#{obj_val_class_name}'")
    end

    unless matched
      return set_failure_message(
        <<-STRING.here_with_pipe!(' ')
          |Attribute: :#{attr_name}
          |with a value of '#{json_val}'(#{json_val.class.name})
          |does not match object: '#{obj_val}'(#{obj_val.class.name})
        STRING
      )
    end
    true
  end

  def match_object?(values)
    values.each do |key, value|
      case key.to_sym
      when :id
        object_id = @object_instance.send(key)
        unless object_id == value.to_i
          return set_failure_message("Expected '#{value}' to match object id: '#{object_id}'")
        end
      when :type
        return false unless valid_type?(value)
      when :attributes
        value.each do |attr, val|
          attribute = attr.underscore
          next if attr.to_sym == :links # skip link validation
          # return false unless @object_instance.send(attribute) == val
          return false unless match_attribute?(attribute, val)
        end
      when :relationships
        next # skip relationships validation
      else
        fail "Invalid attribute: '#{key}'"
      end
    end
    true
  end
end

# Usage:
#   expect(response).to be_jsonapi_response_for(object_instance)
#
RSpec::Matchers.define :be_jsonapi_response_for do |object|
  match do |actual_response|
    @instance = BeJsonApiResponseFor.new(object)

    def failure_message
      @instance.failure_message
    end

    def failure_message_when_negated
      @instance.failure_message
    end

    @instance.matches?(actual_response)
  end
end
