# frozen_string_literal: true

# Class Tag provides a dummy class for use in comparing with jsonapi responses
#
# @author Chris Blackburn <87a1779b@opayq.com>
#
class Tag
  attr_accessor :id, :string_attribute, :time_attribute, :datetime_attribute,
    :true_attribute, :false_attribute, :nil_attribute, :fixnum_attribute,
    :integer_attribute, :float_attribute, :bignum_attribute

  def initialize(options = {})
    json = File.read(JsonapiRspec.root.join('spec', 'fixtures', 'tag_success_response.json'))
    parsed = JSON.parse(json)
    self.id = parsed.dig('data', 'id').to_i
    parsed.dig('data', 'attributes').each do |key, val|
      case key.to_sym
      when :string_attribute
        send(:"#{key}=", options[key.to_sym] || val.to_s)
      when :time_attribute
        send(:"#{key}=", options[key.to_sym] || Time.parse(val))
      when :datetime_attribute
        send(:"#{key}=", options[key.to_sym] || DateTime.parse(val))
      when :true_attribute, :false_attribute, :nil_attribute
        send(:"#{key}=", options[key.to_sym] || val)
      when :fixnum_attribute, :integer_attribute, :bignum_attribute
        send(:"#{key}=", options[key.to_sym] || val.to_i)
      when :float_attribute
        send(:"#{key}=", options[key.to_sym] || val.to_f)
      when :links
        next # ignore
      else
        fail "Unexpected attribute type: #{key} = #{val}"
      end
    end
  end
end
