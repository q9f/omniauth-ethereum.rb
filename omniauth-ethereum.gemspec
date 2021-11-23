lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-ethereum'

Gem::Specification.new do |spec|
  spec.name           = 'omniauth-ethereum'
  spec.version        = '0.1.0'
  spec.summary        = "OmniAuth Strategy for Ethereum"
  spec.description    = "Authentication Strategy for OmniAuth to authenticate a user with an Ethereum account"
  spec.authors        = ["Afri Schoedon"]
  spec.email          = 'gems@fault.dev'
  spec.homepage       = 'https://github.com/q9f/omniauth-ethereum'
  spec.license        = 'Apache-2.0'

  spec.metadata       = {
    'homepage_uri'    => 'https://github.com/q9f/omniauth-ethereum',
    'source_code_uri' => 'https://github.com/q9f/omniauth-ethereum',
    'github_repo'     => 'https://github.com/q9f/omniauth-ethereum',
    'bug_tracker_uri' => 'https://github.com/q9f/omniauth-ethereum/issues',
  }.freeze

  spec.require_paths  = ["lib"]
  spec.files          = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 2.2", "< 4.0"

  # OmniAuth is what this strategy is providing
  spec.add_dependency 'omniauth', '~> 2.0'

  # Use Ruby-Eth for signature recovery
  spec.add_dependency 'eth', '~> 0.4.16'

  # Spec tests
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rack-test', '~> 1.1'
end
