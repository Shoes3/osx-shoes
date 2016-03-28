# run this with ./cshoes --ruby ytm-merge.rb
require 'yaml'
# OSX needs help for ./cshoes
puts "cd = #{`pwd`}"
puts "ARGV = #{ARGV.inspect}"
Dir.chdir(ARGV[0])
puts "Now #{Dir.pwd}"
opts = YAML.load_file('ytm.yaml')
here = Dir.getwd
home = ENV['HOME']
GEMS_DIR = File.join(home, '.shoes','+gem')
puts "DIR = #{DIR}"
puts "GEMS_DIR = #{GEMS_DIR}"
require_relative 'merge-osx'
PackShoes::merge_osx opts
