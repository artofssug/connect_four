# frozen_string_literal: true

require_relative './../lib/connect_four'

describe ConnectFour do
  describe '#update_board' do
    subject(:game_update) { described_class.new }
    let(:player1) { double('Player one', symbol: 'X') }

    it "updates the board with the current player's symbol" do
      expect { game_update.update_board(0, 'X') }.to change { game_update.board[5][0] }.from(' ').to('X')
    end

    context 'column has only one valid cell' do
      before do
        current_board = Array.new(6) do |row|
          Array.new(7) do |column|
            next ' ' if row.zero? && column == 3

            column == 3 ? %w[X O].sample : ' '
          end
        end
        game_update.instance_variable_set(:@board, current_board)
      end

      it "updates the board with the current player's symbol" do
        expect { game_update.update_board(3, 'X') }.to change { game_update.board[0][3] }.from(' ').to('X')
      end
    end
  end

  describe '#input_column' do
    subject(:game_input) { described_class.new }
    let(:player1) { double('Player one', symbol: 'X', name: 'Gustavo') }

    before do
      allow(game_input).to receive(:puts)
    end

    context 'player enters a valid column' do
      it 'return chosen column' do
        allow(game_input).to receive(:gets).and_return('0')
        result = game_input.input_column(player1)
        expect(result).to eq(0)
      end
    end

    context 'player enters an invalid column, and then a valid column' do
      before do
        current_board = Array.new(6) { Array.new(7) { |column| column == 3 ? %w[X O].sample : ' ' } }
        game_input.instance_variable_set(:@board, current_board)
        allow(game_input).to receive(:gets).and_return('3', '0')
      end

      it 'receives a error message once' do
        error_message = "\nThis column is full! Try again."
        expect(game_input).to receive(:puts).with(error_message).once
        game_input.input_column(player1)
      end
    end

    context 'player enters two invalid columns, and then a valid column' do
      before do
        current_board = Array.new(6) { Array.new(7) { |column| [0, 3].include?(column) ? %w[X O].sample : ' ' } }
        game_input.instance_variable_set(:@board, current_board)
        allow(game_input).to receive(:gets).and_return('3', '0', '1')
      end

      it 'receives a error message twice' do
        error_message = "\nThis column is full! Try again."
        expect(game_input).to receive(:puts).with(error_message).twice
        game_input.input_column(player1)
      end
    end
  end

  describe '#check_rows' do
    subject(:game_row) { described_class.new }
    let(:player1) { double('Player One') }

    context 'second row has 4 identical symbols in a row' do
      before do
        current_board = Array.new(6) do |row|
          next [' ', ' ', ' ', 'O', 'O', 'O', 'O'] if row == 1

          Array.new(7) do |column|
            [0, 3].include?(column) ? %w[X O].sample : ' '
          end
        end
        game_row.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_row.check_rows
        expect(result[:is]).to be true
      end
    end

    context 'none of the rows has at least 4 identical symbols in a row' do
      it 'returns false' do
        result = game_row.check_rows
        expect(result[:is]).to be false
      end
    end
  end

  describe '#check_columns' do
    subject(:game_columns) { described_class.new }

    context 'second column has at least 4 identical symbols in a row' do
      before do
        current_board = Array.new(6) do
          Array.new(7) { |column| column == 3 ? 'O' : ' ' }
        end
        game_columns.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_columns.check_columns
        expect(result[:is]).to be true
      end
    end

    context 'none of the columns has at least 4 identical symbols in a row' do
      it 'returns false' do
        result = game_columns.check_columns
        expect(result[:is]).to be false
      end
    end
  end

  describe '#check_upright_diagonals' do
    subject(:game_upr_diagonals) { described_class.new }

    context 'up right diagonal has 4 identical symbols in a row' do
      before do
        current_board = [[' ', ' ', ' ', 'O', ' ', ' ', ' '],
                         [' ', ' ', 'O', ' ', 'O', 'X', ' '],
                         [' ', 'O', 'X', 'O', 'X', 'O', ' '],
                         ['O', 'O', 'O', 'X', 'O', 'X', 'O'],
                         ['O', 'X', 'O', 'X', 'O', 'X', 'X'],
                         ['X', 'O', 'O', 'X', 'O', 'X', 'X']]
        game_upr_diagonals.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_upr_diagonals.check_upright_diagonals
        expect(result[:is]).to be true
      end
    end

    context 'no up right diagonal has at least 4 identical symbols in a row' do
      before do
        current_board = [[' ', ' ', ' ', 'O', ' ', 'O', 'O'],
                         [' ', ' ', 'O', ' ', 'X', 'X', ' '],
                         [' ', 'X', 'X', 'O', 'X', 'O', ' '],
                         ['O', 'O', 'O', 'X', 'O', 'X', 'O'],
                         ['O', 'X', 'O', 'X', 'O', 'X', 'X'],
                         ['X', 'O', 'O', 'X', 'O', 'X', 'X']]
        game_upr_diagonals.instance_variable_set(:@board, current_board)
      end

      it 'returns false' do
        result = game_upr_diagonals.check_upright_diagonals
        expect(result[:is]).to be false
      end
    end

    context 'no cell has been filled yet' do
      it 'returns false' do
        result = game_upr_diagonals.check_upleft_diagonals
        expect(result[:is]).to be false
      end
    end
  end

  describe '#check_upleft_diagonals' do
    subject(:game_upleft_diagonals) { described_class.new }

    context 'up left diagonal has 4 identical symbols in a row' do
      before do
        current_board = [[' ', ' ', ' ', 'O', ' ', 'O', 'O'],
                         [' ', ' ', 'O', 'X', 'O', 'X', ' '],
                         ['O', 'X', 'X', 'O', 'X', 'O', ' '],
                         ['O', 'O', 'O', 'X', 'O', 'X', 'O'],
                         ['O', 'X', 'O', 'X', 'O', 'X', 'X'],
                         ['X', 'O', 'O', 'X', 'O', 'X', 'X']]
        game_upleft_diagonals.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_upleft_diagonals.check_upleft_diagonals
        expect(result[:is]).to be true
      end
    end

    context 'no up left diagonal has at least 4 identical symbols in a row' do
      before do
        current_board = [[' ', ' ', ' ', 'O', ' ', 'O', 'O'],
                         [' ', ' ', 'O', ' ', 'O', 'X', ' '],
                         [' ', 'X', 'X', 'O', 'X', 'X', ' '],
                         ['O', 'O', 'O', 'X', 'O', 'X', 'O'],
                         ['O', 'X', 'O', 'X', 'O', 'X', 'X'],
                         ['X', 'O', 'O', 'X', 'O', 'X', 'X']]
        game_upleft_diagonals.instance_variable_set(:@board, current_board)
      end

      it 'returns false' do
        result = game_upleft_diagonals.check_upleft_diagonals
        expect(result[:is]).to be false
      end
    end

    context 'no cell has been filled yet' do
      it 'returns false' do
        result = game_upleft_diagonals.check_upleft_diagonals
        expect(result[:is]).to be false
      end
    end
  end

  describe '#winner?' do
    subject(:game_winner) { described_class.new }

    context 'no cell has been filled yet' do
      it 'returns false' do
        result = game_winner.winner?
        expect(result[:is]).to be false
      end
    end

    context 'some columns have been filled, but in no direction are there 4 symbols in a row' do
      before do
        current_board = Array.new(6) do |row|
          next [' ', ' ', ' ', 'O', 'O', 'X', 'O'] if row == 4
          next [' ', 'O', 'O', 'O', 'X', 'O', 'O'] if row == 5

          Array.new(7) { ' ' }
        end
        game_winner.instance_variable_set(:@board, current_board)
      end

      it 'returns false' do
        result = game_winner.winner?
        expect(result[:is]).to be false
      end
    end

    context 'fifth row has 4 identical symbols in a row' do
      before do
        current_board = Array.new(6) do |row|
          next [' ', ' ', ' ', 'O', 'O', 'O', 'O'] if row == 4
          next [' ', 'O', 'O', 'O', 'X', 'O', 'O'] if row == 5

          Array.new(7) { ' ' }
        end
        game_winner.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_winner.winner?
        expect(result[:is]).to be true
      end

      it 'returns type of win(row)' do
        result = game_winner.winner?
        expect(result[:type]).to eq('row')
      end
    end

    context 'fifth column has 4 identical symbols in a row' do
      before do
        current_board = Array.new(6) do
          Array.new(7) { |column| column == 3 ? '4' : ' ' }
        end
        game_winner.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_winner.winner?
        expect(result[:is]).to be true
      end

      it 'returns type of win(column)' do
        result = game_winner.winner?
        expect(result[:type]).to eq('column')
      end
    end

    context 'up right diagonal has 4 identical symbols in a row' do
      before do
        current_board = [[' ', ' ', ' ', 'O', ' ', 'O', 'O'],
                         [' ', ' ', 'O', ' ', 'O', 'X', ' '],
                         [' ', 'X', 'X', 'O', 'X', 'O', ' '],
                         ['O', 'O', 'O', 'X', 'O', 'O', 'X'],
                         ['O', 'X', 'O', 'X', 'O', 'X', 'X'],
                         ['X', 'O', 'O', 'X', 'O', 'X', 'X']]
        game_winner.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_winner.winner?
        expect(result[:is]).to be true
      end

      it 'returns type of win(column)' do
        result = game_winner.winner?
        expect(result[:type]).to eq('up right diagonal')
      end
    end

    context 'up left diagonal has 4 identical symbols in a row' do
      before do
        current_board = [[' ', ' ', ' ', 'O', ' ', 'O', 'O'],
                         [' ', ' ', 'O', ' ', 'O', 'X', ' '],
                         [' ', 'X', 'X', 'O', 'X', 'O', ' '],
                         ['O', 'O', 'O', 'X', 'O', 'O', 'X'],
                         ['O', 'X', 'O', 'X', 'O', 'X', 'X'],
                         ['X', 'O', 'O', 'X', 'O', 'X', 'X']]
        game_winner.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_winner.winner?
        expect(result[:is]).to be true
      end

      it 'returns type of win(column)' do
        result = game_winner.winner?
        expect(result[:type]).to eq('up right diagonal')
      end
    end
  end

  describe '#tie?' do
    subject(:game_tie) { described_class.new }
    context 'board is full and none won' do
      before do
        current_board = Array.new(6) { Array.new(7) { %w[X O].sample } }
        game_tie.instance_variable_set(:@board, current_board)
      end

      it 'returns true' do
        result = game_tie.tie?
        expect(result).to be true
      end
    end

    context 'board is partially full' do
      before do
        current_board = [[' ', ' ', ' ', 'O', ' ', 'O', 'O'],
                         [' ', ' ', 'O', ' ', 'O', 'X', ' '],
                         [' ', 'X', 'X', 'O', 'X', 'O', ' '],
                         ['O', 'O', 'O', 'X', 'O', 'O', 'X'],
                         ['O', 'X', 'O', 'X', 'O', 'X', 'X'],
                         ['X', 'O', 'O', 'X', 'O', 'X', 'X']]
        game_tie.instance_variable_set(:@board, current_board)
      end

      it 'returns false' do
        result = game_tie.tie?
        expect(result).to be false
      end
    end
  end
end
