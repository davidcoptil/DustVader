class AreasView {

  class Area {
    int id;
    ArrayList<PVector> pts = new ArrayList<PVector>();
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
    fill(100 + random(100), 100 + random(100), 100 + random(100), 90);
    stroke(0, 160, 0);
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
}
