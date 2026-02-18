class RobotPose {

  PVector pos = new PVector();   // current robot position
  float theta = 0;               // heading in radians

  String baseUrl;
  int mapId;

  volatile float newX, newY, newTheta;

  // AUTOMATIC OFFSET (computed once)
  boolean offsetComputed = false;
  float offsetX = 0;
  float offsetY = 0;

  RobotPose(String baseUrl, int mapId) {
    this.baseUrl = baseUrl;
    this.mapId = mapId;

    newX = pos.x;
    newY = pos.y;
    newTheta = theta;
  }

  void updateAsync() {
    new Thread(new Runnable() {
      public void run() {
        try {
          String jsonStr = join(loadStrings(baseUrl + "/get/rob_pose"), "");
          JSONObject j = parseJSONObject(jsonStr);

          if (!j.getBoolean("valid")) return;

          float x = j.getFloat("x1");
          float y = j.getFloat("y1");
          float h = j.getFloat("heading"); // raw robot heading
          
          float t = h * -PI / 6000.0;       // map robot units → radians
          
          newX = x;
          newY = y;
          newTheta = t;
        }
        catch (Exception e) {
          println("Robot fetch failed: " + e);
        }
      }
    }
    ).start();
  }

  // ---------- UPDATE FRAME ----------
  void updateFrame() {
    pos.x = newX;
    pos.y = newY;
    theta = newTheta;
  }

  // ---------- DRAW ----------
  void draw(MapView map) {
    float s = 40; // robot size in pixels

    if (!offsetComputed && map.loaded && map.dockPos != null) {
      float baseScreenX = map.sx(0);
      float baseScreenY = map.sy(0);

      float dockScreenX = map.sx(map.dockPos.x);
      float dockScreenY = map.sy(map.dockPos.y);

      offsetX = dockScreenX - baseScreenX;
      offsetY = dockScreenY - baseScreenY;

      offsetComputed = true;
    }

    // Map coordinate transform
    float screenX = map.sx(pos.x);// + offsetX;
    float screenY = map.sy(pos.y);// + offsetY;

    pushMatrix();
    translate(screenX, screenY);

    // Apply heading rotation in **screen space**
    rotate(theta);
    println(theta);

    fill(255, 0, 0);
    noStroke();
    ellipse(0, 0, s, s);

    stroke(255);
    strokeWeight(2);
    line(0, 0, 40, 0);  // heading line
    popMatrix();
  }
}
