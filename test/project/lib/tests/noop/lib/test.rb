module RogerNoopTest
  class Test

    def initialize(options={})
      @options = {}
      @options.update(options) if options            
    end

    def call(test, options={})
      test.log(self, "NOOP")
      true
    end

  end
end