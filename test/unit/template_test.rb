# encoding: UTF-8
# Generators register themself on the CLI module
require "./lib/roger/template.rb"
require "test/unit"

module Roger
  class TemplateTest < ::Test::Unit::TestCase
    def setup
      @base = Pathname.new(File.dirname(__FILE__) + "/../project")
      @config = {
        :partials_path => @base + "partials",
        :layouts_path => @base + "layouts"
      }
      @template_path = @base + "html"
    end

    def test_encoding

    end

    # Extension
    def test_source_extension
      mime_types = {
        "html" => "html",
        "html.erb" => "html.erb",
        "css.erb" => "css.erb",
        "json.erb" => "json.erb",
        "sjon.json.erb" => "json.erb",
        "js.erb" => "js.erb"
      }

      mime_types.each do |ext, ext_out|
        assert_equal ext_out, Template.new("", @config.update(:source_path => @base + "html/file.#{ext}")).source_extension
      end      
    end

    def test_target_extension
      mime_types = {
        "html" => "html",
        "html.erb" => "html",
        "css.erb" => "css",
        "json.erb" => "json",
        "js.erb" => "js"
      }

      mime_types.each do |ext, ext_out|
        assert_equal ext_out, Template.new("", @config.update(:source_path => @base + "html/file.#{ext}")).target_extension
      end      
    end


    # Mime type
    def test_target_mime_type
      mime_types = {
        "html" => "text/html",
        "html.erb" => "text/html",
        "css.erb" => "text/css",
        "json.erb" => "application/json"
      }

      mime_types.each do |ext, mime|
        assert_equal mime, Template.new("", @config.update(:source_path => @base + "html/file.#{ext}")).target_mime_type
      end
    end

    # Front-matter

    def test_front_matter_partial_access
      template = Template.new("---\ntest: yay!\n---\n<%= partial 'test/front_matter' %>", @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render, "yay!"
    end    

    # Partials

    def test_encoding_in_partials
    end

    def test_partial
      template = Template.new("<%= partial 'test/simple' %>", @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render, "ERB"

      template = Template.new("<%= partial 'test/simple.html' %>", @config.update(:source_path => @base + "html/test.erb"))
      assert_equal template.render, "ERB"
    end

    def test_partial_with_double_template_extensions
      template = Template.new("<%= partial 'test/json.json' %>", @config.update(:source_path => @base + "html/test.erb"))
      assert_equal template.render, "{ key: value }"
    end

    def test_partial_with_preferred_extension
      template = Template.new("<%= partial 'test/json' %>", @config.update(:source_path => @base + "html/test.html.erb"))
      assert_raise(ArgumentError) {
        template.render
      }

      template = Template.new("<%= partial 'test/json' %>", @config.update(:source_path => @base + "html/test.json.erb"))
      assert_equal template.render, "{ key: value }"

    end

    def test_partial_with_block
      template = Template.new("<% partial 'test/yield' do %>CONTENT<% end %>", @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render, "B-CONTENT-A"

      template = Template.new("<% partial 'test/yield' do %><%= 'CONTENT' %><% end %>", @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render, "B-CONTENT-A"
    end

    def test_partial_with_block_without_yield
      template = Template.new("<% partial 'test/simple' do %>CONTENT<% end %>", @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render, "ERB"
    end

    # Content for parts

    def test_content_for_not_returning_in_template
      content_for_block = 'B<% content_for :one do %><%= "one" %><% end %>A'

      template = Template.new(content_for_block, @config.update(:source_path => @base + "html/test.erb"))
      assert_equal template.render, "BA"
    end

    def test_content_for_yield_in_layout
      content_for_block = "---\nlayout: \"yield\"\n---\nB<% content_for :one do %><%= \"one\" %><% end %>A"

      template = Template.new(content_for_block, @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render, "BAone"      
    end

    def test_content_for_yield_in_layout_without_content_for
      content_for_block = "---\nlayout: \"yield\"\n---\nBA"

      template = Template.new(content_for_block, @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render, "BA"
    end    

    # Environment

    def test_template_env
      template = Template.new("<%= env[:test] %>", @config.update(:source_path => @base + "html/test.html.erb"))
      assert_equal template.render(:test => "test"), "test"
    end



  end
end