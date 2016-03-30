# run this with ruby ytm-merge.rb - modify as needed
require 'fileutils'
include FileUtils
require 'yaml'
opts = YAML.load_file('ytm.yaml')
if opts['shoes_at']
  DIR = opts['shoes_at']
else
  DIR = "/Applications/Shoes.app/Contents/MacOS"
end
home = ENV['HOME']
GEMS_DIR = File.join(home, '.shoes','+gem')
puts "DIR = #{DIR}"
puts "GEMS_DIR = #{GEMS_DIR}"
require_relative 'merge-osx'
PackShoes::merge_osx opts
