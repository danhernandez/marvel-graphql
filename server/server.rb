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

# Serializers
class HeroSerializer
  def initialize(hero)
    @hero = hero
  end

  def as_json(*)
    data = {
      id:@hero.id.to_s,
      name:@hero.name,
      realname:@hero.realname
    }
    data[:errors] = @hero.errors if@hero.errors.any?
    data
  end
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

  # get all heroes
  get '/hero' do
    heroes = Hero.all
    # serialize to JSON
    heroes.map { |hero| HeroSerializer.new(hero) }.to_json
  end

  # get hero with id
  get '/hero/:id' do |id|
    hero = Hero.where(id: id).first
    halt(404, { message: '404 not found'}.to_json ) unless hero
    HeroSerializer.new(hero).to_json
  end

end
