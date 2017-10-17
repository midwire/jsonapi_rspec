module JsonapiRspec
  class Configuration
    attr_accessor :meta_required

    def initialize
      @meta_required = false
    end
  end
end
