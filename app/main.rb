require_relative "board.rb"
MOVEMENT_COOLDOWN_TIME = 5

def tick args
  if args.state.game_over
    args.state.movement_cooldown_timer = nil
    args.state.board_state = nil
    args.state.movement_direction = nil

    args.state.food_location = nil
    args.state.snake_body_locations = nil

    restart_button = {
      x: (args.grid.w / 2) - 75,
      y: (args.grid.h / 2) + 25,
      w: 150,
      h: 50,
      path: "sprites/restart_button.png"
    }

    args.outputs.labels << {
      x: (args.grid.w / 2) - 75 + 25,
      y: (args.grid.h / 2) + 25 + 100,
      text: "Score: #{args.state.score}"
    }
  
    args.outputs.labels << {
      x: 100,
      y: 200,
      text: "Game Over"
    }

    if args.inputs.mouse.click
      if args.inputs.mouse.inside_rect?(restart_button)
        args.state.score = 0
        args.state.game_over = false
      end
    end

    args.outputs.sprites << restart_button
  else
    args.state.score ||= 0
    args.state.movement_cooldown_timer ||= MOVEMENT_COOLDOWN_TIME
    args.state.board_state ||= Board.initial_board_state(20)
    args.state.movement_direction ||= nil

    args.state.food_location ||= Board.generate_food_location(args.state.board_state)
    args.state.snake_body_locations ||= Board.generate_initial_snake_body_locations

    board = Board.new(args.state.board_state, args.state.food_location, args.state.snake_body_locations)

    if args.state.movement_direction != nil
      if args.state.movement_cooldown_timer > 0
        args.state.movement_cooldown_timer -= 1
      else
        valid_move = board.send("move_#{args.state.movement_direction}")
        if valid_move == false
          args.state.game_over = true
        end
        args.state.movement_cooldown_timer = MOVEMENT_COOLDOWN_TIME
      end
    end

    if args.inputs.up && args.state.movement_direction != "down"
      args.state.movement_direction = "up"
    end

    if args.inputs.down && args.state.movement_direction != "up"
      args.state.movement_direction = "down"
    end

    if args.inputs.left && args.state.movement_direction != "right"
      args.state.movement_direction = "left"
    end

    if args.inputs.right && args.state.movement_direction != "left"
      args.state.movement_direction = "right"
    end

    args.outputs.sprites << board.generate_board

    if board.check_player_food_collission
      board.add_body_segment(args.state.movement_direction)
      args.state.food_location = nil
      args.state.score = args.state.score + 1
    end

    args.outputs.labels << {
      x: 100,
      y: 220,
      text: args.state.score
    }

    args.state.board_state = board.board_state
    args.state.snake_body_locations = board.snake_body
  end
end

$gtk.reset
