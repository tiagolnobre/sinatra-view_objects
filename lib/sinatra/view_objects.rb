require "sinatra/view_objects/version"
require 'sinatra'
require 'tilt/erb'

module Sinatra
  module ViewObjects
    module Helpers
      def view(name, *args, layout: :layout)
        view = view_klass(name).new(*args)
        view.app = self
        erb name,
          scope: view,
          layout: layout
      end

      private

      def module_name
        @module_name ||= self.class.name.split("::").first
      end

      def views_module
        @views_module ||= Object.const_get("#{module_name}::Views")
      end

      def view_klass(name)
        views_module.const_get(view_klass_name(name))
      end

      def view_klass_name(name)
        name.to_s.split("_").map {|s| s.capitalize }.join
      end
    end

    def self.registered(app)
      app.helpers ViewObjects::Helpers
      app.set :views, Proc.new { File.join(root, "templates") }
    end

    module View
      attr_writer :app

      def view(name, *args)
        app.view(name, *args, layout: false)
      end

      def erb(name, options = {})
        app.erb name, options.merge(scope: self)
      end

      private
      attr_reader :app
    end
  end
end
