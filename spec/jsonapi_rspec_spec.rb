RSpec.describe JsonapiRspec do
  it 'has a version number' do
    expect(JsonapiRspec::VERSION).not_to be nil
  end

  it 'knows its root directory' do
    expect(JsonapiRspec.root).to exist
  end
end
