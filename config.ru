require 'rubygems'
require 'sinatra/base'
require 'rdiscount'
require 'yaml'
require 'ostruct'
require './lib/view_helpers'
require './lib/ext/kernel'
require './models/article'
require './models/reading'
require './app'

# TODO: Preload articles and readings
run App
