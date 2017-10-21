module JsonapiRspec
  # Class Configuration provides a config object for certain options
  #
  # @author Chris Blackburn <87a1779b@opayq.com>
  #
  class Configuration
    attr_accessor :meta_required
    attr_accessor :required_meta_sections

    def initialize
      @meta_required = false
      @required_meta_sections = [] # :copyright, :version, etc.
    end
  end
end
