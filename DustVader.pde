import java.net.HttpURLConnection;
import java.net.URL;

String BASE = "http://192.168.0.15:8080";

int suction = 3;
int mapId = 2;
String MAP_ARG;

Button[] buttons;

MapView map;
AreasView areas;
CGMView cgm;
RobotPose robot;

int lastCGM = 0;
int lastPose = 0;

float MAP_H;
float BTN_Y;
float BTN_H;

// =======================================================
// SETUP
// =======================================================

void setup() {
  fullScreen();
  orientation(PORTRAIT);

  textAlign(CENTER, CENTER);
  textSize(32);

  MAP_ARG = "&map_id=" + mapId;

  MAP_H = height * 0.5;
  BTN_Y = MAP_H;
  BTN_H = height - MAP_H;

  map   = new MapView(BASE, mapId);
  areas = new AreasView(BASE, mapId);
  cgm   = new CGMView(BASE, mapId);
  robot = new RobotPose(BASE, mapId);

  createButtons();
}

// =======================================================
// DRAW
// =======================================================

void draw() {
  background(20);

  // ================= UI (BOTTOM HALF) =================
  fill(30);
  rect(0, height * 0.5, width, height * 0.5);

  for (Button b : buttons) {
    b.draw();
  }

  // ================= MAP (TOP HALF) =================
  pushMatrix();
  pushStyle();

  clip(0, 0, width, height * 0.5);

  map.draw(0, 0, width, height * 0.5);
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
  for (Button b : buttons) {
    if (b.hit(mouseX, mouseY)) {
      println("Button pressed: " + b.label);
      execute(b.cmd);
    }
  }
}

// =======================================================
// BUTTONS
// =======================================================

void createButtons() {
  buttons = new Button[] {

    new Button("CLEAN ALL", 0, 0, CMD_CLEAN_ALL),
    new Button("STOP", 1, 0, CMD_STOP),

    new Button("CONTINUE", 0, 1, CMD_CONTINUE),
    new Button("GO HOME", 1, 1, CMD_GO_HOME),

    new Button("EXPLORE", 0, 2, CMD_EXPLORE),
    new Button("TEST SPOT", 1, 2, CMD_TEST_SPOT),

    new Button("SUCTION -", 0, 3, CMD_SUCTION_DOWN),
    new Button("SUCTION +", 1, 3, CMD_SUCTION_UP)
  };
}

// =======================================================
// COMMANDS
// =======================================================

final int CMD_CLEAN_ALL    = 1;
final int CMD_STOP         = 2;
final int CMD_CONTINUE     = 3;
final int CMD_GO_HOME      = 4;
final int CMD_EXPLORE      = 5;
final int CMD_SUCTION_DOWN = 11;
final int CMD_SUCTION_UP   = 12;
final int CMD_TEST_SPOT    = 99;

void execute(int cmd) {
  switch (cmd) {

  case CMD_CLEAN_ALL:
    send("/set/clean_all?cleaning_parameter_set=" + suction + "&map_id=" + mapId);
    break;

  case CMD_STOP:
    send("/set/stop");
    break;

  case CMD_CONTINUE:
    send("/set/continue");
    break;

  case CMD_GO_HOME:
    send("/set/go_home");
    break;

  case CMD_EXPLORE:
    // intentionally disabled
    println("EXPLORE disabled to avoid remapping");
    break;

  case CMD_SUCTION_DOWN:
    suction = max(0, suction - 1);
    setSuction();
    break;

  case CMD_SUCTION_UP:
    suction = min(4, suction + 1);
    setSuction();
    break;

  case CMD_TEST_SPOT:
    send("/set/clean_spot?cleaning_parameter_set=4&map_id=" + mapId);
    break;
  }
}


// =======================================================
// HTTP
// =======================================================

void send(final String path) {
  final String urlStr = BASE + path;
  println("SEND: " + urlStr);

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

void setSuction() {
  send("/set/switch_cleaning_parameter_set?cleaning_parameter_set=" + suction);
}

// =======================================================
// BUTTON CLASS
// =======================================================

class Button {
  String label;
  int col, row;
  int cmd;

  Button(String label, int col, int row, int cmd) {
    this.label = label;
    this.col = col;
    this.row = row;
    this.cmd = cmd;
  }

  void draw() {
    float bw = width * 0.5;
    float bh = BTN_H / 4;

    float x = col * bw;
    float y = BTN_Y + row * bh;

    fill(70);
    rect(x + 10, y + 10, bw - 20, bh - 20, 20);

    fill(255);
    text(label, x + bw / 2, y + bh / 2);
  }

  boolean hit(float mx, float my) {
    float bw = width * 0.5;
    float bh = BTN_H / 4;

    float x = col * bw;
    float y = BTN_Y + row * bh;

    return mx > x && mx < x + bw &&
           my > y && my < y + bh;
  }
}
