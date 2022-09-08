# frozen_string_literal: true

# module for Connect Four
module ConnectFourTxt
  def introduction
    puts 'Welcome to my implementation of the Connect Four game!' \
    "\nDo you want to see the tutorial?"

    tutorial if yes?

    puts "\nSo.. shall we begin?"
    enter
  end

  def enter
    puts "\n>Press ENTER to continue<"
    gets.chomp
  end

  def tutorial
    puts "\nObject: Connect four of your checkers in a row while preventing your opponent" \
    "\nfrom doing the same. But, look out – your opponent can sneak up on you and win the game!" \
    "\nThe directions you can connect your checkers are: line, column or diagonal."
    puts "\nGameplay: Each turn, a player selects the column he wants his piece to fall on." \
    "\nAnd, of course, players can tie."
    "\nThat's it! Pretty simple, right?"
  end

  def yes?
    loop do
      puts "\n>Enter Y(yes)/N(no)<"
      answer = gets.chomp.strip.downcase
      return true if %w[y yes].include?(answer)

      return false if %w[n no].include?(answer)

      puts "\nSorry, '#{answer}' is not a valid answer. Try again."
    end
  end
end
