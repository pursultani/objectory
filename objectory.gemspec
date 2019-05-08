#
# COPYRIGHT
#

require_relative 'lib/objectory/version'

Gem::Specification.new do |s|
  s.name = 'objectory'
  s.version = Objectory::VERSION
  s.summary = 'Object mapping factory'

  s.authors = [
    'Hossein Pursultani'
  ]
  s.email = [
    'hossein@pursultani.net'
  ]
  s.homepage = 'https://github.com/pursultani/objectory'

  s.platform = Gem::Platform::RUBY

  s.add_development_dependency 'rspec', '~> 3.8'
end
