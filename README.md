# Rubirai
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FShimogawa%2Frubirai.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FShimogawa%2Frubirai?ref=badge_shield)


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


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FShimogawa%2Frubirai.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FShimogawa%2Frubirai?ref=badge_large)