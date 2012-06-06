require 'rubygems'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'rdiscount'
require 'yaml'
require 'ostruct'
require './lib/view_helpers'
require './lib/ext/kernel'
require './models/article'
require './mongreliog'

run Mongreliog
