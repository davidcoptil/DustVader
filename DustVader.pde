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


// ================= LAYOUT =================

// map
float MAP_START_RATIO  = 0.0;
float MAP_HEIGHT_RATIO = 0.4;

// info
float INFO_START_RATIO  = 0.4;
float INFO_HEIGHT_RATIO = 0.1;

// buttons
float BTN_AREA_START_RATIO  = 0.5;
float BTN_AREA_HEIGHT_RATIO = 0.5;


// ================= CALCULATED =================

float MAP_H;
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

  MAP_H = height * MAP_HEIGHT_RATIO;

  INFO_Y = height * INFO_START_RATIO;
  INFO_H = height * INFO_HEIGHT_RATIO;

  BTN_AREA_Y = height * BTN_AREA_START_RATIO;
  BTN_AREA_H = height * BTN_AREA_HEIGHT_RATIO;

  resetMap(selectedMapId);

  ButtonsInit(INFO_Y, INFO_H, BTN_AREA_Y, BTN_AREA_H);

  updateStatus(); // initial fetch
}


// =======================================================
// DRAW
// =======================================================

void draw() {

  background(15);

  // ---- STATUS UPDATE (5s) ----
  if (millis() - lastStatus > 5000) {
    updateStatus();
    lastStatus = millis();
  }

  ButtonsDraw();

  // ---- MAP ----
  pushMatrix();
  pushStyle();

  clip(0, 0, width, MAP_H);

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

  popStyle();
  popMatrix();
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

    if (json != null) {
      batteryLevel = json.getInt("battery_level");

      String charging = json.getString("charging");
      isCharging = charging.equals("charging");
    }

  } catch (Exception e) {
    println("Status read failed");
  }
}


// =======================================================
// COMMANDS
// =======================================================

final int CMD_CLEAN_ALL    = 1;
final int CMD_CLEAN_ROOMS  = 2;
final int CMD_STOP         = 3;
final int CMD_CONTINUE     = 4;
final int CMD_INTENSIVE    = 5;
final int CMD_SILENT       = 6;
final int CMD_SPEED_NORMAL = 7;
final int CMD_SPEED_HIGH   = 8;

final int CMD_MAP_HOUSE  = 100;
final int CMD_MAP_LIVING = 101;


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
      roomList = roomList.substring(0, roomList.length()-1);

      send("/set/clean_rooms?map_id=" + selectedMapId + "&rooms=" + roomList);

    } else {
      println("No rooms selected!");
    }
    break;

  case CMD_STOP:
    send("/set/stop");
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
    send("/set/configurable_parameters?params=...");
    break;

  case CMD_SPEED_HIGH:
    send("/set/configurable_parameters?params=...");
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

  new Thread(() -> {
    try {
      HttpURLConnection conn =
        (HttpURLConnection) new URL(urlStr).openConnection();

      conn.setRequestMethod("GET");
      conn.getResponseCode();
      conn.disconnect();

    } catch (Exception e) {
      e.printStackTrace();
    }
  }).start();
}
