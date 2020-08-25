#macro CELL_SIZE 64

#macro VOID -5
#macro ROOM -6
#macro HALLWAY -7

#macro NORTH 1
#macro WEST 2
#macro EAST 4
#macro SOUTH 8

randomize();

dungeonWidth = room_width / CELL_SIZE;
dungeonHeight = room_height / CELL_SIZE;

dungeon = ds_grid_create(dungeonWidth, dungeonHeight);

ds_grid_set_region(dungeon, 0, 0, dungeonWidth - 1, dungeonHeight - 1, VOID);

roomCount = 0;
roomMax = 6;

roomList = ds_list_create();

currentRoom = noone;

branchOdds = 4;

//Get first room's size.
roomWidth = irandom_range(4, 6);
roomHeight = irandom_range(4, 6);

//Position the room in a random location within bounds of the dungeon.
roomX1 = irandom_range(1, dungeonWidth - 1 - roomWidth);
roomY1 = irandom_range(1, dungeonHeight - 1 - roomHeight);
roomX2 = roomX1 + roomWidth - 1;
roomY2 = roomY1 + roomHeight - 1;

//Create first room.
with (instance_create_layer(roomX1 * CELL_SIZE, roomY1 * CELL_SIZE, "Rooms", objDungeonRoom)) {
    roomX1 = other.roomX1;
    roomX2 = other.roomX2;
    roomY1 = other.roomY1;
    roomY2 = other.roomY2;
 
    ds_list_add(other.roomList, id);
 
    other.currentRoom = id;
}

//Set the room's region within the grid.
ds_grid_set_region(dungeon, roomX1, roomY1, roomX2, roomY2, ROOM);

roomCount += 1;

iterations = 0;

