class CGMView {

  String baseUrl;
  int mapId;

  int sizeX, sizeY;
  float llx, lly;
  float resolution;
  int[] cleaned;
  boolean valid = false;

  CGMView(String baseUrl, int mapId) {
    this.baseUrl = baseUrl;
    this.mapId = mapId;
  }

  void update() {
    try {
      JSONObject j = parseJSONObject(
        join(loadStrings(baseUrl + "/get/cleaning_grid_map"), "")
      );

      if (j.getInt("map_id") != mapId) return;
      if (j.getInt("size_x") == 0 || j.getInt("size_y") == 0) return;

      sizeX = j.getInt("size_x");
      sizeY = j.getInt("size_y");
      llx = j.getFloat("lower_left_x");
      lly = j.getFloat("lower_left_y");
      resolution = j.getFloat("resolution");

      JSONArray arr = j.getJSONArray("cleaned");
      cleaned = new int[arr.size()];
      for (int i = 0; i < arr.size(); i++)
        cleaned[i] = arr.getInt(i);

      valid = true;
    } catch (Exception e) {
      println("CGM update failed");
    }
  }

  void draw(MapView map) {
    if (!valid) return;

    int idxBlock = 1;
    int cellCount = 0;
    boolean cleanedVal = cleaned[0] == 0;

    noStroke();
    fill(0, 120, 255, 80); // translucent blue

    for (int y = 0; y < sizeY; y++) {
      for (int x = 0; x < sizeX; x++) {

        if (++cellCount >= cleaned[idxBlock]) {
          idxBlock++;
          cleanedVal = !cleanedVal;
          cellCount = 0;
        }

        if (cleanedVal) {
          float wx = llx + x * resolution;
          float wy = lly + y * resolution;

          float sx = map.sx(wx);
          float sy = map.sy(wy);
          float s = resolution * map.scale;

          rect(sx, sy - s, s, s);
        }
      }
    }
  }
}
