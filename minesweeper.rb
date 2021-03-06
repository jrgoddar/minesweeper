require_relative "tile"
require_relative "board"
require "yaml"

class MineSweeper
  def initialize(board)
    @board = board
  end

  def play

    until (won? || lost?)
      system("clear")
      show_board
      pos = get_pos
      val = get_val

      make_move(pos, val)
    end
  end


  private

  def show_board
    @board.render
  end

  def won?
    if @board.won?
      system("clear")
      puts "player wins!"
      @board.render_end(true)
    end
    @board.won?
  end

  def lost?
    if @board.lost?
      system("clear")
      @board.render_end(false)
      puts "Player loses!"
    end
    @board.lost?
  end

  def get_pos
    pos = nil

    until (pos && valid_pos?(pos))
      puts "Please enter a position (e.g. 1,3)"
      print ">"

      pos = parse_pos(STDIN.gets.chomp)
    end

    pos
  end

  def parse_pos(string)
    if string == "save"
      save_game
    else
      raw_pos = string.split(",").map(&:to_i)
      raw_pos.map{|n| n - 1}
    end
  end

  def valid_pos?(pos)
    valid = (
      pos.is_a?(Array) &&
      pos.size == 2 &&
      pos.all?{|el| el.is_a?(Integer) && el.between?(0, @board.size - 1)} &&
      @board.tile_status(pos) != :revealed
    )

    puts "Invalid position! Try again!" unless valid
    valid
  end

  def get_val
    val = nil

    until val && valid_val?(val) 
      puts "Would you like to reveal (r), flag (f), or unflag (u) the position?"
      print ">"

      val = STDIN.gets.chomp
    end

    val
  end

  def valid_val?(val)
    valid = val.size == 1 && ["r", "f", "u"].include?(val)
    puts "Invalid move! Try again!" unless valid
    valid
  end

  def make_move(pos, val)
    @board.update_tile(pos, val)
  end

  def save_game
    saved_board = @board.to_yaml
    File.open("saved_games/saved_game_#{Time.now.strftime("%H:%M")}.yml", 'w') do |f|
      f.write saved_board
    end

    puts "Game is saved"
  end

end


if $PROGRAM_NAME == __FILE__
  unless ARGV[0].nil?
    MineSweeper.new(YAML.load_file(ARGV[0].chomp)).play
  else
    MineSweeper.new(Board.new(9, 10)).play
  end

end
