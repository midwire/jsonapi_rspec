require 'rspec/matchers'
require 'active_support/all'

require_relative 'string'

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
  include JsonapiRspec

  def initialize(object_instance, plural_form = nil)
    @object_instance = object_instance
    @plural_form = plural_form
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
      when :links
        next # TODO: handle links objects
      else
        return set_failure_message(FailureMessages::UNEXPECTED_TOP_LVL_KEY % key)
      end
    end

    true
  end

  private

  # Set the failure message
  #
  # @param [String] msg Failure message
  #
  # @return [Boolean] always returns false
  #
  def set_failure_message(msg)
    @failure_message = "#{FailureMessages::OBJECT_PREFIX} #{msg}"
    false
  end

  def valid_type?(data_type)
    object_type = @plural_form ||
                  @object_instance.class.name.pluralize.underscore.dasherize
    unless data_type == object_type
      return set_failure_message(
        format(FailureMessages::DATA_TYPE_MISMATCH, data_type, object_type)
      )
    end
    true
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
    else
      matched = obj_val == json_val
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
          return set_failure_message(
            format(FailureMessages::OBJECT_ID_MISMATCH, value, object_id)
          )
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
RSpec::Matchers.define :be_jsonapi_response_for do |object, plural_form|
  match do |actual_response|
    @instance = BeJsonApiResponseFor.new(object, plural_form)

    def failure_message
      @instance.failure_message
    end

    def failure_message_when_negated
      @instance.failure_message
    end

    @instance.matches?(actual_response)
  end
end
