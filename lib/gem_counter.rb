require "json"

class JsonParser
  attr_reader :name, :downloads

  def initialize(json_text)
    json = JSON.parse(json_text)
    @name, @downloads = json.first.fetch("name"), json.first.fetch("downloads").to_i
  end
end

class GemStatisticsComparer
  def initialize(data_sets)
    @data_sets = data_sets
  end

  def increase_for(percentile)
    older_data_set = @data_sets.first
    newer_data_set = @data_sets.last
    shared_gem_names = older_data_set.keys | newer_data_set.keys
    differences = {}
    shared_gem_names.each {|gem_name| differences[gem_name] = newer_data_set.fetch(gem_name) - older_data_set.fetch(gem_name)}
    sorted_differences = differences.values.sort.reverse
    
    index = ((sorted_differences.size - 1) * percentile/100.0).round #Ideally, if the index is x.5, it should average value x with value x+1, but not an issue right now
    
    sorted_differences.fetch(index)
  end
end