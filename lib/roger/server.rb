require 'rack'
require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/rack/roger"

require 'webrick'
require 'webrick/https'

module Roger
  class Server
    
    attr_reader :options, :server_options
    
    attr_reader :project
      
    attr_accessor :port, :handler
    
    def initialize(project, options={})
      @stack = initialize_rack_builder
            
      @project = project
      
      @server_options = {}
      
      set_options(options)
    end
    
    # Sets the options, this is a separate method as we want to override certain
    # things set in the mockupfile from the commandline
    def set_options(options)
      @options = {
        :handler => nil, # Autodetect
        :port => 9000
      }.update(options)
            
      self.port = @options[:port]
      self.handler = @options[:handler]      
    end
        
    # Use the specified Rack middleware
    #
    # @see ::Rack::Builder#use
    def use(*args, &block)
      @stack.use *args, &block
    end
    
    # Use the map handler to map endpoints to certain urls
    #
    # @see ::Rack::Builder#map    
    def map(*args, &block)
      @stack.map *args, &block
    end
            
    def run!
      self.get_handler(self.handler).run self.application, self.server_options do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          puts "Roger, out!"
        end
      end
    end
    alias :run :run!
    
    def port=(p)
      self.server_options[:Port] = p
    end
        
    protected
    
    # Build the final application that get's run by the Rack Handler
    def application
      return @app if @app
      
      @stack.run Rack::Roger.new(self.project)
      
      @app = @stack
    end    
    
    # Initialize the Rack builder instance for this server
    #
    # @return ::Rack::Builder instance
    def initialize_rack_builder
      builder = ::Rack::Builder.new 
      builder.use ::Rack::ShowExceptions
      builder.use ::Rack::Lint
      builder.use ::Rack::ConditionalGet
      builder.use ::Rack::Head      
      
      builder 
    end
    
    # Get the actual handler for use in the server
    # Will always return a handler, it will try to use the fallbacks
    def get_handler(preferred_handler_name = nil)
      servers = %w[puma mongrel thin webrick]
      servers.unshift(preferred_handler_name) if preferred_handler_name
      
      handler = nil
      while((server_name = servers.shift) && handler === nil) do 
        begin
          handler = ::Rack::Handler.get(server_name)
        rescue LoadError
        rescue NameError
        end
      end
            
      if preferred_handler_name && server_name != preferred_handler_name
        puts "Handler '#{preferred_handler_name}' not found, using fallback ('#{server_name}')."
      end
      handler
    end
    
  end
end