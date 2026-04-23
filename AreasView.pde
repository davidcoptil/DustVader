class AreasView {

  class Area {
    int id;
    ArrayList<PVector> pts = new ArrayList<PVector>();
    boolean selected = false;
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
    }
    catch (Exception e) {
      println("Areas load failed");
      e.printStackTrace();
    }
  }

  void draw(MapView map) {
    pushStyle();
    for (Area a : areas) {
      drawArea(map, a);
    }
    popStyle();
  }

  void drawArea(MapView map, Area a) {
    if (a.pts.size() < 3) return;

    int baseFill = areaFillColor(a.id);
    int baseStroke = areaStrokeColor(a.id);
    float strokeW = a.selected ? map.worldStroke(2.6) : map.worldStroke(1.4);

    if (a.selected) {
      fill(255, 170, 48, 120);
      stroke(255, 178, 64);
    } else {
      fill(red(baseFill), green(baseFill), blue(baseFill), 82);
      stroke(red(baseStroke), green(baseStroke), blue(baseStroke), 210);
    }

    strokeWeight(strokeW);
    strokeJoin(ROUND);

    beginShape();
    for (PVector p : a.pts) {
      vertex(map.sx(p.x), map.sy(p.y));
    }
    endShape(CLOSE);

    PVector c = centroid(a.pts);
    float labelSize = constrain(map.worldStroke(13), 11, 24);

    fill(a.selected ? color(255, 244, 220) : color(235, 239, 245));
    textAlign(CENTER, CENTER);
    textSize(labelSize);
    text(str(a.id), map.sx(c.x), map.sy(c.y));
  }

  int areaFillColor(int id) {
    float hue = (id * 47) % 360;
    return colorFromHSV(hue, 0.38, 0.72);
  }

  int areaStrokeColor(int id) {
    float hue = (id * 47 + 18) % 360;
    return colorFromHSV(hue, 0.52, 0.88);
  }

  int colorFromHSV(float h, float s, float v) {
    float c = v * s;
    float x = c * (1.0 - abs((h / 60.0) % 2.0 - 1.0));
    float m = v - c;

    float r1 = 0;
    float g1 = 0;
    float b1 = 0;

    if (h < 60) {
      r1 = c;
      g1 = x;
    } else if (h < 120) {
      r1 = x;
      g1 = c;
    } else if (h < 180) {
      g1 = c;
      b1 = x;
    } else if (h < 240) {
      g1 = x;
      b1 = c;
    } else if (h < 300) {
      r1 = x;
      b1 = c;
    } else {
      r1 = c;
      b1 = x;
    }

    return color((r1 + m) * 255.0, (g1 + m) * 255.0, (b1 + m) * 255.0);
  }

  PVector centroid(ArrayList<PVector> pts) {
    float signedArea = 0;
    float cx = 0;
    float cy = 0;

    for (int i = 0; i < pts.size(); i++) {
      PVector p0 = pts.get(i);
      PVector p1 = pts.get((i + 1) % pts.size());
      float a = p0.x * p1.y - p1.x * p0.y;
      signedArea += a;
      cx += (p0.x + p1.x) * a;
      cy += (p0.y + p1.y) * a;
    }

    if (abs(signedArea) < 0.0001) {
      float x = 0;
      float y = 0;
      for (PVector p : pts) {
        x += p.x;
        y += p.y;
      }
      return new PVector(x / pts.size(), y / pts.size());
    }

    signedArea *= 0.5;
    cx /= (6.0 * signedArea);
    cy /= (6.0 * signedArea);
    return new PVector(cx, cy);
  }

  void handleClick(float mx, float my, MapView map) {
    for (Area a : areas) {
      if (pointInPolygon(mx, my, a, map)) {
        a.selected = !a.selected;
        break;
      }
    }
  }

  boolean pointInPolygon(float px, float py, Area a, MapView map) {
    int crossings = 0;
    int count = a.pts.size();

    for (int i = 0; i < count; i++) {
      PVector p1 = a.pts.get(i);
      PVector p2 = a.pts.get((i + 1) % count);
      float x1 = map.sx(p1.x);
      float y1 = map.sy(p1.y);
      float x2 = map.sx(p2.x);
      float y2 = map.sy(p2.y);

      if (((y1 > py) != (y2 > py)) &&
        (px < (x2 - x1) * (py - y1) / (y2 - y1) + x1)) {
        crossings++;
      }
    }

    return (crossings % 2 == 1);
  }

  ArrayList<Integer> getSelectedRooms() {
    ArrayList<Integer> sel = new ArrayList<Integer>();
    for (Area a : areas) {
      if (a.selected) sel.add(a.id);
    }
    return sel;
  }

  void clearSelection() {
    for (Area a : areas) {
      a.selected = false;
    }
  }
}
