$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require 'tuplex/version'

Gem::Specification.new do |s|
  s.name = "tuplex"
  s.version = Tuplex::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0")
  s.authors = ["Joel VanderWerf"]
  s.date = Time.now.strftime "%Y-%m-%d"
  s.summary = "Tuple index."
  s.description = "Constructs index keys for tuples."
  s.email = "vjoel@users.sourceforge.net"
  s.extra_rdoc_files = ["README.md", "COPYING"]
  s.files = Dir[
    "README.md", "COPYING",
    "lib/**/*.rb",
    "ext/**/*.{rb,c,h}",
    "ext/**/Makefile",
    "bench/*.rb",
    "examples/*.{rb,txt}",
    "test/*.rb"
  ]
  s.extensions = Dir["ext/**/extconf.rb"]
  s.test_files = Dir["test/*.rb"]
  s.homepage = "https://github.com/vjoel/tuplex"
  s.rdoc_options = ["--quiet", "--line-numbers", "--inline-source", "--title", "Tuplex", "--main", "README.md"]
  s.require_paths = ["lib", "ext"]

  s.required_ruby_version = Gem::Requirement.new("~> 2.0")
  s.add_dependency 'msgpack', '~> 0'
  s.add_dependency 'siphash', '~> 0'
end
