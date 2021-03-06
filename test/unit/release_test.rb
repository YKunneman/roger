# Generators register themself on the CLI module
require "./lib/roger/release.rb"
require "test/unit"

module Roger
  class ReleaseTest < ::Test::Unit::TestCase

    def test_get_callable
      p = lambda{}
      assert_equal Release.get_callable(p, {}), p
      assert_raise(ArgumentError){ Release.get_callable(nil, {})}
    end

    def test_get_callable_with_map
      p = lambda{}
      map = {
        :lambda => p,
      }

      assert_equal Release.get_callable(:lambda, map), p
      assert_raise(ArgumentError){ Release.get_callable(:huh, map)}
    end

    class Works
      def call; end
    end
    class Breaks
    end

    def test_get_callable_with_class
      assert Release.get_callable(Works, {}).instance_of?(Works)
      assert_raise(ArgumentError){ Release.get_callable(Breaks, {}) }
    end

  end
end