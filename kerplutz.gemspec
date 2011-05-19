Gem::Specification.new do |s|
  s.name        = 'kerplutz'
  s.version     = '0.1.0'
  s.authors     = ["Mike Sassak"]
  s.description = "Command-line option parser with subcommands that won't leave you feeling Kerplutz"
  s.summary     = "kerplutz #{s.version}"
  s.email       = "msassak@gmail.com"
  s.homepage    = "https://github.com/msassak/kerplutz"

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rspec'

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
