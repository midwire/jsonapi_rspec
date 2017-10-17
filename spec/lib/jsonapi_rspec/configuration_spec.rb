require 'spec_helper'

module JsonapiRspec
  RSpec.describe Configuration do
    context '#meta_required=' do
      it 'can set the value' do
        JsonapiRspec.configure do |config|
          config.meta_required = true
        end
        expect(JsonapiRspec.configuration.meta_required).to eq true
      end
    end
  end
end
