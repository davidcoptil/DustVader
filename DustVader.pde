import java.net.HttpURLConnection;
import java.net.URL;

String BASE = "http://192.168.1.15:8080";

int mapId = 2;

MapView map;
AreasView areas;
CGMView cgm;
RobotPose robot;

int lastCGM = 0;
int lastPose = 0;


// ================= USER LAYOUT PARAMETERS =================

// map takes this part of screen
float MAP_HEIGHT_RATIO = 0.4;


// ================= CALCULATED VALUES =================

float MAP_H;


// =======================================================
// SETUP
// =======================================================

void setup() {

  fullScreen();
  orientation(PORTRAIT);

  textAlign(CENTER, CENTER);
  textSize(32);

  // ----- map area -----
  MAP_H = height * MAP_HEIGHT_RATIO;

  resetMap(2);

  // init buttons (NEW)
  ButtonsInit();
}


// =======================================================
// DRAW
// =======================================================

void draw() {

  background(20);

  // draw buttons (NEW)
  ButtonsDraw();


  // ----- MAP AREA -----
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

  // buttons (NEW)
  ButtonsHandleClick(mouseX, mouseY);

  // map interaction
  areas.handleClick(mouseX, mouseY, map);
}


// =======================================================
// COMMAND IDs
// =======================================================

final int CMD_CLEAN_HOUSE  = 1;
final int CMD_CLEAN_LIVING = 2;
final int CMD_STOP         = 3;
final int CMD_CONTINUE     = 4;
final int CMD_INTENSIVE    = 5;
final int CMD_SILENT       = 6;
final int CMD_SPEED_NORMAL = 7;
final int CMD_SPEED_HIGH   = 8;


// =======================================================
// EXECUTE
// =======================================================

void execute(int cmd) {

  switch (cmd) {

  case CMD_CLEAN_HOUSE:
    resetMap(2);
    send("/set/clean_map?map_id=2&cleaning_parameter_set=3");
    break;

  case CMD_CLEAN_LIVING:
    resetMap(55);
    send("/set/clean_map?map_id=55&cleaning_parameter_set=3");
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
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_trans_speed%22%3A12800%7D%7D%7D%7D%7D");
    break;

  case CMD_SPEED_HIGH:
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_trans_speed%22%3A20480%7D%7D%7D%7D%7D");
    break;

  case 99:
    ArrayList<Integer> selRooms = areas.getSelectedRooms();
    if (selRooms.size() > 0) {
      String roomList = "";
      for (int r : selRooms) roomList += r + ",";
      roomList = roomList.substring(0, roomList.length()-1);
      println("Cleaning selected rooms: " + roomList);
      //send("/set/clean_rooms?map_id=" + mapId + "&rooms=" + roomList);
    } else {
      println("No rooms selected!");
    }
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

        HttpURLConnection conn =
          (HttpURLConnection) new URL(urlStr).openConnection();

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
  }).start();
}
