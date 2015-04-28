require 'fileutils'

namespace :thematic do
  desc "descriptions of the task" 
  task :install, [:filepath] do |task, args|
    # args[:filepath] represent the path of the theme

    puts "Inspecting theme..."

    puts "Installing CSS..."

    copy_from_path = "#{args[:filepath]}/css"
    theme_subfolder = "theme"

    FileUtils.remove_dir "vendor/assets/stylesheets/#{theme_subfolder}" if File.exist?("vendor/assets/stylesheets/#{theme_subfolder}")
    FileUtils.mkdir "vendor/assets/stylesheets/#{theme_subfolder}"

    file_to_edit = "app/assets/stylesheets/application.css"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      if line =~/^*= require_tree ./ #we want to insert new require statements above this line
        files_to_copy = Dir[ File.join(copy_from_path, '**', '*') ]

        files_to_copy.each do |filepath|
          unless File.directory?(filepath) || filepath.end_with?("min.css")
            filename = filepath.split("/").last
            copy(filepath, "vendor/assets/stylesheets/#{theme_subfolder}/") 
            tempfile << " *= require #{theme_subfolder}/#{filename.gsub('.css', '')}\n"
          end
        end
 
      end
      tempfile << line
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close

    puts "Installing JS..."

    copy_from_path = "#{args[:filepath]}/js"

    FileUtils.remove_dir "vendor/assets/javascripts/#{theme_subfolder}" if File.exist?("vendor/assets/javascripts/#{theme_subfolder}")
    FileUtils.mkdir "vendor/assets/javascripts/#{theme_subfolder}"

    file_to_edit = "app/assets/javascripts/application.js"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      if line =~/^\/\/= require_tree ./ #we want to insert new require statements above  
        files_to_copy = Dir[ File.join(copy_from_path, '**', '*') ]

        files_to_copy.each do |filepath|
          unless File.directory?(filepath) || filepath.end_with?("min.js")
            filename = filepath.split("/").last
            copy(filepath, "vendor/assets/javascripts/#{theme_subfolder}/") 
            tempfile << "//= require #{theme_subfolder}/#{filename.gsub('.js', '')}\n"
          end
        end
      end
      tempfile << line
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close

    puts "Copying images..."

    FileUtils.remove_dir "app/assets/images/#{theme_subfolder}" if File.exist?("app/assets/images/#{theme_subfolder}")
    FileUtils.mkdir "app/assets/images/#{theme_subfolder}"

    copy_from_path = "#{args[:filepath]}/img"
    files_to_copy = Dir[ File.join(copy_from_path, '**', '*') ]

    files_to_copy.each do |filepath|
      copy(filepath, "app/assets/images/#{theme_subfolder}/") unless File.directory?(filepath)
    end

    puts "Copying fonts..."

    FileUtils.mkdir "app/assets/fonts" unless File.exist?("app/assets/fonts")
    FileUtils.remove_dir "app/assets/fonts/#{theme_subfolder}" if File.exist?("app/assets/fonts/#{theme_subfolder}")
    FileUtils.mkdir "app/assets/fonts/#{theme_subfolder}"

    copy_from_path = "#{args[:filepath]}/fonts"
    files_to_copy = Dir[ File.join(copy_from_path, '**', '*') ]

    files_to_copy.each do |filepath|
      copy(filepath, "app/assets/fonts/#{theme_subfolder}") unless File.directory?(filepath)
    end

    puts "Configuring FontAwesome..."



  end 
end