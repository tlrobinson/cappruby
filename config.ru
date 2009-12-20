#!/usr/bin/env rackup

$:.unshift File.join(File.dirname(__FILE__),'lib-ruby')

require 'cappruby/server'
require 'pathname'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::ShowStatus
# use Rack::Lint
# use Rack::ContentLength

appPath = ARGV[1].nil? ?
  File.join(File.dirname(__FILE__), "TestApp") : # Dir.pwd
  Pathname.new(ARGV[1]).realpath.to_s

puts "Starting up CappRuby server with root: #{appPath}"

run Rack::Cascade.new([
  CappRuby::Server.new(appPath),
  Rack::File.new(appPath)
])
