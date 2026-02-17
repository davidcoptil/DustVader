import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.HttpURLConnection;
import java.net.URL;

String BASE = "http://192.168.0.15:8080";

int suction = 3;
int mapId = 2;

String lastCommand = "none";
String lastResult  = "none";

Button[] buttons;

// ---------- COMMAND IDS ----------
final int CMD_CLEAN_ALL    = 1;
final int CMD_STOP         = 2;
final int CMD_CONTINUE     = 3;
final int CMD_GO_HOME      = 4;
final int CMD_EXPLORE      = 5;

final int CMD_TV           = 6;
final int CMD_HALLWAY      = 7;
final int CMD_BEDROOM      = 8;
final int CMD_KITCHEN      = 9;
final int CMD_WHOLE        = 10;

final int CMD_SUCTION_DOWN = 11;
final int CMD_SUCTION_UP   = 12;

final int CMD_TEST_SPOT    = 99;

MapView map;
AreasView areas;
CGMView cgm;
RobotPose robot;
int lastCGM = 0;
int lastPose = 0;


void setup() {
  //fullScreen();
  size(1000, 2000);
  orientation(PORTRAIT);
  textAlign(CENTER, CENTER);
  textSize(36);

  buttons = new Button[] {

    new Button("CLEAN ALL", 0.05, 0.10, CMD_CLEAN_ALL),
    new Button("STOP", 0.55, 0.10, CMD_STOP),

    new Button("CONTINUE", 0.05, 0.23, CMD_CONTINUE),
    new Button("GO HOME", 0.55, 0.23, CMD_GO_HOME),

    new Button("EXPLORE", 0.05, 0.36, CMD_EXPLORE),
    new Button("TEST SPOT", 0.55, 0.36, CMD_TEST_SPOT),

    new Button("TV ROOM", 0.05, 0.50, CMD_TV),
    new Button("HALLWAY", 0.55, 0.50, CMD_HALLWAY),

    new Button("BEDROOM", 0.05, 0.63, CMD_BEDROOM),
    new Button("KITCHEN", 0.55, 0.63, CMD_KITCHEN),

    new Button("WHOLE MAP", 0.05, 0.76, CMD_WHOLE),

    new Button("SUCTION -", 0.05, 0.89, CMD_SUCTION_DOWN),
    new Button("SUCTION +", 0.55, 0.89, CMD_SUCTION_UP)
  };

  map = new MapView(BASE, 2);
  areas = new AreasView(BASE, 2);
  cgm = new CGMView(BASE, 2);
  robot = new RobotPose(BASE, 2);
}

void draw() {
  background(20);

  textSize(36);

  map.draw(0, 20, width * 0.85, height * 0.9);
  areas.draw(map);

  if (millis() - lastCGM > 1000) {
    cgm.update();
    lastCGM = millis();
  }

  if (millis() - lastPose > 150) {
    robot.update();
    lastPose = millis();
  }

  cgm.draw(map);
  robot.draw(map);


  for (int i = 0; i < buttons.length; i++) {
    //buttons[i].draw();
  }
}

void mousePressed() {
  for (int i = 0; i < buttons.length; i++) {
    if (buttons[i].hit(mouseX, mouseY)) {
      //execute(buttons[i].cmd);
    }
  }
}

// ---------- EXECUTION ----------
void execute(int cmd) {

  switch (cmd) {

  case CMD_CLEAN_ALL:
    send("/set/clean_all?cleaning_parameter_set=" + suction);
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
    send("/set/explore");
    break;

  case CMD_TV:
    cleanRoom(4);
    break;

  case CMD_HALLWAY:
    cleanRoom(3);
    break;

  case CMD_BEDROOM:
    cleanRoom(1);
    break;

  case CMD_KITCHEN:
    cleanRoom(2);
    break;

  case CMD_WHOLE:
    send("/set/clean_map?map_id=2&cleaning_parameter_set=" + suction);
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
    // EXACT SAME URL AS YOUR BROWSER TEST
    send("/set/clean_spot?map_id=2&cleaning_parameter_set=4");
    break;
  }
}

// ---------- HTTP ----------
void send(final String path) {

  final String fullUrl = BASE + path;
  lastCommand = fullUrl;
  lastResult  = "sending...";

  println("SENDING: " + fullUrl);

  new Thread(new Runnable() {
    public void run() {
      try {
        URL url = new URL(fullUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(4000);
        conn.setReadTimeout(4000);

        int code = conn.getResponseCode();
        lastResult = "HTTP " + code;
        println("HTTP RESPONSE: " + code);

        conn.disconnect();
      }
      catch (Exception e) {
        lastResult = "ERROR";
        println("ERROR:");
        e.printStackTrace();
      }
    }
  }
  ).start();
}

// ---------- HELPERS ----------
void cleanRoom(int areaId) {
  send("/set/clean_map?map_id=" + mapId +
    "&area_ids=" + areaId +
    "&cleaning_parameter_set=" + suction);
}

void setSuction() {
  send("/set/switch_cleaning_parameter_set?cleaning_parameter_set=" + suction);
}

String suctionName() {
  if (suction == 0) return "Default";
  if (suction == 1) return "Normal";
  if (suction == 2) return "Silent";
  if (suction == 3) return "Intensive";
  if (suction == 4) return "Super Silent";
  return "";
}

// ---------- BUTTON ----------
class Button {
  String label;
  float x, y;
  float w = 0.4, h = 0.1;
  int cmd;

  Button(String label, float x, float y, int cmd) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.cmd = cmd;
  }

  void draw() {
    fill(60);
    rect(width*x, height*y, width*w, height*h, 20);
    fill(255);
    text(label, width*(x + w/2), height*(y + h/2));
  }

  boolean hit(float mx, float my) {
    return mx > width*x && mx < width*(x+w) &&
      my > height*y && my < height*(y+h);
  }
}
