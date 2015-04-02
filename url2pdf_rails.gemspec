$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "url2pdf_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "url2pdf_rails"
  s.version     = Url2pdfRails::VERSION
  s.authors     = ["Nic Pillinger"]
  s.email       = ["nic@lsf.io"]
  s.homepage    = "http://factory3.io"
  s.summary     = "Summary of Url2pdfRails."
  s.description = "Description of Url2pdfRails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "url2pdf", "~> 0.0.1"

  s.add_development_dependency "rspec-rails", "~> 3.2"
  s.add_development_dependency "guard-rspec", "~> 4.5"
  s.add_development_dependency "vcr", "~> 2.9"
  s.add_development_dependency "webmock"
end
