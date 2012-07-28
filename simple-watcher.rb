#!/usr/local/bin/ruby
#requere ruby >= 1.9
#http://blog.sosedoff.com/2010/06/01/making-colorized-console-output-with-ruby/
#https://developers.google.com/closure/compiler/

# TODO
# - Delete files from build folder when file deleted from source folder
# - Added red color for deleted files

require 'rubygems'
require 'fileutils'

argv_str = ARGV.join(" ")


watch_folder = "src"
build_folder = "public"
profile_name = ".profile"
hash = {}

without_js_compiling = (argv_str.match(/--without_js_compiling/) != nil)
["build_folder", "watch_folder", "profile_name"].each do |match_name|
  match = argv_str.match(Regexp.new('(--' + match_name + '=)([.\w\/]+)'))
  unless (match.nil?)
    eval("#{match_name}=\"#{match[2]}\"")
  end
end

# options for each type of files
# out_type - replacement file type
# cms - command for transform watcher file

options = {
    :haml => {
        :out_type => "html",
        :options => "-t ugly -r './app_helper'",
        :cmd => 'haml #{options[:haml][:options]} #{watch_dir} #{out_dir}/#{file_name}'
    },
    :coffee => {
        :out_type => "js",
        :options => '-b -c -l',
        :cmd => 'coffee #{options[:coffee][:options]} -o #{out_dir} #{watch_dir}',
        :compile => 'java -jar ./compiler/compiler.jar --js #{out_dir}/#{file_name} --js_output_file #{out_dir}/#{compile_file_name}'
    },
    :scss => {
        :out_type => "css",
        :options => "-t compressed -C",
        :cmd => 'sass #{options[:scss][:options]} #{watch_dir} #{out_dir}/#{file_name}'
    }
}

def console_log(text)
  puts "<<< [#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]\e[1m\e[32m #{text} \e[0m"
end

File.open(profile_name, File::CREAT|File::RDWR) do |f|
  content = f.read
  hash = eval(content) unless content.empty?
end

puts "Output <#{build_folder}> folder"
puts "Watching <#{watch_folder}> and subfolders for changes in SASS & HAML & Coffee files..."
puts "Simple watcher is watching for changes. Press Ctrl-C to Stop."

first_loop = true
while true do
  watch_files = []
  options.each_key do |type_name|
    watch_files += Dir.glob(File.join(watch_folder, "**", "*.#{type_name}"))
  end

  new_hash = {}

  watch_files.sort { |a, b| a <=> b }.each do |file|
    new_hash[file] = File.stat(file).mtime.to_i
  end

  new_hash.sort { |a, b| a <=> b }
  diff_hash = new_hash == hash
  delete_files = Hash[hash.to_a - new_hash.to_a]
  unless (delete_files.empty?)
    delete_files.each_key do |file|
      if (!new_hash[file] and hash[file])
        console_log("Delete #{file}")
      end
    end
  end

  unless diff_hash
    new_hash.each_key do |watch_dir|
      next if (File.stat(watch_dir).mtime.to_i == hash[watch_dir])

      file_type = watch_dir.match(/(coffee|scss|haml)$/)[1]
      cmd, compile_cmd = nil

      #if you change partial file u need re-render all files, where are you required its
      if (watch_dir.match(/\/_\w*.*$/))
        next if first_loop
        Dir.glob(File.join(watch_folder, "**", "*.#{file_type}")).each do |file|
          next if (file == watch_dir)
          part_file_name = watch_dir.match(/_\w*[^.*&]/)
          File.open(file, File::RDWR) do |f|
            unless (f.read.to_s.index(part_file_name.to_s).nil?)
              new_hash[file] = 0
            end
          end
        end
        next
      end

      if file_type
        type_opt = options[file_type.to_sym]
        paths = watch_dir.gsub(file_type, type_opt[:out_type]).split('/')
        file_name = paths.pop()
        compile_file_name = file_name
        is_compile = type_opt[:compile].nil?
        unless is_compile
          f_comps = file_name.split(".")
          compile_file_name = [f_comps[0], "min", f_comps[1]].join(".")
        end
        out_dir = build_folder + paths.join('/').gsub(watch_folder, "")
        FileUtils.mkdir_p out_dir
        cmd = eval('"' + type_opt[:cmd] + '"')
        unless without_js_compiling
          compile_cmd = eval('"' + type_opt[:compile] + '"') unless is_compile
        end
      end

      if cmd
        system(cmd)
        console_log("Change detected #{out_dir}/#{file_name}")
      end
      if (compile_cmd)
        system(compile_cmd)
        console_log("Minify #{out_dir}/#{compile_file_name} \e[0m")
      end
    end

    hash = new_hash

    File.open(profile_name, File::CREAT|File::RDWR) do |f|
      f.truncate(0)
      f.write(hash.to_s)
    end
  end

  first_loop = false
  sleep 1
end
