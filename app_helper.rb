require 'haml'

module Haml
  module Helpers
    def render_file(filename, from_root=false)
      dir = from_root ? Dir.pwd : caller[0].match(/^[\w\/]*\//).to_s
      contents = File.read(dir + filename)
      Haml::Engine.new(contents).render
    end
  end
end