//Generate new rooms and hallways until no more can be added within 50 iterations.
while (roomCount < roomMax && iterations < 50) {
         
    //Choose a cardinal direction relative to the current room.
    dir = choose(WEST, EAST, NORTH, SOUTH);

    //Get size of new room.
	roomWidth = irandom_range(15, 25);
	roomHeight = irandom_range(15, 25);

    hallwayLength = irandom_range(5, 12);
    hallwayWidth = choose(2, 3);

    //Calculate the top left corner of the new room based on hallway distance and direction.
    switch (dir) {
        case WEST:
            roomX1 = currentRoom.roomX1 - hallwayLength - roomWidth;
            roomY1 = irandom_range(currentRoom.roomY1 - roomHeight + hallwayWidth, currentRoom.roomY2 - (hallwayWidth - 1));
            break;
        case EAST:
            roomX1 = currentRoom.roomX2 + hallwayLength + 1;
            roomY1 = irandom_range(currentRoom.roomY1 - roomHeight + hallwayWidth, currentRoom.roomY2 - (hallwayWidth - 1));
            break;
        case NORTH:
            roomX1 = irandom_range(currentRoom.roomX1 - roomWidth + hallwayWidth, currentRoom.roomX2 - (hallwayWidth - 1));
            roomY1 = currentRoom.roomY1 - hallwayLength - roomHeight;
            break;
        case SOUTH:
            roomX1 = irandom_range(currentRoom.roomX1 - roomWidth + hallwayWidth, currentRoom.roomX2 - (hallwayWidth - 1));
            roomY1 = currentRoom.roomY2 + hallwayLength + 1;
            break;
    }

    //Calculate the bottom right corner of the new room.
    roomX2 = roomX1 + (roomWidth - 1);
    roomY2 = roomY1 + (roomHeight - 1);

    //If the room is within dungeon bounds.
    if (roomX1 > 0 && roomX1 < dungeonWidth - 2 - roomWidth && roomY1 > 0 && roomY1 < dungeonHeight - 2 - roomHeight) {
     
        //Connect the new room and previous room with a hallway.
        switch (dir) {
            case WEST:
                hallwayX1 = roomX2 + 1;
                hallwayX2 = hallwayX1 + hallwayLength - 1;
                 
                if (roomY1 < currentRoom.roomY1) {
                    minRange = currentRoom.roomY1;
                }
                else {
                    minRange = roomY1;
                }
                 
                if (roomY2 > currentRoom.roomY2) {
                    maxRange = currentRoom.roomY2 - (hallwayWidth - 1);
                }
                else {
                    maxRange = roomY2 - (hallwayWidth - 1);
                }
                 
                hallwayY1 = minRange + round(abs(maxRange - minRange) / 2);
                hallwayY2 = hallwayY1 + (hallwayWidth - 1);
                break;
            case EAST:
                hallwayX1 = roomX1 - hallwayLength;
                hallwayX2 = hallwayX1 + hallwayLength - 1;
                 
                if (roomY1 < currentRoom.roomY1) {
                    minRange = currentRoom.roomY1;
                }
                else {
                    minRange = roomY1;
                }
                 
                if (roomY2 > currentRoom.roomY2) {
                    maxRange = currentRoom.roomY2 - (hallwayWidth - 1);
                }
                else {
                    maxRange = roomY2 - (hallwayWidth - 1);
                }
                 
                hallwayY1 = minRange + round(abs(maxRange - minRange) / 2);
                hallwayY2 = hallwayY1 + (hallwayWidth - 1);
                break;
            case NORTH:
                if (roomX1 < currentRoom.roomX1) {
                    minRange = currentRoom.roomX1;
                }
                else {
                    minRange = roomX1;
                }
                 
                if (roomX2 > currentRoom.roomX2) {
                    maxRange = currentRoom.roomX2 - (hallwayWidth - 1);
                }
                else {
                    maxRange = roomX2 - (hallwayWidth - 1);
                }
                 
                hallwayX1 = minRange + round(abs(maxRange - minRange) / 2);
                 
                hallwayX2 = hallwayX1 + (hallwayWidth - 1);
                 
                hallwayY1 = roomY2 + 1;
                hallwayY2 = hallwayY1 + hallwayLength - 1;
                break;
            case SOUTH:
                if (roomX1 < currentRoom.roomX1) {
                    minRange = currentRoom.roomX1;
                }
                else {
                    minRange = roomX1;
                }
                 
                if (roomX2 > currentRoom.roomX2) {
                    maxRange = currentRoom.roomX2 - (hallwayWidth - 1);
                }
                else {
                    maxRange = roomX2 - (hallwayWidth - 1);
                }
                 
                hallwayX1 = minRange + round(abs(maxRange - minRange) / 2);
                 
                hallwayX2 = hallwayX1 + (hallwayWidth - 1);
                 
                hallwayY1 = roomY1 - hallwayLength;
                hallwayY2 = hallwayY1 + hallwayLength - 1;
                break;
        }

        //Check if the room is touching other rooms or hallways.
        isTouching = false;
        for (xx = roomX1 - 1; xx <= roomX2 + 1; xx += 1) {
            for (yy = roomY1 - 1; yy <= roomY2 + 1; yy += 1) {
                if (dungeon[# xx, yy] != VOID) {
                    isTouching = true;
                }
            }
        }
        //Check if the hallway is touching other rooms.
        for (xx = hallwayX1 - 1; xx <= hallwayX2 + 1; xx += 1) {
            for (yy = hallwayY1 - 1; yy <= hallwayY2 + 1; yy += 1) {
                if (xx < currentRoom.roomX1 || xx > currentRoom.roomX2 || yy < currentRoom.roomY1 || yy > currentRoom.roomY2) {
                    if (dungeon[# xx, yy] == ROOM) {
                        isTouching = true;
                    }
                }
            }
        }

        if (!isTouching) {
         
            //Create new room.
            with (instance_create_layer(roomX1 * CELL_SIZE, roomY1 * CELL_SIZE, "Rooms", objDungeonRoom)) {
                roomX1 = other.roomX1;
                roomX2 = other.roomX2;
                roomY1 = other.roomY1;
                roomY2 = other.roomY2;
             
                ds_list_add(other.roomList, id);
                other.currentRoom = id;
            }
         
            //Fill room and hallway.
            ds_grid_set_region(dungeon, roomX1, roomY1, roomX2, roomY2, ROOM);
            ds_grid_set_region(dungeon, hallwayX1, hallwayY1, hallwayX2, hallwayY2, HALLWAY);
         
            roomCount += 1;
         
            //Reset iterations.
            iterations = 0;
        }
        else {
            iterations += 1;
        }
    }
    else {
        iterations += 1;
    }

    if (irandom_range(1, branchOdds) == 1) {
        currentRoom = ds_list_find_value(roomList, irandom_range(0, ds_list_size(roomList) - 1));
    }
}