# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eba/version'

Gem::Specification.new do |spec|
  spec.name          = "eba"
  spec.version       = Eba::VERSION
  spec.authors       = ["Rafael Campos Cruz"]
  spec.email         = ["rcampos@tendencias.com.br"]

  spec.summary       = %q{Class which serves as interface with Brazillian Central Bank databases through the Webservice SGS - Sistema Gerenciador de Séries Temporais - v2.1. eba stands for Easy BCB Access and is also an expression of joy in Brazillian Portuguese.}
  spec.description   = %q{This class was developed in a partinership with Tendencias - Consultoria Econômica, a economical analysis company from Brazil. The intent is, given that you know one of more primary keys for series inside the BCB database, you can extract updates or the full historical data of said series.}
  spec.homepage      = "https://github.com/rCamposCruz/eba"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "nokogiri", "~> 1.6"
  spec.add_development_dependency "savon", "~> 2.11"
  spec.add_development_dependency "net", "~> 0.1"
end
