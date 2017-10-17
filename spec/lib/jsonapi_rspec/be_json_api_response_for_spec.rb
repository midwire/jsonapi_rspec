require 'spec_helper'
require 'json'

RSpec.describe 'be_jsonapi_response_for' do
  ExpectationNotMetError = RSpec::Expectations::ExpectationNotMetError

  let(:success_response_json) do
    File.read(JsonapiRspec.root.join('spec', 'fixtures', 'tag_success_response.json'))
  end

  let(:error_response_json) do
    File.read(JsonapiRspec.root.join('spec', 'fixtures', 'error_response.json'))
  end

  let(:tag) do
    Tag.new
  end

  let(:empty_response) do
    res = Rack::Response.new
    res.body = ''
    res
  end

  let(:success_response) do
    empty_response.body = success_response_json
    empty_response
  end

  let(:error_response) do
    empty_response.body = error_response_json
    empty_response
  end

  context 'invalid response' do
    it 'fails with empty string message' do
      expect do
        expect(empty_response).to be_jsonapi_response_for(tag)
      end.to raise_error(ExpectationNotMetError, /empty string/)
    end

    context 'data section' do
      it 'fails with invalid data section message' do
        empty_response.body = File.read(JsonapiRspec.root.join('spec', 'fixtures', 'tag_invalid_data_response.json'))
        expect do
          expect(empty_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /'data' section/)
      end
    end

    context 'data:type section' do
      it 'fails with invalid type section message' do
        expect do
          expect(success_response).to be_jsonapi_response_for(NotTag.new)
        end.to raise_error(ExpectationNotMetError, /data:type/)
      end
    end

    context 'data:attributes section' do
      it 'fails with an invalid data type for String' do
        tag = Tag.new(string_attribute: 13)
        expect do
          expect(success_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /does not match/)
      end

      it 'fails with an invalid data type for Fixnum' do
        tag = Tag.new(fixnum_attribute: '11')
        expect do
          expect(success_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /does not match/)
      end

      it 'fails with incorrect data value' do
        tag = Tag.new(string_attribute: 'Something Else')
        expect do
          expect(success_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /does not match/)
      end
    end

    context 'meta section' do
      before do
        JsonapiRspec.configure do |config|
          config.meta_required = true
        end
      end

      it 'fails when meta section is messing' do
        empty_response.body = File.read(JsonapiRspec.root.join('spec', 'fixtures', 'meta_missing_response.json'))
        expect do
          expect(empty_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /'meta' section is missing/)
      end

      it 'fails when meta:version is missing' do
        empty_response.body = File.read(JsonapiRspec.root.join('spec', 'fixtures', 'meta_missing_version_response.json'))
        expect do
          expect(empty_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /'meta:version' is missing/)
      end

      it 'fails when meta:copyright is missing' do
        empty_response.body = File.read(JsonapiRspec.root.join('spec', 'fixtures', 'meta_missing_copyright_response.json'))
        expect do
          expect(empty_response).to be_jsonapi_response_for(tag)
        end.to raise_error(ExpectationNotMetError, /'meta:copyright' is missing/)
      end
    end

    it 'fails with unexpected root key' do
      empty_response.body = File.read(JsonapiRspec.root.join('spec', 'fixtures', 'unexpected_key_response.json'))
      expect do
        expect(empty_response).to be_jsonapi_response_for(tag)
      end.to raise_error(ExpectationNotMetError, /Unexpected key/i)
    end
  end

  context 'error response' do
    it 'fails with message' do
      expect do
        expect(error_response).to be_jsonapi_response_for(tag)
      end.to raise_error(ExpectationNotMetError, /Response is an error/)
    end
  end

  context 'successful responses' do
    it 'match without error' do
      expect do
        expect(success_response).to be_jsonapi_response_for(tag)
      end.to_not raise_error
    end
  end
end
