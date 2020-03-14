# -*- encoding : utf-8 -*-
#
require "capybara/cucumber"

require 'middleman-autoprefixer'
require 'middleman-core/rack'
require 'middleman-livereload'

middleman_app = ::Middleman::Application.new

Capybara.app = ::Middleman::Rack.new(middleman_app).to_app do
  set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
  set :environment, :development
  set :show_exceptions, false
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox)
end
Capybara.default_driver = :selenium

Before do
  visit "/"
end

Capybara.default_max_wait_time = 10
Capybara.default_selector = :css
