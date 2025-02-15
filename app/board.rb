class Board
  attr_accessor :board_state, :player_x, :player_y, :food_location, :snake_body

  def self.initial_board_state(board_width_height)
    board = Array.new(board_width_height) { Array.new(board_width_height) }

    generate_initial_head_location(board)
  end

  def self.generate_initial_head_location(board)
    size = board.length

    head_y = Numeric.rand(0..size - 1)
    head_x = Numeric.rand(0..size - 1)

    board[head_y][head_x] = "head"
    board
  end

  def self.generate_food_location(board_state)
    self.generate_food(board_state)
  end

  def self.generate_initial_snake_body_locations
    []
  end

  def self.generate_food(board_state)
    board_height = board_state.length
    board_width = board_state[0].length

    food_location = [nil, nil]
    while food_location.first == nil
      food_y = Numeric.rand(0..board_height - 1)
      food_x = Numeric.rand(0..board_width - 1)

      if board_state[food_y][food_x] == nil
        food_location = [food_y, food_x]
      end
    end

    food_location
  end

  def initialize(board_state = nil, food_location, snake_body)
    # dup input array to prevent mutate the passed array
    @board_state = board_state.map(&:dup)
    @snake_body = snake_body
    @player_x, @player_y = find_player_x_y(board_state)
    @food_location = food_location.map(&:dup)
  end

  def check_player_food_collission
    @player_x == @food_location.second && @player_y == @food_location.first
  end

  def generate_board
    @board_state.each_with_index.map do |row, row_index|
      row.each_with_index.map do |tile, tile_index|
        tile_type = nil
        if row_index == @food_location.first && tile_index == @food_location.second
          tile_type = "sprites/food.png"
        elsif tile == "head" || tile == "body"
          tile_type = "sprites/player.png"
        else
          tile_type = "sprites/empty.png"
        end
        {
          x: ((1280 / 2) - ((25 * 20) /  2)) + (25 * tile_index),
          y: ((720 / 2) + ((25 * 20) / 2)) - (25 * row_index),
          h: 25,
          w: 25,
          path: tile_type
        }
      end
    end
  end

  def move_up
    return false if @player_y == 0
    return false if @board_state[@player_y - 1][@player_x] == "body"
    @board_state[@player_y][@player_x] = nil
    @board_state[@player_y - 1][@player_x] = "head"
    move_body(@player_y, @player_x)
  end

  def move_down
    return false if @player_y == 19
    return false if @board_state[@player_y + 1][@player_x] == "body"
    @board_state[@player_y][@player_x] = nil
    @board_state[@player_y + 1][@player_x] = "head"
    move_body(@player_y, @player_x)
  end

  def move_left
    return false if @player_x == 0
    return false if @board_state[@player_y][@player_x - 1] == "body"
    @board_state[@player_y][@player_x] = nil
    @board_state[@player_y][@player_x - 1] = "head"
    move_body(@player_y, @player_x)
  end

  def move_right
    return false if @player_x == 19
    return false if @board_state[@player_y][@player_x + 1] == "body"
    @board_state[@player_y][@player_x] = nil
    @board_state[@player_y][@player_x + 1] = "head"
    move_body(@player_y, @player_x)
  end

  def add_body_segment(movement_direction)
    last_y = nil
    last_x = nil
    if @snake_body.length == 0
      last_y = @player_y
      last_x = @player_x
    else
      last_y, last_x = @snake_body.last
    end
    if last_y - 1 >= 0 && @board_state[last_y - 1][last_x] == nil && movement_direction != "up"
      @snake_body << [last_y - 1,last_x]
      @board_state[last_y - 1][last_x] = "body"
    elsif last_y + 1 <= 19 && @board_state[last_y + 1][last_x] == nil && movement_direction != "down"
      @snake_body << [last_y + 1,last_x]
      @board_state[last_y + 1][last_x] = "body"
    elsif last_x - 1 >= 0 && @board_state[last_y][last_x - 1] == nil && movement_direction != "left"
      @snake_body << [last_y,last_x - 1]
      @board_state[last_y][last_x - 1] = "body"
    elsif last_x + 1 <= 19 && @board_state[last_y][last_x + 1] == nil && movement_direction != "right"
      @snake_body << [last_y,last_x + 1]
      @board_state[last_y][last_x + 1] = "body"
    end
  end

  private

  def move_body(player_y, player_x)
    previous_x = player_x
    previous_y = player_y
    @snake_body.each_with_index do |body_tile, tile_index|
      if tile_index == 0
        @board_state[body_tile[0]][body_tile[1]] = nil
        @board_state[player_y][player_x] = "body"
        @snake_body[tile_index] = [previous_y, previous_x]
        previous_x = body_tile[1]
        previous_y = body_tile[0]
      else
        @board_state[body_tile[0]][body_tile[1]] = nil
        @board_state[previous_y][previous_x] = "body"
        @snake_body[tile_index] = [previous_y, previous_x]
        previous_x = body_tile[1]
        previous_y = body_tile[0]
      end
    end
  end

  def find_player_x_y(board_state)
    x = nil
    y = nil
    board_state.each_with_index do |row, row_index|
      row.each_with_index do |tile, column_index|
        if tile == "head"
          x = column_index
          y = row_index
        end
      end
    end
    return [x, y]
  end
end

$gtk.reset
