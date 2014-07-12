Dir[File.dirname(File.realpath(__FILE__)) + "/helpers/*.rb"].each do |f|
  require f
end
