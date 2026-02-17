// ================= MAP VIEW MODULE =================
// Fetches + renders tile_map into an arbitrary rectangle
// ===================================================

class MapView {

  // ---------- DATA ----------
  class Line {
    float x1, y1, x2, y2;
  }

  ArrayList<Line> walls = new ArrayList<Line>();
  ArrayList<PVector> outline = new ArrayList<PVector>();
  PVector dockPos = null;

  // ---------- TRANSFORM ----------
  float scale;
  float offX, offY;

  boolean loaded = false;
  int mapId;
  String baseUrl;

  // ---------- CONSTRUCTOR ----------
  MapView(String baseUrl, int mapId) {
    this.baseUrl = baseUrl;
    this.mapId = mapId;
    load();
  }

  // ---------- LOAD TILE MAP ----------
  void load() {
    try {
      String url = baseUrl + "/get/tile_map?map_id=" + mapId;
      JSONObject root = parseJSONObject(join(loadStrings(url), ""));

      JSONObject map = root.getJSONObject("map");

      // Walls
      walls.clear();
      JSONArray lines = map.getJSONArray("lines");
      for (int i = 0; i < lines.size(); i++) {
        JSONObject l = lines.getJSONObject(i);
        Line ln = new Line();
        ln.x1 = l.getFloat("x1");
        ln.y1 = l.getFloat("y1");
        ln.x2 = l.getFloat("x2");
        ln.y2 = l.getFloat("y2");
        walls.add(ln);
      }

      // Outline
      outline.clear();
      JSONArray ol = root.getJSONArray("outline");
      for (int i = 0; i < ol.size(); i++) {
        JSONObject p = ol.getJSONObject(i);
        outline.add(new PVector(p.getFloat("x"), p.getFloat("y")));
      }

      // Dock
      JSONObject dock = map.getJSONObject("docking_pose");
      if (dock.getBoolean("valid")) {
        dockPos = new PVector(dock.getFloat("x"), dock.getFloat("y"));
      }

      loaded = true;
    } catch (Exception e) {
      println("Map load failed:");
      e.printStackTrace();
    }
  }

  // ---------- DRAW ENTRY POINT ----------
  // Call THIS from your main draw()
  void draw(float x, float y, float w, float h) {
    if (!loaded) return;

    pushMatrix();
    clip((int)x, (int)y, (int)w, (int)h);
    computeTransform(x, y, w, h);
    render();
    noClip();
    popMatrix();
  }

  // ---------- TRANSFORM ----------
  void computeTransform(float x, float y, float w, float h) {

    float minX = 1e9, minY = 1e9;
    float maxX = -1e9, maxY = -1e9;

    for (PVector p : outline) {
      minX = min(minX, p.x);
      minY = min(minY, p.y);
      maxX = max(maxX, p.x);
      maxY = max(maxY, p.y);
    }

    float mapW = maxX - minX;
    float mapH = maxY - minY;

    scale = min(w / mapW, h / mapH) * 0.95;

    offX = x + w/2 - (minX + mapW/2) * scale;
    offY = y + h/2 + (minY + mapH/2) * scale;
  }

  // ---------- COORD TRANSFORM ----------
  float sx(float wx) { return wx * scale + offX; }
  float sy(float wy) { return -wy * scale + offY; }

  // ---------- RENDER ----------
  void render() {

    // Outline
    fill(35);
    stroke(80);
    strokeWeight(2);
    beginShape();
    for (PVector p : outline)
      vertex(sx(p.x), sy(p.y));
    endShape(CLOSE);

    // Walls
    stroke(230);
    strokeWeight(3);
    for (Line l : walls)
      line(sx(l.x1), sy(l.y1), sx(l.x2), sy(l.y2));

    // Dock
    if (dockPos != null) {
      noStroke();
      fill(0, 200, 0);
      ellipse(sx(dockPos.x), sy(dockPos.y), 14, 14);
    }
  }
}
