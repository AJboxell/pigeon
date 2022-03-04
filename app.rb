require 'open-uri'
require 'json'
require 'sinatra'

get '/' do
  if params[:actor]
    url = "https://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=SELECT+%3Ff+%0D%0AWHERE+%7B%0D%0A%3Ff+rdf%3Atype+dbo%3AFilm+.%0D%0A%3Ff+dbo%3Astarring+dbr%3A#{params[:actor]}+.%0D%0A%7D&format=application%2Fsparql-results%2Bjson&timeout=30000&signal_vo"
    endpoint = URI.open(url).read
    films = JSON.parse(endpoint)
    @result = films["results"]["bindings"].map do |film|
      film["f"]["value"].gsub(/^.*resource\//, "").gsub("_", " ")
    end
  elsif params[:film]
    url = "https://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=SELECT+%3Fstarring%0D%0AWHERE+%7B%0D%0A%3Ffilm+rdfs%3Alabel+%22#{params[:film]}%22%40en+%3B%0D%0Adbo%3Astarring++%3Fstarring+.%0D%0A%7D&format=application%2Fsparql-results%2Bjson&timeout=30000&signal_void=on&signal_unconnected=on"
    endpoint = URI.open(url).read
    actors = JSON.parse(endpoint)
    @result = actors
  else
    @result = "no input"
  end
  erb :home
end
