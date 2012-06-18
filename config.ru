require 'rubygems'
require 'sinatra/base'
require 'rdiscount'
require 'yaml'
require 'ostruct'
require './lib/view_helpers'
require './lib/ext/kernel'
require './models/article'
require './app'

run App
