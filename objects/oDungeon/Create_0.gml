var _dungeonWidth = floor(room_width / CELL_SIZE);
var _dungeonHeight = floor(room_height / CELL_SIZE);
dungeon = ds_grid_create(_dungeonWidth, _dungeonHeight);

rooms = [];

// Room size ranges
roomWidthMin = 10;
roomWidthMax = 12;
roomHeightMin = 10;
roomHeightMax = 12;

// Hallway size ranges
hallwayLengthMin = 3;
hallwayLengthMax = 8;
hallwayWidthMin = 2;
hallwayWidthMax = 3;

roomToExtendFrom = noone;

// 1 in n chance to choose a random room to branch from
branchOdds = 4;

failedIterations = 0;

// Number of consecutive failed iterations before quitting generation
iterationMax = 50;

GenerateNewDungeon = function() {
	
	// Reset dungeon data
	failedIterations = 0;
	array_resize(rooms, 0);
	tilemap_clear(layer_tilemap_get_id(layer_get_id("Tiles")), 0);
	
	var _dungeonWidth = ds_grid_width(dungeon);
	var _dungeonHeight = ds_grid_height(dungeon);
	
	// Fill the whole dungeon with walls to start
	ds_grid_set_region(dungeon, 0, 0, _dungeonWidth - 1, _dungeonHeight - 1, CELL_TYPES.WALL);
	
	while (failedIterations < iterationMax) {
		
		var _roomWidth = irandom_range(roomWidthMin, roomWidthMax);
		var _roomHeight = irandom_range(roomHeightMin, roomHeightMax);
		
		var _roomCount = array_length(rooms);
		if (_roomCount > 0) {
			
			var _directions = [DIRECTIONS.WEST, DIRECTIONS.EAST, DIRECTIONS.NORTH, DIRECTIONS.SOUTH];
			var _directionCount = array_length(_directions);
			array_shuffle(_directions);
	
			repeat (_directionCount) {
				
				var _direction = array_pop(_directions);
				
				// Generate a random hallway length and width
				var _hallwayLength = irandom_range(hallwayLengthMin, hallwayLengthMax);
				var _hallwayWidth = irandom_range(hallwayWidthMin, hallwayWidthMax);
		
				var _roomX1, _roomY1, _roomX2, _roomY2;
			
				// Calculate the top left corner of the new room based on distance and direction
				switch (_direction) {
					case DIRECTIONS.WEST:
						_roomX1 = roomToExtendFrom.x1 - _hallwayLength - _roomWidth;
						_roomY1 = irandom_range(roomToExtendFrom.y1 - _roomHeight + _hallwayWidth, roomToExtendFrom.y2 - (_hallwayWidth - 1));
						break;
					case DIRECTIONS.EAST:
						_roomX1 = roomToExtendFrom.x2 + _hallwayLength + 1;
						_roomY1 = irandom_range(roomToExtendFrom.y1 - _roomHeight + _hallwayWidth, roomToExtendFrom.y2 - (_hallwayWidth - 1));
						break;
					case DIRECTIONS.NORTH:
						_roomX1 = irandom_range(roomToExtendFrom.x1 - _roomWidth + _hallwayWidth, roomToExtendFrom.x2 - (_hallwayWidth - 1));
						_roomY1 = roomToExtendFrom.y1 - _hallwayLength - _roomHeight;
						break;
					case DIRECTIONS.SOUTH:
						_roomX1 = irandom_range(roomToExtendFrom.x1 - _roomWidth + _hallwayWidth, roomToExtendFrom.x2 - (_hallwayWidth - 1));
						_roomY1 = roomToExtendFrom.y2 + _hallwayLength + 1;
						break;
				}
			
				// Calculate the bottom right corner of the new room.
				_roomX2 = _roomX1 + _roomWidth - 1;
				_roomY2 = _roomY1 + _roomHeight - 1;
				
				// Skip this direction if new room is out of bounds
				if (_roomX1 <= 0 || _roomX1 >= _dungeonWidth - 2 - _roomWidth || _roomY1 <= 0 || _roomY1 >= _dungeonHeight - 2 - _roomHeight) {
					continue;
				}
			
				var _hallwayX1, _hallwayX2, _hallwayY1, _hallwayY2;
				var _minRange, _maxRange;
			
				// Connect the new room and previous room with a hallway, and calculate the hallway's four corners
				switch (_direction) {
					
					case DIRECTIONS.WEST:
					
						_hallwayX1 = _roomX2 + 1;
						_hallwayX2 = _hallwayX1 + _hallwayLength - 1;
                 
						if (_roomY1 < roomToExtendFrom.y1) {
							_minRange = roomToExtendFrom.y1;
						}
						else {
							_minRange = _roomY1;
						}
                 
						if (_roomY2 > roomToExtendFrom.y2) {
							_maxRange = roomToExtendFrom.y2 - (_hallwayWidth - 1);
						}
						else {
							_maxRange = _roomY2 - (_hallwayWidth - 1);
						}
                 
						_hallwayY1 = _minRange + round(abs(_maxRange - _minRange) / 2);
						_hallwayY2 = _hallwayY1 + (_hallwayWidth - 1);
						
						break;
						
					case DIRECTIONS.EAST:
					
						_hallwayX1 = _roomX1 - _hallwayLength;
						_hallwayX2 = _hallwayX1 + _hallwayLength - 1;
                 
						if (_roomY1 < roomToExtendFrom.y1) {
							_minRange = roomToExtendFrom.y1;
						}
						else {
							_minRange = _roomY1;
						}
                 
						if (_roomY2 > roomToExtendFrom.y2) {
							_maxRange = roomToExtendFrom.y2 - (_hallwayWidth - 1);
						}
						else {
							_maxRange = _roomY2 - (_hallwayWidth - 1);
						}
                 
						_hallwayY1 = _minRange + round(abs(_maxRange - _minRange) / 2);
						_hallwayY2 = _hallwayY1 + (_hallwayWidth - 1);
						break;
						
					case DIRECTIONS.NORTH:
					
						if (_roomX1 < roomToExtendFrom.x1) {
							_minRange = roomToExtendFrom.x1;
						}
						else {
							_minRange = _roomX1;
						}
                 
						if (_roomX2 > roomToExtendFrom.x2) {
							_maxRange = roomToExtendFrom.x2 - (_hallwayWidth - 1);
						}
						else {
							_maxRange = _roomX2 - (_hallwayWidth - 1);
						}
                 
						_hallwayX1 = _minRange + round(abs(_maxRange - _minRange) / 2);
						_hallwayX2 = _hallwayX1 + (_hallwayWidth - 1);
						_hallwayY1 = _roomY2 + 1;
						_hallwayY2 = _hallwayY1 + _hallwayLength - 1;
						
						break;
						
					case DIRECTIONS.SOUTH:
					
						if (_roomX1 < roomToExtendFrom.x1) {
							_minRange = roomToExtendFrom.x1;
						}
						else {
							_minRange = _roomX1;
						}
                 
						if (_roomX2 > roomToExtendFrom.x2) {
							_maxRange = roomToExtendFrom.x2 - (_hallwayWidth - 1);
						}
						else {
							_maxRange = _roomX2 - (_hallwayWidth - 1);
						}
                 
						_hallwayX1 = _minRange + round(abs(_maxRange - _minRange) / 2);
						_hallwayX2 = _hallwayX1 + (_hallwayWidth - 1);
						_hallwayY1 = _roomY1 - _hallwayLength;
						_hallwayY2 = _hallwayY1 + _hallwayLength - 1;
						
						break;
				}
			
				var _isTouching = false;
			
				// Check if the hallway is touching a non-wall space
				
				for (var xx = _roomX1 - 1; xx <= _roomX2 + 1; xx++) {
					for (var yy = _roomY1 - 1; yy <= _roomY2 + 1; yy++) {
					    if (dungeon[# xx, yy] != CELL_TYPES.WALL) {
					        _isTouching = true;
							break;
					    }
					}
					if (_isTouching) {
						break;
					}
				}
				
				if (!_isTouching) {
					
					// Check if the hallway is touching another room
				
					for (xx = _hallwayX1 - 1; xx <= _hallwayX2 + 1; xx++) {
						for (yy = _hallwayY1 - 1; yy <= _hallwayY2 + 1; yy++) {
						    if (xx < roomToExtendFrom.x1 || xx > roomToExtendFrom.x2 || yy < roomToExtendFrom.y1 || yy > roomToExtendFrom.y2) {
						        if (dungeon[# xx, yy] == CELL_TYPES.ROOM) {
						            _isTouching = true;
									break;
						        }
						    }
						}
						if (_isTouching) {
							break;
						}
					}
					
					if (!_isTouching) {
					
						roomToExtendFrom = CreateRoom(_roomX1, _roomY1, _roomX2, _roomY2);
						CreateHallway(_hallwayX1, _hallwayY1, _hallwayX2, _hallwayY2);
						
						// Reset failed iterations
						failedIterations = -1;
						
						break;
					}
				}
			}
			
			failedIterations++;
			
		    if (random(branchOdds) < 1) {
				var _randomRoomIndex = irandom(_roomCount - 1);
		        roomToExtendFrom = rooms[_randomRoomIndex];
			}
		}
		else {
			
			// Position the room in a random location within bounds of the dungeon
			var _roomX1 = irandom(_dungeonWidth - _roomWidth) + 1;
			var _roomY1 = irandom(_dungeonHeight - _roomHeight) + 1;
			var _roomX2 = _roomX1 + _roomWidth - 1;
			var _roomY2 = _roomY1 + _roomHeight - 1;
	
			roomToExtendFrom = CreateRoom(_roomX1, _roomY1, _roomX2, _roomY2);
		}
	}

	for (var xx = 0; xx < _dungeonWidth; xx++) {
		for (var yy = 0; yy < _dungeonHeight; yy++) {
			var _cell = dungeon[# xx, yy];
			
			var _tileInd = 0;
		
			if (_cell == CELL_TYPES.ROOM) {
				_tileInd = 1;
			}
			else if (_cell == CELL_TYPES.HALLWAY) {
				_tileInd = 2;
			}
			
			tilemap_set(layer_tilemap_get_id(layer_get_id("Tiles")), _tileInd, xx, yy);
		}
	}
}

CreateRoom = function(_x1, _y1, _x2, _y2) {
	var _newRoom = new DungeonRoom(_x1, _y1, _x2, _y2);
	array_push(rooms, _newRoom);
	ds_grid_set_region(dungeon, _x1, _y1, _x2, _y2, CELL_TYPES.ROOM);
	return _newRoom;
}

CreateHallway = function(_x1, _y1, _x2, _y2) {
	ds_grid_set_region(dungeon, _x1, _y1, _x2, _y2, CELL_TYPES.HALLWAY);
}

GenerateNewDungeon();