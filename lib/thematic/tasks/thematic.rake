require 'fileutils'

namespace :thematic do
  desc "descriptions of the task" 
  task :install, [:filepath] do |task, args|
    # args[:filepath] represent the path of the theme

    # CSS #################################
    puts "Installing CSS..."

    # We will search the entire theme and all subfolders for all css files
    copy_from_path = args[:filepath]
    theme_subfolder = "theme"

    FileUtils.remove_dir "vendor/assets/stylesheets/#{theme_subfolder}" if File.exist?("vendor/assets/stylesheets/#{theme_subfolder}")
    FileUtils.mkdir "vendor/assets/stylesheets/#{theme_subfolder}"

    file_to_edit = "app/assets/stylesheets/application.css"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      if line =~/^*= require_tree ./ #we want to insert new require statements above this line
        files_to_copy = Dir[ File.join(copy_from_path, '**', '*.css') ]

        #filter out minified versions of libraries that also have a non-minified version
        files_to_copy.reject! { |filename| filename.index(".min") && files_to_copy.include?(filename.gsub(".min", "")) }

        files_to_copy.each do |filepath|
          filename = filepath.split("/").last
          copy(filepath, "vendor/assets/stylesheets/#{theme_subfolder}/") 
          tempfile << " *= require #{theme_subfolder}/#{filename.gsub('.css', '')}\n"
        end
 
      end
      tempfile << line
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close

    # JS #################################
    puts "Installing JS..."

    # We will only search the js folder for js files; plugins can be added via the plugin task below
    copy_from_path = "#{args[:filepath]}/js"

    FileUtils.remove_dir "vendor/assets/javascripts/#{theme_subfolder}" if File.exist?("vendor/assets/javascripts/#{theme_subfolder}")
    FileUtils.mkdir "vendor/assets/javascripts/#{theme_subfolder}"

    file_to_edit = "app/assets/javascripts/application.js"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      if line =~/^\/\/= require_tree ./ #we want to insert new require statements above  
        files_to_copy = Dir[ File.join(copy_from_path, '**', '*.js') ]

        #filter out minified versions of libraries that also have a non-minified version
        files_to_copy.reject! { |filename| filename.index(".min") && files_to_copy.include?(filename.gsub(".min", "")) }

        files_to_copy.each do |filepath|
          filename = filepath.split("/").last
          copy(filepath, "vendor/assets/javascripts/#{theme_subfolder}/") 
          tempfile << "//= require #{theme_subfolder}/#{filename.gsub('.js', '')}\n"
        end
      end
      tempfile << line
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close

    # IMAGES #################################

    puts "Copying images..."

    FileUtils.remove_dir "app/assets/images/#{theme_subfolder}" if File.exist?("app/assets/images/#{theme_subfolder}")
    FileUtils.mkdir "app/assets/images/#{theme_subfolder}"

    copy_from_path = "#{args[:filepath]}/img"

    # We copy all files AND FOLDERS as they exist in the theme folder structure
    Dir.open(copy_from_path).each do |filename|
      next if filename[0] == "."
      cp_r("#{copy_from_path}/#{filename}", "app/assets/images/#{theme_subfolder}/")
    end

    # FONTS #################################

    puts "Copying fonts..."

    FileUtils.mkdir "app/assets/fonts" unless File.exist?("app/assets/fonts")
    FileUtils.remove_dir "app/assets/fonts/#{theme_subfolder}" if File.exist?("app/assets/fonts/#{theme_subfolder}")
    FileUtils.mkdir "app/assets/fonts/#{theme_subfolder}"

    copy_from_path = "#{args[:filepath]}/fonts"
    files_to_copy = Dir[ File.join(copy_from_path, '**', '*') ]

    files_to_copy.each do |filepath|
      copy(filepath, "app/assets/fonts/#{theme_subfolder}") unless File.directory?(filepath)
    end

    if File.exist?("vendor/assets/stylesheets/#{theme_subfolder}/font-awesome.css")
      puts "Configuring FontAwesome..."
      FileUtils.mv("vendor/assets/stylesheets/#{theme_subfolder}/font-awesome.css", "vendor/assets/stylesheets/#{theme_subfolder}/font-awesome.css.erb")

      file_to_edit = "vendor/assets/stylesheets/#{theme_subfolder}/font-awesome.css.erb"
      f = File.new(file_to_edit)
      tempfile = File.open("file.tmp", 'w')

      f.each do |line|
        if line =~/url/
          modified_line = line.gsub("../fonts", "<%= font_path('#{theme_subfolder}").gsub("?", "')%>?")
          tempfile << modified_line
        else
          tempfile << line
        end
      end
      FileUtils.mv("file.tmp", file_to_edit)
      f.close
      tempfile.close

    end

    # REWRITING URLS REFERENCED IN CSS ##########
    if File.exist?("vendor/assets/stylesheets/#{theme_subfolder}/style.css")
      puts "Configuring images referenced in CSS..."
      FileUtils.mv("vendor/assets/stylesheets/#{theme_subfolder}/style.css", "vendor/assets/stylesheets/#{theme_subfolder}/style.css.erb")

      file_to_edit = "vendor/assets/stylesheets/#{theme_subfolder}/style.css.erb"
      f = File.new(file_to_edit)
      tempfile = File.open("file.tmp", 'w')

      f.each do |line|
        if line =~/background.*url/
          # image_filename = /\(.*\)/.match(line)[0].delete('(').delete(')').split("/").last.delete('"')
          image_filename = /".*"/.match(line)[0].split("img/").last.delete('"')
          new_snippet = "(\"<%= asset_path('#{theme_subfolder}/#{image_filename}') %>\")"
          modified_line = line.gsub(/\(.*\)/, new_snippet)
          tempfile << modified_line
        else
          tempfile << line
        end
      end
      FileUtils.mv("file.tmp", file_to_edit)
      f.close
      tempfile.close

      puts "Theme installed!"

    end
  end 

  task :plugin, [:filepath] do |task, args|
    copy_from_path = args[:filepath]
    theme_subfolder = "theme"

    file_to_edit = "app/assets/javascripts/application.js"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      if line =~/^\/\/= require_tree ./ #we want to insert new require statements above  
        files_to_copy = Dir[ File.join(copy_from_path, '*.js') ]

        #filter out minified versions of libraries that also have a non-minified version
        files_to_copy.reject! { |filename| filename.index(".min") && files_to_copy.include?(filename.gsub(".min", "")) }

        files_to_copy.each do |filepath|
          filename = filepath.split("/").last
          copy(filepath, "vendor/assets/javascripts/#{theme_subfolder}/") 
          tempfile << "//= require #{theme_subfolder}/#{filename.gsub('.js', '')}\n"
        end
      end
      tempfile << line
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close
  end

end