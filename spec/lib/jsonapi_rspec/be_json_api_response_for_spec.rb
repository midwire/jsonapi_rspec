require 'spec_helper'
require 'json'

RSpec.describe 'be_jsonapi_response_for' do
  Tag = Struct.new(:id, :type, :name, :created_at, :updated_at)

  let(:valid_jsonapi_response) do
    {
      'data' => {
        'id' => '234',
        'type' => 'tags',
        'attributes' => {
          'type' => 'Category',
          'name' => 'Wellness',
          'created-at' => '2017-10-13T19:33:54.000Z',
          'updated-at' => '2017-10-13T19:33:54.000Z',
          'links' => {
            'self' => 'http://test.host/api/v1/tag_types.234'
          }
        }
      },
      'meta' => {
        'copyright' => 'Copyright 2017 Chris Blackburn',
        'version' => 'V5'
      }
    }.to_json
  end

  let(:tag) do
    Tag.new(234, 'Category', 'Wellness', Time.now, Time.now)
  end

  let(:response) do
    response = Rack::Response.new
    response.body = valid_jsonapi_response
    response
  end

  it 'matches on data => id' do
    tag.id = 999
    expect do
      expect(response).to be_jsonapi_response_for(tag)
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /model id/)
  end

  it 'matches on data => type' do
    tag.type = 'Bogus'
    expect do
      expect(response).to be_jsonapi_response_for(Object.new)
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /data:type/)
  end

  it 'matches on data => attributes' do
    tag.created_at = 1.year.ago
    expect do
      expect(response).to be_jsonapi_response_for(tag)
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /^Expected model/)
  end

  it 'matches on meta' do
    expect do
      expect(response).to be_jsonapi_response_for(tag)
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /^Expected model/)
  end
end
