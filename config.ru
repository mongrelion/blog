require 'rubygems'
require 'sinatra/base'
require 'rdiscount'
require 'yaml'
require 'json'
require 'ostruct'
require 'digest/md5'
require './lib/view_helpers'
require './lib/cache_helpers'
require './lib/core_ext/kernel'
require './lib/model'
require './models/article'
require './models/reading'
require './models/project'
require './app'

Encoding.default_external = "utf-8"

# Preload articles and readings
Article.all
Reading.all

run App
