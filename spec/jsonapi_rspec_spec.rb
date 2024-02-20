# frozen_string_literal: true

RSpec.describe JsonapiRspec do
  it 'has a version number' do
    expect(JsonapiRspec::VERSION).not_to be_nil
  end

  it 'knows its root directory' do
    expect(described_class.root).to exist
  end
end
