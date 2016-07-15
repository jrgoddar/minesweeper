require_relative "tile"
require 'byebug'
require 'colorize'

class Board
  attr_reader :size
  INPUT_VAL_MAP = {"r": :revealed, "f": :flagged, "u": :hidden}
  ADJACENT_MOVES = [[1,0],[0,1], [-1, 0], [0, -1], [1,1], [1, -1], [-1, 1], [-1, -1]]

  def initialize(size = 9, bombs = 10)
    @size = size
    @num_bombs = bombs
    @grid = Array.new(size){Array.new(size)}
    randomly_seed
    @tiles_to_reveal = {}
  end


  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

  def update_tile(pos, val)
    if val == "r"
      return if flagged?(pos)
      update_board(pos)
    else
      self[pos].status = INPUT_VAL_MAP[val.to_sym]
    end
  end

  def render_end(won)
    puts "  #{(0...@size).to_a.join(" ")}"

    @grid.each_with_index do |row, row_num|
      print "#{row_num}"
      row.each do |tile|
        if tile.bomb?
          color = won ? :white : :red
          print " B".colorize(color)
        else
          print " #{tile.to_s}"
        end
      end
      puts
    end
  end

  def render
    puts "  #{(1..@size).to_a.join(" ")}"

    @grid.each_with_index do |row, row_num|
      print "#{row_num+1} "
      print row.map{|tile| tile.to_s}.join(" ")
      puts
    end
  end

  def tile_status(pos)
    self[pos].status
  end

  def won?
    @grid.each do |row|
      return false if row.any?{|tile| !tile.bomb? && tile.status != :revealed}
    end

    true
  end

  def lost?
    @grid.each do |row|
      return true if row.any?{|tile| tile.bomb? && tile.status == :revealed}
    end

    false
  end

  private

  def flagged?(pos)
    if self[pos].status == :flagged
      puts "You can't reveal a flagged mine!"
      sleep(1)
      return true
    end
    false
  end

  def reveal_tiles
    @tiles_to_reveal.each do |pos, bombs|
      self[pos].status = :revealed
      self[pos].fringe_value = bombs if bombs > 0
    end
  end

  def update_board(pos)
    @tiles_to_reveal = {}
    explore_tile(pos)
    reveal_tiles
  end

  def explore_tile(pos)
    return if self[pos].status == :revealed || @tiles_to_reveal.keys.include?(pos)

    adjacent_tiles = get_adjacent(pos)
    surrounding_bombs = adjacent_tiles.select{|pos| self[pos].bomb?}.size
    @tiles_to_reveal[pos] = surrounding_bombs

    return if surrounding_bombs > 0

    to_explore = adjacent_tiles.select do |tile|
      !self[tile].bomb? && self[tile].status != :revealed
    end

    to_explore.each{|pos| explore_tile(pos)}
  end


  def get_adjacent(pos)
    adjacent_positions = []

    ADJACENT_MOVES.each do |change|
      d_row, d_col = change
      adjacent_positions << [pos[0] + d_row, pos[1] + d_col]
    end

    adjacent_positions.select do |pos|
      x, y = pos
      x.between?(0, @size-1) && y.between?(0, @size-1)
    end
  end

  def randomly_seed
    bombs = bomb_positions

    (0...@size).each do |row|
      (0...@size).each do |col|
        if bombs.include?([row,col])
          self[[row, col]] = Tile.new(true)
        else
          self[[row, col]] = Tile.new(false)
        end
      end
    end

  end

  def bomb_positions
    all_positions = []
    (0...@size).each do |row|
      (0...@size).each do |col|
        all_positions << [row,col]
      end
    end

    all_positions.shuffle.take(@num_bombs)
  end


end
