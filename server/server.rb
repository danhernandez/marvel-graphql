# server.rb
require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'

# DB setup
Mongoid.load! "mongoid.config"

# Models

class Hero
  include Mongoid::Document

  field :name, type: String
  field :realname, type: String
  field :associates, type: String
  field :heroid, type: String

  validates :name, presence: true
  validates :realname, presence: true
  validates :associates, presence: true
  validates :heroid, presence: true

  index({ name: 'text' })
  index({ heroid:1 }, { unique: true, name: "heroid_index" })
end

# Endpoints
get '/' do
  'List of Marvel Heroes...'
end

namespace '/api' do
  # set content type
  before do
    content_type 'application/json'
  end
  # get all heroes:
  get '/hero' do
    # serialize to JSON
    Hero.all.to_json
  end
end
