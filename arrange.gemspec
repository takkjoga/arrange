$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "arrange/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "arrange"
  s.version     = Arrange::VERSION
  s.authors     = ['Takumi Onodera']
  s.email       = ['takkjoga@gmail.com']
  s.summary     = 'Viewing and Editing ActiveRecord data on Ruby on Rails'
  s.description = s.summary
  s.homepage    = 'https://github.com/takkjoga/arrange'
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.4"
  s.add_dependency 'activesupport'
  s.add_dependency 'ransack'

  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec-rails"
end
