require "thematic/version"
require 'rails'

module Thematic
  class Railtie < Rails::Railtie
    rake_tasks do
      load "thematic/tasks/thematic.rake"
    end
  end
end
