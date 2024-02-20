# frozen_string_literal: true

require 'spec_helper'

module JsonapiRspec
  RSpec.describe Configuration do
    describe '#meta_required=' do
      it 'can set the value' do
        JsonapiRspec.configure do |config|
          config.meta_required = true
        end
        expect(JsonapiRspec.configuration.meta_required).to be true
      end
    end
  end
end
