class RobotPose {

  PVector pos = new PVector();
  float theta;
  String baseUrl;
  int mapId;

  RobotPose(String baseUrl, int mapId) {
    this.baseUrl = baseUrl;
    this.mapId = mapId;
  }

  void update() {
    try {
      JSONObject j = parseJSONObject(
        join(loadStrings(baseUrl + "/get/rob_pose"), "")
      );

      if (j.getInt("map_id") != mapId) return;

      pos.x = j.getFloat("x1");
      pos.y = j.getFloat("y1");
      theta = j.getFloat("theta") / 1000.0; // milliradians → radians

    } catch (Exception e) {
      println("Robot pose fetch failed");
    }
  }

  void draw(MapView map) {
    float x = map.sx(pos.x);
    float y = map.sy(pos.y);

    pushMatrix();
    translate(x, y);
    rotate(-theta);
    fill(255, 0, 0);
    noStroke();
    ellipse(0, 0, 14, 14);
    stroke(255);
    line(0, 0, 12, 0);
    popMatrix();
  }
}
