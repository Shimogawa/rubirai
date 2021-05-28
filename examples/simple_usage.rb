# frozen_string_literal: true

require_relative 'helper'
require 'rubirai'

bot = Rubirai::Bot.new '127.0.0.1', 8080

puts 'Enter qq: '
qq = gets.chomp
puts 'Enter auth key: '
auth = gets.chomp

bot.login(qq, auth)

puts 'Login successful. Enter qq to send message to:'
target = gets.chomp

bot.send_friend_msg(
  target,
  'hello', ' world!',
  Rubirai::ImageMessage(url: 'https://i0.hdslb.com/bfs/album/67fc4e6b417d9c68ef98ba71d5e79505bbad97a1.png')
)

bot.logout
