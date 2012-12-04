$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "param_guard/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "param_guard"
  s.version     = ParamGuard::VERSION
  s.authors     = ["Levente Bagi"]
  s.email       = ["bagilevi@gmail.com"]
  s.summary     = "Filter parameters by defining a required structure"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rake"
end

