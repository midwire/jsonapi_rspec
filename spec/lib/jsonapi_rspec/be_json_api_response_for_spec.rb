# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe 'be_jsonapi_response_for' do
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
    it 'fails with empty string message' do
      expect do
        expect(empty_response).to be_jsonapi_response_for(Tag.new)
      end.to raise_error(ExpectationNotMetError, /#{FailureMessages::EMPTY}/)
    end
  end

  context 'invalid response' do
    context 'data section' do
      it 'fails with invalid data section message' do
        response = response_with('tag_invalid_data')
        expect do
          expect(response).to be_jsonapi_response_for(Tag.new)
        end.to raise_error(ExpectationNotMetError, /#{FailureMessages::INVALID_DATA_SECTION}/)
      end
    end

    context 'data:type section' do
      it 'fails with invalid type section message' do
        expected_message = format(FailureMessages::DATA_TYPE_MISMATCH, 'tags', 'not-tags')
        expect do
          expect(response_with('tag_success')).to be_jsonapi_response_for(NotTag.new)
        end.to raise_error(ExpectationNotMetError, /#{expected_message}/)
      end

      context 'pluralization' do
        it 'fails on pizzaria without a plural_form given' do
          expected_message = format(FailureMessages::DATA_TYPE_MISMATCH, 'pizzarias', 'pizzaria')
          expect do
            expect(response_with('pizzaria_success')).to be_jsonapi_response_for(Pizzaria.new)
          end.to raise_error(ExpectationNotMetError, /#{expected_message}/)
        end

        it 'uses the passed plural_form if given' do
          expect do
            expect(response_with('pizzaria_success')).to be_jsonapi_response_for(Pizzaria.new, 'pizzarias')
          end.not_to raise_error
        end
      end
    end

    context 'data:attributes section' do
      it 'fails with an invalid data type for String' do
        tag = Tag.new(string_attribute: 13)
        expect do
          expect(success_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /does not match object/)
      end

      it 'fails with an invalid data type for Fixnum' do
        tag = Tag.new(fixnum_attribute: '11')
        expect do
          expect(success_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /does not match object/)
      end

      it 'fails with incorrect data value' do
        tag = Tag.new(string_attribute: 'Something Else')
        expect do
          expect(success_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /does not match object/)
      end
    end

    context 'meta section' do
      before do
        JsonapiRspec.configure do |config|
          config.meta_required = true
        end
      end

      it 'fails when meta section is missing' do
        response = response_with('meta_missing')
        expect do
          expect(response).to be_jsonapi_response_for(Tag.new)
        end.to raise_error(ExpectationNotMetError, /#{FailureMessages::MISSING_META}/)
      end
    end

    it 'fails with unexpected root key' do
      response = response_with('unexpected_key')
      expected_msg = format(FailureMessages::UNEXPECTED_TOP_LVL_KEY, 'alpha')
      expect do
        expect(response).to be_jsonapi_response_for(Tag.new)
      end.to raise_error(ExpectationNotMetError, /#{expected_msg}/)
    end
  end

  context 'error response' do
    it 'fails with message' do
      expect do
        expect(error_response).to be_jsonapi_response_for(Tag.new)
      end.to raise_error(ExpectationNotMetError, /#{FailureMessages::ERROR}/)
    end
  end

  context 'successful responses' do
    it 'match without error' do
      expect do
        expect(success_response).to be_jsonapi_response_for(Tag.new)
      end.not_to raise_error
    end
  end
end
