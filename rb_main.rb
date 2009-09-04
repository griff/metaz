#
#  rb_main.rb
#  MetaZ
#
#  Created by Brian Olsen on 26/08/09.
#  Copyright (c) 2009 Maven-Group. All rights reserved.
#
require 'osx/cocoa'

def load_ruby_programs(bundle)
  path = bundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

OSX.init_for_bundle do |bundle, param, logger|
  # bundle  - the bundle related RBApplicationInit
  # param   - the 4th argument of RBApplicationInit
  # logger  - NSLog wrapper for this block
  #             usage: log.info("param=%p", param.to_s)

  load_ruby_programs(bundle)
end
