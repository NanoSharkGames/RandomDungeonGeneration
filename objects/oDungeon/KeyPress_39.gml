iterations = 0;
ds_list_clear(roomList);
tilemap_clear(layer_tilemap_get_id(layer_get_id("Tiles")), 0);

GenerateNewDungeon();