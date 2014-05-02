# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'irc/client/character/voice/version'

Gem::Specification.new do |spec|
  spec.name          = "irc-client-character-voice"
  spec.version       = Irc::Client::Character::Voice::VERSION
  spec.authors       = ["mattak"]
  spec.email         = ["mattak.me@gmail.com"]
  spec.summary       = %q{The irc client for character voice api.}
  spec.description   = %q{The irc client for character voice api.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
