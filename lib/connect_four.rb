# frozen_string_literal: true

require_relative './connect_four_txt'
require_relative './player'

# class for Connect Four game
class ConnectFour
  include ConnectFourTxt
  attr_reader :board

  def initialize
    @board = Array.new(6) { Array.new(7) { ' ' } }
    @player1 = nil
    @player2 = nil
    @round = 0
  end

  def setup_players
    @player1 = create_player('one')
    @player2 = create_player('two')
    @first = goes_first
    @second = @first == @player1 ? @player2 : @player1
  end

  def create_player(num)
    name = player_name(num)
    if @player1.nil?
      sym = player_symbol(name)
    else
      sym = 'O' if @player1.symbol == 'X'
      sym = 'X' if @player1.symbol == 'O'
    end

    Player.new(name, sym)
  end

  def player_name(num)
    loop do
      puts "\nPlayer #{num}, enter your name:"
      name = gets.chomp.strip
      return name unless [nil, ' ', ''].include?(name) || name.to_i.positive? || name.to_i.negative?

      puts "\n'#{name}' is a invalid name. Please, try again."
    end
  end

  def player_symbol(name)
    loop do
      puts "\n#{name}, enter your symbol:" \
      "\n>Enter 1 for 'X' or 2 for 'O'"
      symbol = gets.chomp.strip
      return 'O' if symbol == '2'
      return 'X' if symbol == '1'

      puts "\n'#{symbol}' is a invalid symbol. Please, try again."
    end
  end

  def goes_first
    loop do
      puts "\nSo, who goes first?" \
      "\n>Enter #{@player1.name} or #{@player2.name}<"
      name = gets.chomp.strip.downcase
      return @player1 if name == @player1.name.downcase
      return @player2 if name == @player2.name.downcase

      puts "\n'#{name}' is a invalid name. Please, try again."
    end
  end

  def play(first = @first, second = @second, current_player = first)
    puts "\nRound #{@round}. Fight!"
    show_board
    update_board(input_column(current_player), current_player.symbol)
    result = winner?
    return winner_txt(result) if result[:is] == true

    return tie_txt if tie?

    @round += 1
    case current_player
    when first then play(first, second, second)
    else play(first, second, first)
    end
  end

  def tie?
    result = @board.all? { |row| row.none?(' ') }
  end

  def tie_txt
    show_board
    puts "\nIt's a tie!"
  end

  def winner_txt(result)
    show_board
    player = result[:symbol] == @player1.symbol ? @player1 : @player2

    puts "\nCONGRATULATIONS!! #{player.name}(#{player.symbol}) won by scoring 4 symbols in a row in: #{result[:type]}"
  end

  def input_column(player)
    loop do
      puts "#{player.name}, enter a column:"
      column = gets.chomp.to_i
      next puts "\nInvalid column. Try again." if column > 7 || column.negative?

      return column if @board[0][column] == ' '

      puts "\nThis column is full! Try again."
    end
  end

  def update_board(column, symbol, row = @board.length - 1)
    return @board[row][column] = symbol if @board[row][column] == ' '

    update_board(column, symbol, row - 1)
  end

  def check_rows(row = 5)
    return { is: false } if @board[row].nil? || @board[row].all?(' ')

    symbol = []
    @board[row].length.times do |column|
      break if symbol.length == 4
      next symbol << @board[row][column] if @board[row][column] == symbol.last

      symbol = [@board[row][column]]
    end

    return { is: true, symbol: symbol[0], type: 'row' } if four_in_a_row?(symbol)

    check_rows(row - 1)
  end

  def check_columns(columns = @board.transpose, column = 0)
    return { is: false } if columns[column].nil?

    symbol = []
    columns[column].length.times do |i|
      break if symbol.length == 4
      next symbol << columns[column][i] if columns[column][i] == symbol.last

      symbol = [columns[column][i]]
    end
    return { is: true, symbol: symbol[0], type: 'column' } if four_in_a_row?(symbol)

    check_columns(columns, column + 1)
  end

  def check_upright_diagonals(column = 3, row = @board.length - 1, diagonal = [])
    return { is: false } if @board[2].all?(' ') || row == 2

    symbol = []
    return check_upright_diagonals(0, row - 1) if column.negative?

    num_of_iterations = column.zero? ? row - 1 : (row - column).abs
    (num_of_iterations + 2).times { |i| diagonal << @board[row - i][column + i] }
    diagonal.length.times do |i|
      break if symbol.length == 4
      next symbol << diagonal[i] if diagonal[i] == symbol.last

      symbol = [diagonal[i]]
    end
    return { is: true, symbol: symbol[0], type: 'up right diagonal' } if four_in_a_row?(symbol)

    check_upright_diagonals(column - 1, row)
  end

  def check_upleft_diagonals(column = 3, row = @board.length - 1, diagonal = [])
    return { is: false } if @board[2].all?(' ') || row == 2

    symbol = []
    return check_upleft_diagonals(6, row - 1) if column > 6

    num_of_iterations = column == 6 ? row + 1 : column + 1
    num_of_iterations.times { |i| diagonal << @board[row - i][column - i] }
    diagonal.length.times do |i|
      break if symbol.length == 4
      next symbol << diagonal[i] if diagonal[i] == symbol.last

      symbol = [diagonal[i]]
    end
    return { is: true, symbol: symbol[0], type: 'up left diagonal' } if four_in_a_row?(symbol)

    check_upleft_diagonals(column + 1, row)
  end

  def four_in_a_row?(symbol)
    true unless symbol[0] == ' ' || symbol.length < 4
  end

  def winner?
    result = check_columns
    return result if result[:is] == true

    result = check_rows
    return result if result[:is] == true

    result = check_upleft_diagonals
    return result if result[:is] == true

    result = check_upright_diagonals
    return result if result[:is] == true

    { is: false }
  end

  def show_board
    puts "\nCurrently board:"
    @board.each do |row|
      row.each_with_index do |sym, sym_i|
        next print "| #{sym} |" if sym_i.zero?

        print " #{sym} |"
      end
      puts "\n────────────────────────────"
    end
  end
end
