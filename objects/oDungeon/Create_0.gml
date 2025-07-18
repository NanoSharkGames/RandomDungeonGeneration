var _dungeon_width = floor(room_width / CELL_SIZE);
var _dungeon_height = floor(room_height / CELL_SIZE);
dungeon = ds_grid_create(_dungeon_width, _dungeon_height);

rooms = [];

// Room size ranges
room_width_min = 10;
room_width_max = 12;
room_height_min = 10;
room_height_max = 12;

// Hallway size ranges
hallway_length_min = 3;
hallway_length_max = 8;
hallway_width_min = 2;
hallway_width_max = 3;

room_to_extend_from = undefined;

// 1 in n chance to choose a random room to branch from
branch_odds = 4;

failed_iterations = 0;

// Number of consecutive failed iterations before quitting generation
iteration_max = 50;

generate_new_dungeon = function() {
	
	// Reset dungeon data
	failed_iterations = 0;
	array_resize(rooms, 0);
	tilemap_clear(layer_tilemap_get_id(layer_get_id("Tiles")), 0);
	
	var _dungeon_width = ds_grid_width(dungeon);
	var _dungeon_height = ds_grid_height(dungeon);
	
	// Fill the whole dungeon with walls to start
	ds_grid_set_region(dungeon, 0, 0, _dungeon_width - 1, _dungeon_height - 1, CELL_TYPES.WALL);
	
	while (failed_iterations < iteration_max) {
		
		var _room_width = irandom_range(room_width_min, room_width_max);
		var _room_height = irandom_range(room_height_min, room_height_max);
		var _room_count = array_length(rooms);
		
		if (_room_count > 0) {
			
			var _directions = [DIRECTIONS.WEST, DIRECTIONS.EAST, DIRECTIONS.NORTH, DIRECTIONS.SOUTH];
			var _direction_count = array_length(_directions);
			_directions = array_shuffle(_directions);
	
			repeat (_direction_count) {
				
				var _direction = array_pop(_directions);
				
				// Generate a random hallway length and width
				var _hallway_length = irandom_range(hallway_length_min, hallway_length_max);
				var _hallway_width = irandom_range(hallway_width_min, hallway_width_max);
			
				// Calculate the top left corner of the new room based on distance and direction
				
				var _room_x_1, _room_y_1;
				
				switch (_direction) {
					case DIRECTIONS.WEST:
						_room_x_1 = room_to_extend_from.x1 - _hallway_length - _room_width;
						_room_y_1 = irandom_range(room_to_extend_from.y1 - _room_height + _hallway_width, room_to_extend_from.y2 - (_hallway_width - 1));
						break;
					case DIRECTIONS.EAST:
						_room_x_1 = room_to_extend_from.x2 + _hallway_length + 1;
						_room_y_1 = irandom_range(room_to_extend_from.y1 - _room_height + _hallway_width, room_to_extend_from.y2 - (_hallway_width - 1));
						break;
					case DIRECTIONS.NORTH:
						_room_x_1 = irandom_range(room_to_extend_from.x1 - _room_width + _hallway_width, room_to_extend_from.x2 - (_hallway_width - 1));
						_room_y_1 = room_to_extend_from.y1 - _hallway_length - _room_height;
						break;
					case DIRECTIONS.SOUTH:
						_room_x_1 = irandom_range(room_to_extend_from.x1 - _room_width + _hallway_width, room_to_extend_from.x2 - (_hallway_width - 1));
						_room_y_1 = room_to_extend_from.y2 + _hallway_length + 1;
						break;
				}
			
				// Calculate the bottom right corner of the new room.
				var _room_x_2 = _room_x_1 + _room_width - 1;
				var _room_y_2 = _room_y_1 + _room_height - 1;
				
				// Skip this direction if new room is out of bounds
				if (_room_x_1 <= 0 || _room_x_1 >= _dungeon_width - 2 - _room_width || _room_y_1 <= 0 || _room_y_1 >= _dungeon_height - 2 - _room_height) {
					continue;
				}
				
				// Connect the new room and previous room with a hallway, and calculate the hallway's four corners
			
				var _hallway_x_1, _hallway_x_2, _hallway_y_1, _hallway_y_2;
				var _min_hallway_range, _max_hallway_range;
			
				switch (_direction) {
					
					case DIRECTIONS.WEST:
					
						_hallway_x_1 = _room_x_2 + 1;
						_hallway_x_2 = _hallway_x_1 + _hallway_length - 1;
                 
						if (_room_y_1 < room_to_extend_from.y1) {
							_min_hallway_range = room_to_extend_from.y1;
						}
						else {
							_min_hallway_range = _room_y_1;
						}
                 
						if (_room_y_2 > room_to_extend_from.y2) {
							_max_hallway_range = room_to_extend_from.y2 - (_hallway_width - 1);
						}
						else {
							_max_hallway_range = _room_y_2 - (_hallway_width - 1);
						}
                 
						_hallway_y_1 = _min_hallway_range + round(abs(_max_hallway_range - _min_hallway_range) / 2);
						_hallway_y_2 = _hallway_y_1 + (_hallway_width - 1);
						
						break;
						
					case DIRECTIONS.EAST:
					
						_hallway_x_1 = _room_x_1 - _hallway_length;
						_hallway_x_2 = _hallway_x_1 + _hallway_length - 1;
                 
						if (_room_y_1 < room_to_extend_from.y1) {
							_min_hallway_range = room_to_extend_from.y1;
						}
						else {
							_min_hallway_range = _room_y_1;
						}
                 
						if (_room_y_2 > room_to_extend_from.y2) {
							_max_hallway_range = room_to_extend_from.y2 - (_hallway_width - 1);
						}
						else {
							_max_hallway_range = _room_y_2 - (_hallway_width - 1);
						}
                 
						_hallway_y_1 = _min_hallway_range + round(abs(_max_hallway_range - _min_hallway_range) / 2);
						_hallway_y_2 = _hallway_y_1 + (_hallway_width - 1);
						break;
						
					case DIRECTIONS.NORTH:
					
						if (_room_x_1 < room_to_extend_from.x1) {
							_min_hallway_range = room_to_extend_from.x1;
						}
						else {
							_min_hallway_range = _room_x_1;
						}
                 
						if (_room_x_2 > room_to_extend_from.x2) {
							_max_hallway_range = room_to_extend_from.x2 - (_hallway_width - 1);
						}
						else {
							_max_hallway_range = _room_x_2 - (_hallway_width - 1);
						}
                 
						_hallway_x_1 = _min_hallway_range + round(abs(_max_hallway_range - _min_hallway_range) / 2);
						_hallway_x_2 = _hallway_x_1 + (_hallway_width - 1);
						_hallway_y_1 = _room_y_2 + 1;
						_hallway_y_2 = _hallway_y_1 + _hallway_length - 1;
						
						break;
						
					case DIRECTIONS.SOUTH:
					
						if (_room_x_1 < room_to_extend_from.x1) {
							_min_hallway_range = room_to_extend_from.x1;
						}
						else {
							_min_hallway_range = _room_x_1;
						}
                 
						if (_room_x_2 > room_to_extend_from.x2) {
							_max_hallway_range = room_to_extend_from.x2 - (_hallway_width - 1);
						}
						else {
							_max_hallway_range = _room_x_2 - (_hallway_width - 1);
						}
                 
						_hallway_x_1 = _min_hallway_range + round(abs(_max_hallway_range - _min_hallway_range) / 2);
						_hallway_x_2 = _hallway_x_1 + (_hallway_width - 1);
						_hallway_y_1 = _room_y_1 - _hallway_length;
						_hallway_y_2 = _hallway_y_1 + _hallway_length - 1;
						
						break;
				}
			
				var _is_touching = false;
			
				// Check if the hallway is touching a non-wall space
				
				for (var _x = _room_x_1 - 1; _x <= _room_x_2 + 1; _x++) {
					for (var _y = _room_y_1 - 1; _y <= _room_y_2 + 1; _y++) {
					    if (dungeon[# _x, _y] != CELL_TYPES.WALL) {
					        _is_touching = true;
							break;
					    }
					}
					if (_is_touching) {
						break;
					}
				}
				
				if (!_is_touching) {
					
					// Check if the hallway is touching another room
				
					for (var _x = _hallway_x_1 - 1; _x <= _hallway_x_2 + 1; _x++) {
						for (var _y = _hallway_y_1 - 1; _y <= _hallway_y_2 + 1; _y++) {
						    if (_x < room_to_extend_from.x1 || _x > room_to_extend_from.x2 || _y < room_to_extend_from.y1 || _y > room_to_extend_from.y2) {
						        if (dungeon[# _x, _y] == CELL_TYPES.ROOM) {
						            _is_touching = true;
									break;
						        }
						    }
						}
						if (_is_touching) {
							break;
						}
					}
					
					if (!_is_touching) {
					
						room_to_extend_from = create_room(_room_x_1, _room_y_1, _room_x_2, _room_y_2);
						create_hallway(_hallway_x_1, _hallway_y_1, _hallway_x_2, _hallway_y_2);
						
						_room_count++;
						
						// Reset failed iterations
						failed_iterations = -1;
						
						break;
					}
				}
			}
			
			failed_iterations++;
			
		    if (random(branch_odds) < 1) {
				var _random_room_index = irandom(_room_count - 1);
		        room_to_extend_from = rooms[_random_room_index];
			}
		}
		else {
			
			// Position the room in a random location within bounds of the dungeon
			var _room_x_1 = irandom(_dungeon_width - _room_width) + 1;
			var _room_y_1 = irandom(_dungeon_height - _room_height) + 1;
			var _room_x_2 = _room_x_1 + _room_width - 1;
			var _room_y_2 = _room_y_1 + _room_height - 1;
	
			room_to_extend_from = create_room(_room_x_1, _room_y_1, _room_x_2, _room_y_2);
		}
	}

	for (var _x = 0; _x < _dungeon_width; _x++) {
		for (var _y = 0; _y < _dungeon_height; _y++) {
			var _cell = dungeon[# _x, _y];
			
			var _tile_index = 0;
		
			if (_cell == CELL_TYPES.ROOM) {
				_tile_index = 1;
			}
			else if (_cell == CELL_TYPES.HALLWAY) {
				_tile_index = 2;
			}
			
			tilemap_set(layer_tilemap_get_id(layer_get_id("Tiles")), _tile_index, _x, _y);
		}
	}
}

create_room = function(_x1, _y1, _x2, _y2) {
	var _new_room = new DungeonRoom(_x1, _y1, _x2, _y2);
	array_push(rooms, _new_room);
	ds_grid_set_region(dungeon, _x1, _y1, _x2, _y2, CELL_TYPES.ROOM);
	return _new_room;
}

create_hallway = function(_x1, _y1, _x2, _y2) {
	ds_grid_set_region(dungeon, _x1, _y1, _x2, _y2, CELL_TYPES.HALLWAY);
}

generate_new_dungeon();