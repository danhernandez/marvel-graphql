# server.rb
require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/activerecord'
require 'mongoid'

require_relative 'graphql/schema'

# DB setup
Mongoid.load! "mongoid.config"

# Models

class Hero
  include Mongoid::Document

  field :name, type: String
  field :alias, type: String
  field :affiliations, type: Array

  validates :name, presence: true
  validates :alias, presence: true
  validates :affiliations, presence: true

end

class Affiliations
  include Mongoid::Document
  has_many :heros
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
      alias:@hero.alias,
      affiliations:@hero.affiliations
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

  # post to graphql endpoint
  post '/graphql' do
    result = HeroSchema.execute(
      params[:query],
      variables: params[:variables],
      context: { current_hero: nil }
    )
    result.to_json
  end
