require 'rails/plugin'
 
module Rails
  class Plugin
    def initialize(root)
      # ActiveSupport::Deprecation.warn "You have Rails 2.3-style plugins in vendor/plugins! Support for these plugins will be removed in Rails 4.0. Move them out and bundle them in your Gemfile, or fold them in to your app as lib/myplugin/* and config/initializers/myplugin.rb. See the release notes for more on this: http://weblog.rubyonrails.org/2012/01/04/rails-3-2-0-rc2-has-been-released"
      @name = File.basename(root).to_sym
      config.root = root
    end
  end
end