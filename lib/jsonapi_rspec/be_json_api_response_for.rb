require 'active_support/all'

# Class BeJsonApiResponseFor provides custom RSpec matching for json:api responses
#
# Usage:
#   expect(response).to BeJsonApiResponseFor.new(model_instance)
#
# @author Chris Blackburn <87a1779b@opayq.com>
#
class BeJsonApiResponseFor
  def initialize(model_instance)
    @model_instance = model_instance
  end

  def matches?(response)
    if response.body == ''
      return set_failure_message('Expected response to match a model instance but it is an empty string')
    end
    @parsed_response = JSON.parse(response.body)

    return set_failure_message('Response is an error') if response_is_error?
    return false unless valid_meta_section?
    return false unless valid_data_section?
    return false unless valid_type?
    return false unless valid_attributes?

    @parsed_response.each do |key, value|
      case key.to_sym
      when :data
        return false unless match_model?(value)
      when :meta
        next # this is already checked above
      else
        return set_failure_message("Unexpected key in response: '#{key}'")
      end
    end

    true
  end

  def failure_message
    @failure_message ||= "Expected model [#{@model_instance}] to match"
    "#{@failure_message} - parsed response: #{JSON.pretty_generate(@parsed_response)}"
  end

  def failure_message_when_negated
    @failure_message = "handle method 'failure_message_when_negated' in custom_matchers.rb"
    "#{@failure_message}: #{JSON.pretty_generate(@parsed_response)}"
  end

  private

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

  def valid_data_section?
    unless @parsed_response.dig('data').is_a?(Hash)
      return set_failure_message("The 'data' section is missing or invalid")
    end
    true
  end

  def valid_attributes?
    unless @parsed_response.dig('data', 'attributes').is_a?(Hash)
      return set_failure_message("The 'data:attributes' section is missing or invalid")
    end
    true
  end

  def valid_type?
    data_type = @parsed_response.dig('data', 'type')
    model_type = @model_instance.class.name.underscore.dasherize.pluralize
    unless data_type == model_type
      return set_failure_message("Expected data:type '#{data_type}' to match: '#{model_type}'")
    end
    true
  end

  def valid_meta_section?
    meta = @parsed_response.dig('meta')
    return set_failure_message("The 'meta' is missing or invalid") unless meta.is_a?(Hash)
    return set_failure_message("The 'meta:version' is missing") if meta.dig('version').nil?
    unless meta.dig('copyright') =~ /^Copyright.+\d{4}/
      return set_failure_message("The 'meta:copyright' is missing or invalid - regex: '/^Copyright.+\\d{4}/'")
    end
    true
  end

  def response_is_error?
    !@parsed_response.dig('errors').nil?
  end

  def match_untyped_value?(x, y)
    case x.class.name
    when 'String'
      x == y.to_s
    when 'Fixnum', 'Integer'
      x == y.to_i
    when 'Time'
      x.to_i == Time.parse(y).to_i
    when 'NilClass', 'TrueClass', 'FalseClass'
      x == y
    else
      set_failure_message("Fix 'match_untyped_value?' method to handle: '#{x.class.name}'")
    end
  end

  def match_model?(values)
    values.each do |key, value|
      case key.to_sym
      when :id
        model_id = @model_instance.send(key)
        unless model_id == value.to_i
          return set_failure_message("Expected '#{value}' to match model id: '#{model_id}'")
        end
      when :type
        next # should have already checked this
      when :attributes
        value.each do |attr, val|
          attribute = attr.underscore
          next if attr.to_sym == :links # skip link validation
          # return false unless @model_instance.send(attribute) == val
          return false unless match_untyped_value?(@model_instance.send(attribute), val)
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
#   expect(response).to be_jsonapi_response_for(model_instance)
#
RSpec::Matchers.define :be_jsonapi_response_for do |model|
  match do |actual_response|
    @instance = BeJsonApiResponseFor.new(model)

    def failure_message
      @instance.failure_message
    end

    def failure_message_when_negated
      @instance.failure_message
    end

    @instance.matches?(actual_response)
  end
end
