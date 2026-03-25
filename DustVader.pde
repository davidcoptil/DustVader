import java.net.HttpURLConnection;
import java.net.URL;

String BASE = "http://192.168.1.15:8080";

int mapId = 2;

Button[] buttons;

MapView map;
AreasView areas;
CGMView cgm;
RobotPose robot;

int lastCGM = 0;
int lastPose = 0;



// ================= USER LAYOUT PARAMETERS =================

// map takes this part of screen

float MAP_HEIGHT_RATIO = 0.5;

// button size

float BTN_WIDTH_RATIO  = 0.38;
float BTN_HEIGHT_RATIO = 0.18;

// spacing between button centers

float BTN_GAP_X_RATIO = 1.15;
float BTN_GAP_Y_RATIO = 1.2;

// vertical offset inside bottom area

float BTN_OFFSET_Y_RATIO = 0.6;



// ================= CALCULATED VALUES =================

float MAP_H;

float BTN_AREA_Y;
float BTN_AREA_H;

float BTN_W;
float BTN_H_BTN;

float BTN_SPACING_X;
float BTN_SPACING_Y;

float BTN_START_X;
float BTN_START_Y;



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

  BTN_AREA_Y = MAP_H;
  BTN_AREA_H = height - MAP_H;


  // ----- button size -----

  BTN_W = width * BTN_WIDTH_RATIO;
  BTN_H_BTN = BTN_AREA_H * BTN_HEIGHT_RATIO;


  // ----- spacing -----

  BTN_SPACING_X = BTN_W * BTN_GAP_X_RATIO;
  BTN_SPACING_Y = BTN_H_BTN * BTN_GAP_Y_RATIO;


  // ----- start position (center of first button) -----

  BTN_START_X = width * 0.5 - BTN_SPACING_X / 2;
  BTN_START_Y = BTN_AREA_Y + BTN_SPACING_Y * BTN_OFFSET_Y_RATIO;


  resetMap(2);
  createButtons();
}



// =======================================================
// DRAW
// =======================================================

void draw() {

  background(20);

  fill(30);
  rect(0, BTN_AREA_Y, width, BTN_AREA_H);

  for (Button b : buttons) b.draw();


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
  for (Button b : buttons)
    if (b.hit(mouseX, mouseY))
      execute(b.cmd);
}



// =======================================================
// BUTTONS
// =======================================================

void createButtons() {

  buttons = new Button[] {

    new Button("CLEAN HOUSE", 0, 0, CMD_CLEAN_HOUSE),
    new Button("CLEAN LIVING", 1, 0, CMD_CLEAN_LIVING),

    new Button("STOP", 0, 1, CMD_STOP),
    new Button("CONTINUE", 1, 1, CMD_CONTINUE),

    new Button("INTENSIVE", 0, 2, CMD_INTENSIVE),
    new Button("SILENT", 1, 2, CMD_SILENT),

    new Button("NORMAL SPEED", 0, 3, CMD_SPEED_NORMAL),
    new Button("HIGH SPEED", 1, 3, CMD_SPEED_HIGH)
  };
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
    send("/set/switch_cleaning_parameter_set?cleaning_parameter_set=4");
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

      } catch (Exception e) {
        e.printStackTrace();
      }

    }

  }).start();
}



// =======================================================
// BUTTON CLASS
// =======================================================

class Button {

  String label;
  int col,row,cmd;

  Button(String l,int c,int r,int cmd){
    label=l;
    col=c;
    row=r;
    this.cmd=cmd;
  }

  void draw() {

    float cx = BTN_START_X + col * BTN_SPACING_X;
    float cy = BTN_START_Y + row * BTN_SPACING_Y;

    float x = cx - BTN_W/2;
    float y = cy - BTN_H_BTN/2;

    fill(70);
    rect(x, y, BTN_W, BTN_H_BTN, 20);

    fill(255);
    text(label, cx, cy);
  }

  boolean hit(float mx,float my) {

    float cx = BTN_START_X + col * BTN_SPACING_X;
    float cy = BTN_START_Y + row * BTN_SPACING_Y;

    float x = cx - BTN_W/2;
    float y = cy - BTN_H_BTN/2;

    return mx>x && mx<x+BTN_W &&
           my>y && my<y+BTN_H_BTN;
  }
}
