require 'graphql'

HeroType = GraphQL::ObjectType.define do
    name 'Hero'
    description '...'

    field :id, !types.String
    field :name, !types.String
    field :alias, !types.String
    field :affiliations do
        type -> { types[HeroType]}
        resolve -> (hero, args, ctx) { hero.affiliations }
    end
end

QueryType = GraphQL::ObjectType.define do
    name 'Query'
    description '...'

    field :hero do
        type HeroType
        argument :id, !types.String
        resolve -> (root, args, ctx) { Hero.find(args[:id]) }
    end
end

HeroSchema = GraphQL::Schema.define do
  query QueryType
end