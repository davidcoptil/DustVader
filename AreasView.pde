class AreasView {

  class Area {
    int id;
    ArrayList<PVector> pts = new ArrayList<PVector>();
    boolean selected = false; // NEW: track selection
  }

  ArrayList<Area> areas = new ArrayList<Area>();
  String baseUrl;
  int mapId;

  AreasView(String baseUrl, int mapId) {
    this.baseUrl = baseUrl;
    this.mapId = mapId;
    load();
  }

  void load() {
    try {
      String url = baseUrl + "/get/areas?map_id=" + mapId;
      JSONObject root = parseJSONObject(join(loadStrings(url), ""));
      JSONArray arr = root.getJSONArray("areas");

      areas.clear();
      for (int i = 0; i < arr.size(); i++) {
        JSONObject a = arr.getJSONObject(i);
        Area area = new Area();
        area.id = a.getInt("id");

        JSONArray pts = a.getJSONArray("points");
        for (int j = 0; j < pts.size(); j++) {
          JSONObject p = pts.getJSONObject(j);
          area.pts.add(new PVector(p.getFloat("x"), p.getFloat("y")));
        }
        areas.add(area);
      }
    } catch (Exception e) {
      println("Areas load failed");
      e.printStackTrace();
    }
  }

  void draw(MapView map) {
    for (Area a : areas) {
      drawArea(map, a);
    }
  }

  void drawArea(MapView map, Area a) {
    // pastel color derived from ID (stable)
    randomSeed(a.id * 9973);

    if (a.selected) {
      fill(255, 150, 0, 150); // HIGHLIGHT selected
      stroke(255, 100, 0);
    } else {
      fill(100 + random(100), 100 + random(100), 100 + random(100), 90);
      stroke(0, 160, 0);
    }

    strokeWeight(2);
    beginShape();
    for (PVector p : a.pts) {
      vertex(map.sx(p.x), map.sy(p.y));
    }
    endShape(CLOSE);

    // label
    PVector c = centroid(a.pts);
    fill(0);
    textAlign(CENTER, CENTER);
    text("#" + a.id, map.sx(c.x), map.sy(c.y));
  }

  PVector centroid(ArrayList<PVector> pts) {
    float x = 0, y = 0;
    for (PVector p : pts) {
      x += p.x;
      y += p.y;
    }
    return new PVector(x / pts.size(), y / pts.size());
  }

  // ---------------- NEW: handle click to toggle selection ----------------
  void handleClick(float mx, float my, MapView map) {
    for (Area a : areas) {
      if (pointInPolygon(mx, my, a, map)) {
        a.selected = !a.selected;
        break; // toggle only one at a time
      }
    }
  }

  // Simple point-in-polygon check using ray casting
  boolean pointInPolygon(float px, float py, Area a, MapView map) {
    int crossings = 0;
    int count = a.pts.size();
    for (int i = 0; i < count; i++) {
      PVector p1 = a.pts.get(i);
      PVector p2 = a.pts.get((i + 1) % count);
      float x1 = map.sx(p1.x), y1 = map.sy(p1.y);
      float x2 = map.sx(p2.x), y2 = map.sy(p2.y);

      if (((y1 > py) != (y2 > py)) &&
          (px < (x2 - x1) * (py - y1) / (y2 - y1) + x1)) {
        crossings++;
      }
    }
    return (crossings % 2 == 1);
  }

  // ---------------- NEW: get selected room IDs ----------------
  ArrayList<Integer> getSelectedRooms() {
    ArrayList<Integer> sel = new ArrayList<Integer>();
    for (Area a : areas) {
      if (a.selected) sel.add(a.id);
    }
    return sel;
  }
}
