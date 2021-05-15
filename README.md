# Rubirai

A light-weight Mirai QQ bot http interface lib for Ruby.

## Usage

```ruby
require 'rubirai'
# assuming your mirai http api address and port
# are 127.0.0.1 and 8080
bot = Rubirai::Bot.new('127.0.0.1', '8080')
# qq and auth key
bot.login 1145141919, 'ikisugi_key'
```
