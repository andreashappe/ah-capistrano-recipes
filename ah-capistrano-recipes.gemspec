require 'capistrano'

Gem::Specification.new do |s|
  s.name        = 'ah-capistrano-recipes'
  s.version     = '0.0.1'
  s.date        = '2012-11-28'
  s.summary     = "Hola!"
  s.description = "A simple hello world gem"
  s.authors     = ["Andreas Happe"]
  s.email       = 'andreashappe@snikt.net'
  s.files       = Dir["lib/**/*.rb", "lib/templates/*", "tasks/*.rake"]
  s.homepage    = 'http://rubygems.org/gems/hola'
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.rdoc"]

  s.add_dependency "capistrano"
end
