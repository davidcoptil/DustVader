import java.net.HttpURLConnection;
import java.net.URL;

String BASE = "http://192.168.1.15:8080";

// -------- MAP STATE --------
int mapId = 2;
int selectedMapId = 2;

// -------- MODULES --------
MapView map;
AreasView areas;
CGMView cgm;
RobotPose robot;

int lastCGM = 0;
int lastPose = 0;

// -------- STATUS --------
int batteryLevel = -1;
boolean isCharging = false;
int lastStatus = 0;

// ================= USER LAYOUT PARAMETERS =================
float MAP_START_RATIO  = 0.0;
float MAP_HEIGHT_RATIO = 0.4;

float INFO_START_RATIO  = 0.4;
float INFO_HEIGHT_RATIO = 0.1;

float BTN_AREA_START_RATIO  = 0.5;
float BTN_AREA_HEIGHT_RATIO = 0.5;

// ================= CALCULATED VALUES =================
float MAP_Y, MAP_H;
float INFO_Y, INFO_H;
float BTN_AREA_Y, BTN_AREA_H;

// =======================================================
// SETUP
// =======================================================
void setup() {
  fullScreen();
  orientation(PORTRAIT);
  textAlign(CENTER, CENTER);
  textSize(32);

  // compute layout
  MAP_Y = height * MAP_START_RATIO;
  MAP_H = height * MAP_HEIGHT_RATIO;

  INFO_Y = height * INFO_START_RATIO;
  INFO_H = height * INFO_HEIGHT_RATIO;

  BTN_AREA_Y = height * BTN_AREA_START_RATIO;
  BTN_AREA_H = height * BTN_AREA_HEIGHT_RATIO;

  resetMap(selectedMapId);

  // pass layout to buttons
  ButtonsInit(INFO_Y, INFO_H, BTN_AREA_Y, BTN_AREA_H);
}

// =======================================================
// DRAW
// =======================================================
void draw() {
  background(15);

  if (millis() - lastStatus > 5000) {
    updateStatus();
    lastStatus = millis();
  }

  map.draw(0, 0, width, MAP_H);
  areas.draw(map);

  if (millis() - lastCGM > 1000) {
    cgm.update();
    lastCGM = millis();
  }
  if (millis() - lastPose > 150) {
    robot.updateAsync();
    lastPose = millis();
  }

  robot.updateFrame();
  robot.draw(map);
  cgm.draw(map);

  noStroke();
  fill(15);
  rect(0, MAP_H, width, height - MAP_H);

  ButtonsDraw();

  // ---------------- INFO BAR ----------------


  // display at the info bar location using the new function
  drawInfo();
}

// =======================================================
// DISPLAY INFO AT INFO BAR LOCATION
// =======================================================
void drawInfo() {
  String infoText = (batteryLevel >= 0 ? batteryLevel + "%" : "--");
  if (isCharging) infoText += " +";
  else infoText += " -";
  fill(color(255));
  textSize(40);
  textAlign(CENTER, CENTER);
  text(infoText, width * 0.85, INFO_Y + INFO_H/2);
}

// =======================================================
// INPUT
// =======================================================
void mousePressed() {
  if (!ButtonsHandleClick(mouseX, mouseY)) {
    areas.handleClick(mouseX, mouseY, map);
  }
}

// =======================================================
// STATUS
// =======================================================
void updateStatus() {
  try {
    String url = BASE + "/get/status";
    JSONObject json = parseJSONObject(join(loadStrings(url), ""));
    batteryLevel = json.getInt("battery_level");
    String charging = json.getString("charging");
    isCharging = !charging.equals("unconnected");
  }
  catch (Exception e) {
    println("Status read failed");
  }
}

// =======================================================
// COMMAND IDs
// =======================================================
final int CMD_CLEAN_ALL    = 1;
final int CMD_CLEAN_ROOMS  = 2;
final int CMD_STOP         = 3;
final int CMD_CONTINUE     = 4;
final int CMD_INTENSIVE    = 5;
final int CMD_SILENT       = 6;
final int CMD_SPEED_NORMAL = 7;
final int CMD_SPEED_HIGH   = 8;
final int CMD_MAP_HOUSE    = 100;
final int CMD_MAP_LIVING   = 101;
final int CMD_GO_HOME      = 200;

// =======================================================
// EXECUTE
// =======================================================
void execute(int cmd) {
  switch (cmd) {
  case CMD_MAP_HOUSE:
    selectedMapId = 2;
    resetMap(selectedMapId);
    break;
  case CMD_MAP_LIVING:
    selectedMapId = 55;
    resetMap(selectedMapId);
    break;

  case CMD_CLEAN_ALL:
    send("/set/clean_map?map_id=" + selectedMapId + "&cleaning_parameter_set=3");
    break;

  case CMD_CLEAN_ROOMS:
    ArrayList<Integer> selRooms = areas.getSelectedRooms();
    if (selRooms.size() > 0) {
      String roomList = "";
      for (int r : selRooms) roomList += r + ",";
      roomList = roomList.substring(0, roomList.length() - 1);
      send("/set/clean_map?map_id=" + selectedMapId + "&area_ids=" + roomList);
      areas.clearSelection();
    } else {
      println("No rooms selected!");
    }
    break;

  case CMD_STOP:
    send("/set/stop");
    break;
  case CMD_GO_HOME:
    send("/set/go_home");
    break;
  case CMD_CONTINUE:
    send("/set/continue");
    break;
  case CMD_INTENSIVE:
    send("/set/switch_cleaning_parameter_set?cleaning_parameter_set=3");
    break;
  case CMD_SILENT:
    send("/set/switch_cleaning_parameter_set?cleaning_parameter_set=1");
    break;

  case CMD_SPEED_NORMAL:
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_trans_speed%22%3A12800%7D%7D%7D%7D%7D");
    delay(500);
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_ang_speed%22%3A24576%7D%7D%7D%7D%7D");
    break;

  case CMD_SPEED_HIGH:
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_trans_speed%22%3A20480%7D%7D%7D%7D%7D");
    delay(500);
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_ang_speed%22%3A28672%7D%7D%7D%7D%7D");
    break;
  }
}

// =======================================================
// MAP RESET
// =======================================================
void resetMap(int newMapId) {
  mapId = newMapId;
  map   = new MapView(BASE, mapId);
  areas = new AreasView(BASE, mapId);
  cgm   = new CGMView(BASE, mapId);
  robot = new RobotPose(BASE, mapId);
}

// =======================================================
// HTTP
// =======================================================
void send(final String path) {
  final String urlStr = BASE + path;
  new Thread(new Runnable() {
    public void run() {
      try {
        HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(4000);
        conn.setReadTimeout(4000);
        conn.getResponseCode();
        conn.disconnect();
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
  ).start();
}
