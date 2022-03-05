require 'open-uri'

BASE_URL = "https://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=SELECT+%3F"

def valid_params?
  @query_type, @query = params.keys.first, params.values.first
  params[:actor] || params[:film]
end

def dbpedia_call
  dbpedia_response = parse(sparql_query)
  @result = params[:actor] ? extract_values(dbpedia_response, "f") : extract_values(dbpedia_response, "starring")
  if @result == []
    dbpedia_response = parse(sparql_query.gsub("_", "+"))
    @result = params[:actor] ? extract_values(dbpedia_response, "f") : extract_values(dbpedia_response, "starring")
  end
  @result
end

private

def sparql_query
  if params[:actor]
    query_string = "f+%0D%0AWHERE+%7B%0D%0A%3Ff+rdf%3Atype+dbo%3AFilm+.%0D%0A%3Ff+dbo%3Astarring+dbr%3A#{params[:actor]}"
  elsif params[:film]
    query_string = "starring%0D%0AWHERE+%7B%0D%0A%3Ffilm+rdfs%3Alabel+%22#{params[:film]}%22%40en+%3B%0D%0Adbo%3Astarring++%3Fstarring"
  end
  url = "#{BASE_URL}#{query_string}+.%0D%0A%7D&format=application%2Fsparql-results%2Bjson&timeout=30000"
end

def parse(query)
  JSON.parse(URI.open(query).read)
end

def extract_values(results, entity)
  results["results"]["bindings"].map { |value| tidy_string(value[entity]) }
end

def tidy_string(string)
  string["value"].gsub(/^.*resource\//, "").gsub("_", " ")
end
