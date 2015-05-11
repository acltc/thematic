# Thematic

By running simple commands from the terminal, you can automatically convert regular [WrapBootstrap](http://wrapbootstrap.com) and other HTML/CSS/JS themes and have them integrate into your Rails app so that it plays nicely with the asset pipeline. 

## Installation

Add this line to your application's Gemfile:


    gem 'thematic'


## Usage

You can watch a [video demo!](https://vimeo.com/126414898) of Thematic being used in action.

Navigate to the root folder of your application, and run the following command:

    rake thematic:install[../relative/path/to/the/root/folder/of/your/theme]
    
The root folder of your theme should be the one that contains the folders 'css', 'img', and 'js', as is standard in many themes.

You can also automatically grab an entire HTML template from the theme as well, and copy it into your app/views/layouts/application.html.erb. (WARNING: THIS WILL OVERWRITE ANY CUSTOM CODE YOU HAVE THERE. So this is something you would do early on in your project.) To do so, run this command:

    rake thematic:template[../relative/path/to/your/theme/template/index.html]

The installation only copies JavaScript from the JS folder, but if there are additional plugins inside another plugins folder, you can also install each plugin individually with:

    rake thematic:plugin[../relative/path/to/your/plugin/folder]

By default, it is assumed that the images are found in a folder called 'img', and that the JavaScript is found in a folder called 'js', but if either of these are not the case, you can specify as such in IMAGES and JAVASCRIPT environment variables. For example, if the images folder was called 'images', and the JavaScript folder was called 'javascripts', you'd run the command as follows:

    rake thematic:install[../relative/path/to/the/root/folder/of/your/theme] IMAGES=images JAVASCRIPT=javascripts

Thematic, by default, will create subfolders throughout your application called 'theme'. If you want to choose a different name for that subfolder, can do so with the THEME environment variable. For example:

    rake thematic:install[../relative/path/to/the/root/folder/of/your/theme] THEME=cowabunga

## Contributing

1. Fork it ( https://github.com/[my-github-username]/thematic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
