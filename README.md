# Rubirai

[![Gem Version](https://badge.fury.io/rb/rubirai.svg)](https://rubygems.org/gems/rubirai)
[![CI](https://github.com/Shimogawa/rubirai/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/Shimogawa/rubirai/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/Shimogawa/rubirai/branch/master/graph/badge.svg?token=OVUVEWFPKY)](https://codecov.io/gh/Shimogawa/rubirai)
[![Maintainability](https://api.codeclimate.com/v1/badges/9a9d8c887e5deb601e1e/maintainability)](https://codeclimate.com/github/Shimogawa/rubirai/maintainability)
[![Inline docs](http://inch-ci.org/github/shimogawa/rubirai.svg?branch=master)](http://inch-ci.org/github/shimogawa/rubirai)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FShimogawa%2Frubirai.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FShimogawa%2Frubirai?ref=badge_shield)

A light-weight Mirai QQ bot http interface lib for Ruby.

[中文][wiki] | [Rubydocs][rubydocs]

## Description

This library is designed specifically for integration with [mirai-api-http].
[Mirai][mirai] is a QQ bot framework. The relationship is like this:

```
mirai <-jvm-> mirai-console <-plugin-> mirai-api-http <-http-> rubirai
```

[mirai-api-http]: https://github.com/project-mirai/mirai-api-http
[mirai]: https://github.com/mamoe/mirai

## Prerequisite

Install [mirai-api-http] and configure its `setting.yml` file.

Now its easier to enable `singleMode` if you have only one account
in the mirai console.

Note that you **must** enable Http Adapter with configuration of
`http` under `adapterSettings`. More mode support to come.

## Usage

First, download the package using `gem`. In your `Gemfile`, add

```ruby
gem 'rubirai'
```

Then, start to write code (no matter if it's a rails application or something else):

```ruby
require 'rubirai'
# assuming your mirai http api address and port
# are 127.0.0.1 and 8080
bot = Rubirai::Bot.new('127.0.0.1', '8080')
# qq and verify key
bot.login 1145141919, 'ikisugi_key'

# Add a listener function
bot.add_listener do |event|
  puts event.inspect
  if event.is_a?(Rubirai::MessageEvent)
    event.respond("Hello, world!")
  end
end

# Listen to message every 0.5 seconds
# And blocks the current thread
bot.start_listen 0.5, is_blocking: true
```

> If you want to install globally with `gem`, use

```bash
gem install rubirai 
```

## Wiki and Documentation

- [中文 Wiki][wiki]
- [Docs][rubydocs]

## License

[AGPL-3.0 License][license]

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FShimogawa%2Frubirai.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FShimogawa%2Frubirai?ref=badge_large)


[wiki]: https://github.com/Shimogawa/rubirai/wiki
[rubydocs]: https://www.rebuild.moe/rubirai/
[license]: LICENSE
