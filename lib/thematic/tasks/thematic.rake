require 'fileutils'

namespace :thematic do
  desc "descriptions of the task" 
  task :install, [:filepath] do |task, args|
    # args[:filepath] represent the path of the theme

    puts "Inspecting theme..."

    puts "Installing CSS..."

    # it is assumed that the theme comes with a folder called 'css'
    copy_from_path = "#{args[:filepath]}/css"
    theme_subfolder = "theme"

    FileUtils.remove_dir "vendor/assets/stylesheets/#{theme_subfolder}" if File.exist?("vendor/assets/stylesheets/#{theme_subfolder}")
    FileUtils.mkdir "vendor/assets/stylesheets/#{theme_subfolder}"

    file_to_edit = "app/assets/stylesheets/application.css"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      if line =~/^*= require_tree ./ #we want to insert new require statements above this line
        Dir.open(copy_from_path).each do |filename|
          unless File.directory?("#{copy_from_path}/#{filename}") || filename[0] == "."
            copy("#{copy_from_path}/#{filename}", "vendor/assets/stylesheets/#{theme_subfolder}/") 
            tempfile << " *= require #{filename.gsub('.css', '')}\n"
          end
        end
      end
      tempfile << line
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close

    puts "Installing JS..."

    # it is assumed that the theme comes with a folder called 'js'
    copy_from_path = "#{args[:filepath]}/js"

    FileUtils.remove_dir "vendor/assets/javascripts/#{theme_subfolder}" if File.exist?("vendor/assets/javascripts/#{theme_subfolder}")
    FileUtils.mkdir "vendor/assets/javascripts/#{theme_subfolder}"

    file_to_edit = "app/assets/javascripts/application.js"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      if line =~/^\/\/= require_tree ./ #we want to insert new require statements above this line
        Dir.open(copy_from_path).each do |filename|
          unless File.directory?("#{copy_from_path}/#{filename}") || filename[0] == "."
            copy("#{copy_from_path}/#{filename}", "vendor/assets/javascripts/#{theme_subfolder}/") unless File.directory?("#{copy_from_path}/#{filename}")
            tempfile << "//= require #{filename.gsub('.js', '')}\n"
          end
        end
      end
      tempfile << line
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close

  end 
end