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
  # s.files = ['lib/rubirai.rb']

  s.required_ruby_version = '>= 2.4'

  s.add_dependency 'http', '>= 5.0.0'
  s.homepage = 'https://github.com/Shimogawa/rubirai'
  s.license = 'AGPLv3'
end
