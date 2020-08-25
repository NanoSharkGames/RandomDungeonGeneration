for (xx = 0; xx < dungeonWidth; xx += 1) {
	for (yy = 0; yy < dungeonHeight; yy += 1) {
		
		text = "";
		
		switch (dungeon[# xx, yy]) {
			case ROOM:
				text = "ROOM";
				break;
			case HALLWAY:
				text = "HALL";
				break;
		}
		
		draw_text(xx * CELL_SIZE + 32, yy * CELL_SIZE + 32, text);
	}
}