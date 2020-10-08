$:.push File.expand_path("../lib", __FILE__)

require "odooly/version"

Gem::Specification.new do |s|
  s.name = %q{odooly}
  s.version = Odooly::VERSION

  s.date = %q{2020-09-10}
  s.authors = ["Christian RUsch"]
  s.email = %q{christian.rusch@wingo.ch}
  s.summary = %q{Odooly-Ruby - OpenERP RPC client for Ruby}

  s.files = Dir["{lib}/**/*"] + ["README.md", "Rakefile"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency('nokogiri', [">= 1.10.4"])
end
