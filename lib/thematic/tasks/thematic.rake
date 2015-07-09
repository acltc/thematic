require 'fileutils'

namespace :thematic do
  desc "descriptions of the task" 
  task :install, [:filepath] do |task, args|

    # There are a number of things that need to happen in order to install a theme properly
    # into a Rails application. They are:
    # 1. CSS, JS, fonts, and image files must all be copied over into the Rails app.
    #    CSS and JS files belong in the vendor/assets folders, while fonts and images will 
    #    go into app/assets.   
    # 2. Anything inside vendor must be explicitly referenced by the application.css and
    #    application.js files under app/assets. Each and every file must be referenced.
    # 3. Any time that an image url or font url is referenced inside CSS, it must be
    #    modified as follows: The css file must be given a .erb extension, and the url
    #    must be wrapped in erb with an asset path or font path. 
    #    For example: url('images/picture.png')
    #    must be edited to: url('<%= asset_path("theme/picture.png") %>')
    #    and url('../fonts/fontawesome-webfont.eot?v=4.2.0')
    #    must be edited to: url('<%= font_path('theme/fontawesome-webfont.eot')%>?v=4.2.0')
    # 4. Whenever an image is referenced inside HTML, an image_tag or image_path within
    #    erb must be used instead of the plain HTML.
    # Currently, this gem accomplishes steps 1 - 3, and step 4 must be done manually.

    # CSS #################################
    puts "Installing CSS..."

    # We will search the entire theme and all subfolders for all css files
    copy_from_path = args[:filepath]
    theme_subfolder = ENV["THEME"] || "theme"
    images_folder = ENV["IMAGES"] || "img"
    javascript_folder = ENV["JAVASCRIPT"] || "js"

    FileUtils.remove_dir "vendor/assets/stylesheets/#{theme_subfolder}" if File.exist?("vendor/assets/stylesheets/#{theme_subfolder}")
    FileUtils.mkdir "vendor/assets/stylesheets/#{theme_subfolder}"

    if File.exist?("app/assets/stylesheets/application.css") # the default of older Rails versions
      file_to_edit = "app/assets/stylesheets/application.css"
    else
      file_to_edit = "app/assets/stylesheets/application.scss"
    end

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
    copy_from_path = "#{args[:filepath]}/#{javascript_folder}"

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

    copy_from_path = "#{args[:filepath]}/#{images_folder}"

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

    assets_initializer = File.open("config/initializers/assets.rb", 'a')
    assets_initializer << "Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')"
    assets_initializer.close

    # REWRITING URLS REFERENCED IN CSS ##########
    if File.exist?("vendor/assets/stylesheets/#{theme_subfolder}/style.css")
      puts "Configuring images referenced in CSS..."
      FileUtils.mv("vendor/assets/stylesheets/#{theme_subfolder}/style.css", "vendor/assets/stylesheets/#{theme_subfolder}/style.css.erb")

      file_to_edit = "vendor/assets/stylesheets/#{theme_subfolder}/style.css.erb"
      f = File.new(file_to_edit)
      tempfile = File.open("file.tmp", 'w')

      f.each do |line|
        if line =~/background.*url/
          # TODO: Some themes omit the quotation marks around the url
          image_filename = /("|').*("|')/.match(line)[0].split("#{images_folder}/").last.delete('"').delete("'")
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
    end
    puts "Theme installed! Please restart your Rails server." 
  end 

  task :plugin, [:filepath] do |task, args|
    copy_from_path = args[:filepath]
    theme_subfolder = ENV["THEME"] || "theme"


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

  task :template, [:filepath] do |task, args|
    theme_subfolder = ENV["THEME"] || "theme"
    images_folder = ENV["IMAGES"] || "img"

    # user is expected to input which html template to copy from
    sourcefile = File.open(args[:filepath], 'r')

    file_to_edit = "app/views/layouts/application.html.erb"
    f = File.new(file_to_edit)

    tempfile = File.open("file.tmp", 'w')
    f.each do |line|
      break if line =~/<body/ #we will remove existing body and replace it from theme  
      tempfile << line
    end

    reached_body = false
    sourcefile.each do |line|
      reached_body = true if line =~/<body/
      next unless reached_body
      tempfile << line.gsub("#{images_folder}/", "assets/#{theme_subfolder}/")
    end

    FileUtils.mv("file.tmp", file_to_edit)
    f.close
    tempfile.close
    sourcefile.close

    puts "Theme template installed!"
  end

end