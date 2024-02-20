# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe 'be_jsonapi_response' do
  let(:empty_response) do
    res = Rack::Response.new
    res.body = ''
    res
  end

  let(:success_response) do
    response_with('tag_success')
  end

  let(:error_response) do
    response_with('error')
  end

  context 'empty response' do
    it 'fails with the expected message' do
      expect do
        expect(empty_response).to be_jsonapi_response
      end.to raise_error(ExpectationNotMetError, /#{FailureMessages::EMPTY}/)
    end
  end

  context 'error response' do
    it 'fails with the expected message' do
      expect do
        expect(error_response).to be_jsonapi_response
      end.to raise_error(ExpectationNotMetError, /#{FailureMessages::ERROR}/)
    end
  end

  context 'missing required top level sections' do
    it 'fails with the expected message' do
      response = response_with('missing_required_top_level')
      expect do
        expect(response).to be_jsonapi_response
      end.to raise_error(ExpectationNotMetError, /#{FailureMessages::MISSING_REQ_TOP_LVL}/)
    end
  end

  context 'has conflicting top level sections' do
    it 'fails with the expected message' do
      response = response_with('conflicting_top_level')
      expect do
        expect(response).to be_jsonapi_response
      end.to raise_error(ExpectationNotMetError, /#{FailureMessages::CONFLICTING_TOP_LVL}/)
    end
  end

  context 'has unexpected top level key' do
    it 'fails with the expected message' do
      response = response_with('unexpected_key')
      expected_msg = format(FailureMessages::UNEXPECTED_TOP_LVL_KEY, 'alpha')
      expect do
        expect(response).to be_jsonapi_response
      end.to raise_error(ExpectationNotMetError, /#{expected_msg}/i)
    end
  end

  context 'invalid data section' do
    it 'fails with the expected message' do
      response = response_with('invalid_data')
      expect do
        expect(response).to be_jsonapi_response
      end.to raise_error(ExpectationNotMetError, /#{FailureMessages::INVALID_DATA_SECTION}/)
    end
  end
end
