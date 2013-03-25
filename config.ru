require 'rubygems'
require 'sinatra/base'
require 'rdiscount'
require 'yaml'
require 'ostruct'
require 'digest/md5'
require './lib/view_helpers'
require './lib/cache_helpers'
require './lib/ext/kernel'
require './models/article'
require './models/reading'
require './app'

# Preload articles and readings
Article.all
Reading.all

run App
