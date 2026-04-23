// ================= MAP VIEW MODULE =================
// Processing-side recreation of the original app's map stack:
// 1) map background polygon
// 2) tile / feature lines
// 3) areas and labels drawn by AreasView
// 4) robot / cleaning overlays drawn elsewhere
// ===================================================

class MapView {

  class Line {
    float x1, y1, x2, y2;
  }

  ArrayList<Line> walls = new ArrayList<Line>();
  ArrayList<PVector> outline = new ArrayList<PVector>();
  PVector dockPos = null;

  float scale = 1;
  float offX = 0;
  float offY = 0;

  float viewX = 0;
  float viewY = 0;
  float viewW = 0;
  float viewH = 0;

  float minX = 0;
  float minY = 0;
  float maxX = 1;
  float maxY = 1;

  boolean loaded = false;
  int mapId;
  String baseUrl;

  MapView(String baseUrl, int mapId) {
    this.baseUrl = baseUrl;
    this.mapId = mapId;
    load();
  }

  void load() {
    try {
      String url = baseUrl + "/get/tile_map?map_id=" + mapId;
      JSONObject root = parseJSONObject(join(loadStrings(url), ""));
      JSONObject map = root.getJSONObject("map");

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

      outline.clear();
      JSONArray ol = root.getJSONArray("outline");
      for (int i = 0; i < ol.size(); i++) {
        JSONObject p = ol.getJSONObject(i);
        outline.add(new PVector(p.getFloat("x"), p.getFloat("y")));
      }

      dockPos = null;
      if (map.hasKey("docking_pose")) {
        JSONObject dock = map.getJSONObject("docking_pose");
        if (dock.getBoolean("valid")) {
          dockPos = new PVector(dock.getFloat("x"), dock.getFloat("y"));
        }
      }

      updateBounds();
      loaded = true;
    }
    catch (Exception e) {
      println("Map load failed:");
      e.printStackTrace();
      loaded = false;
    }
  }

  void draw(float x, float y, float w, float h) {
    if (!loaded) return;

    viewX = x;
    viewY = y;
    viewW = w;
    viewH = h;

    computeTransform(x, y, w, h);
    render();
  }

  void updateBounds() {
    minX = 1e9;
    minY = 1e9;
    maxX = -1e9;
    maxY = -1e9;

    for (PVector p : outline) {
      includePoint(p.x, p.y);
    }

    for (Line l : walls) {
      includePoint(l.x1, l.y1);
      includePoint(l.x2, l.y2);
    }

    if (dockPos != null) {
      includePoint(dockPos.x, dockPos.y);
    }

    if (minX > maxX || minY > maxY) {
      minX = 0;
      minY = 0;
      maxX = 1;
      maxY = 1;
    }

    if (abs(maxX - minX) < 1) {
      maxX += 0.5;
      minX -= 0.5;
    }
    if (abs(maxY - minY) < 1) {
      maxY += 0.5;
      minY -= 0.5;
    }
  }

  void includePoint(float x, float y) {
    minX = min(minX, x);
    minY = min(minY, y);
    maxX = max(maxX, x);
    maxY = max(maxY, y);
  }

  void computeTransform(float x, float y, float w, float h) {
    float mapW = max(1, maxX - minX);
    float mapH = max(1, maxY - minY);

    float pad = 0.08;
    float usableW = max(1, w * (1.0 - pad * 2.0));
    float usableH = max(1, h * (1.0 - pad * 2.0));

    scale = min(usableW / mapW, usableH / mapH);

    float centerX = (minX + maxX) * 0.5;
    float centerY = (minY + maxY) * 0.5;

    offX = x + w * 0.5 - centerX * scale;
    offY = y + h * 0.5 + centerY * scale;
  }

  float sx(float wx) {
    return wx * scale + offX;
  }

  float sy(float wy) {
    return -wy * scale + offY;
  }

  float worldStroke(float px) {
    return max(1.0, px * max(0.65, scale / 55.0));
  }

  void render() {
    pushStyle();

    noStroke();
    fill(12, 15, 20);
    rect(viewX, viewY, viewW, viewH);

    drawTileBackground();
    drawTileWalls();
    drawOutline();
    drawDock();

    popStyle();
  }

  void drawTileBackground() {
    if (outline.size() < 3) return;

    noStroke();
    fill(42, 47, 56);
    beginShape();
    for (PVector p : outline) {
      vertex(sx(p.x), sy(p.y));
    }
    endShape(CLOSE);
  }

  void drawTileWalls() {
    if (walls.isEmpty()) return;

    stroke(230, 233, 238);
    strokeWeight(worldStroke(3.0));
    strokeCap(ROUND);

    for (Line l : walls) {
      line(sx(l.x1), sy(l.y1), sx(l.x2), sy(l.y2));
    }
  }

  void drawOutline() {
    if (outline.size() < 2) return;

    noFill();
    stroke(120, 130, 146, 180);
    strokeWeight(worldStroke(1.5));
    strokeJoin(ROUND);

    beginShape();
    for (PVector p : outline) {
      vertex(sx(p.x), sy(p.y));
    }
    endShape(CLOSE);
  }

  void drawDock() {
    if (dockPos == null) return;

    float x = sx(dockPos.x);
    float y = sy(dockPos.y);
    float outer = max(12, worldStroke(12));
    float inner = outer * 0.52;

    noStroke();
    fill(22, 29, 36, 220);
    ellipse(x, y, outer, outer);

    fill(84, 214, 136);
    ellipse(x, y, inner, inner);
  }
}
