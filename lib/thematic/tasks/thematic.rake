require 'fileutils'

namespace :thematic do
  desc "descriptions of the task" 
  task :install, [:filepath] do |task, args|
    puts "Inspecting theme..."

    puts "Installing CSS..."
    copy_from_path = "#{args[:filepath]}/css"

    FileUtils.mkdir 'vendor/assets/stylesheets/theme'

    Dir.open(copy_from_path).each do |filename|
      copy("#{copy_from_path}/#{filename}", "vendor/assets/stylesheets/theme/") unless File.directory?("#{copy_from_path}/#{filename}")
    end

    puts "Installing JS..."
    copy_from_path = "#{args[:filepath]}/js"

    FileUtils.mkdir 'vendor/assets/javascripts/theme'

    Dir.open(copy_from_path).each do |filename|
      copy("#{copy_from_path}/#{filename}", "vendor/assets/javascripts/theme/") unless File.directory?("#{copy_from_path}/#{filename}")
    end

  end 
end