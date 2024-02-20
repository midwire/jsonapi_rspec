# frozen_string_literal: true

require 'rspec/matchers'

require_relative 'string'

# Class BeJsonApiResponse provides custom RSpec matching for json:api
# responses in general.
#
# It expects a Rack::Response (or similar) response object
#
# Usage:
#   expect(response).to BeJsonApiResponse.new
#
# @author Chris Blackburn <87a1779b@opayq.com>
#
class BeJsonApiResponse
  include JsonapiRspec

  def matches?(response)
    return false unless valid_response?(response)

    @parsed_response = JSON.parse(response.body)

    return false if response_is_error?
    return false unless required_top_level_sections?
    return false if conflicting_sections?

    return false if JsonapiRspec.configuration.meta_required && !valid_meta_section?

    @parsed_response.each_key do |key|
      case key.to_sym
      when :data
        return false unless valid_data_section?
      when :meta
        return false unless valid_meta_section?
      when :jsonapi
        next # this can legally be anything
      when :included
        next # TODO: handle included objects
      when :links
        next # TODO: handle links objects
      else
        return failure_message(FailureMessages::UNEXPECTED_TOP_LVL_KEY % key)
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
  def failure_message(msg)
    @failure_message = "#{FailureMessages::GENERAL_PREFIX} #{msg}"
    false
  end
end

# Usage:
#   expect(response).to be_jsonapi_response
#
RSpec::Matchers.define :be_jsonapi_response do
  match do |actual_response|
    @instance = BeJsonApiResponse.new

    def failure_message
      @instance.failure_message
    end

    def failure_message_when_negated
      @instance.failure_message
    end

    @instance.matches?(actual_response)
  end
end
