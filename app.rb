require 'sinatra'
require_relative 'query_controller'

cache = {}

get '/' do
  if valid_params?  #/ the app will only respond to queries for 'actor' or 'film' /#
    unless @result = cache[@query]  #/ if the query is already in the 'cache', then the result will be taken from there /#
      dbpedia_call #/ else, the app calls dbpedia and then 'caches' the query and result /#
      cache[@query] = @result
    end
    @query_type == "actor" ? {:films => @result}.to_json : {:actors => @result}.to_json
  else
    "Invalid input = please query in the format http://localhost:4567/?actor=actor_name or http://localhost:4567/?film=film_name"
  end
end

error 404 do
  "I'm sorry, that is not a valid endpoint - please query in the format http://localhost:4567/?actor=actor_name or http://localhost:4567/?film=film_name"
end
