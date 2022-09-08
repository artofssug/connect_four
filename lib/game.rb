# frozen_string_literal: true

require_relative './connect_four'

game = ConnectFour.new
game.introduction
game.setup_players
game.play
