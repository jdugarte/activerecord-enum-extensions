$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enum_extensions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enum_extensions"
  s.version     = EnumExtensions::VERSION
  s.author      = "Jesús Dugarte"
  s.email       = "jdugarte@gmail.com"
  s.homepage    = "http://github.com/jdugarte/activerecord-enum-extensions/"
  s.summary     = "Scopeless enums, and some syntactic sugar for string enums"
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activerecord", "~> 4.0"

  s.add_development_dependency "rails", "~> 4.0"
  s.add_development_dependency "sqlite3"
end
