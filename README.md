#simple-watcher
==============

Coffee-script, haml and sass simple watcher

require ruby > 1.9

##Installation

To install simple watcher run:

    $ bash setup.sh

##Usage

Run simple-watcher command with parameters in console

    $ simple-watcher params

## Params

    simple-watcher [--without_js_compiling]
         [--watch_folder=folder] - 'src' by default
         [--build_folder=folder] - 'public' by default
         [--profile_name=file_name] - '.profile' by default

## Advanced mode

For more compiling settings use simple-watcher.rb -> options[:engine].options