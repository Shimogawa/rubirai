# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'rubirai/version'

Gem::Specification.new do |s|
  s.name = 'rubirai'
  s.version = Rubirai::VERSION
  s.summary = 'A Mirai QQ bot http interface lib for Ruby.'
  s.description = 'A Mirai QQ bot http interface lib for Ruby.'
  s.authors = ['Rebuild']
  s.email = 'admin@rebuild.moe'
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.6'

  s.add_dependency 'concurrent-ruby', '>= 1.1.8', '< 1.3.0'
  s.add_dependency 'http', '~> 5.0'
  s.homepage = 'https://github.com/Shimogawa/rubirai'
  s.license = 'AGPL-3.0'
end
