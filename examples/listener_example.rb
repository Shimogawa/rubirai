# frozen_string_literal: true

require_relative 'helper'
require 'rubirai'

bot = Rubirai::Bot.new '127.0.0.1', 8080

puts 'Enter qq: '
qq = gets.chomp
puts 'Enter auth key: '
auth = gets.chomp

bot.login(qq, auth)
puts 'Login successful.'

bot.add_listener do |event|
  puts "#{event.class} -> #{event.raw}"
end

begin
  bot.start_listen 0.5, is_blocking: true, ignore_error: false
rescue Interrupt
  bot.logout
  puts 'Bye'
end
