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

float MAP_H;
float BTN_Y;
float BTN_H;

void setup() {
  fullScreen();
  orientation(PORTRAIT);

  textAlign(CENTER, CENTER);
  textSize(32);

  MAP_H = height * 0.5;
  BTN_Y = MAP_H;
  BTN_H = height - MAP_H;

  resetMap(2);
  createButtons();
}

void draw() {
  background(20);

  fill(30);
  rect(0, height * 0.5, width, height * 0.5);

  for (Button b : buttons) b.draw();

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

void mousePressed() {
  for (Button b : buttons)
    if (b.hit(mouseX, mouseY))
      execute(b.cmd);
}

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

final int CMD_CLEAN_HOUSE  = 1;
final int CMD_CLEAN_LIVING = 2;
final int CMD_STOP         = 3;
final int CMD_CONTINUE     = 4;
final int CMD_INTENSIVE    = 5;
final int CMD_SILENT       = 6;
final int CMD_SPEED_NORMAL = 7;
final int CMD_SPEED_HIGH   = 8;

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
    send("/set/switch_cleaning_parameter_set?cleaning_parameter_set=2");
    break;

  case CMD_SPEED_NORMAL:
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_trans_speed%22%3A12800%7D%7D%7D%7D%7D");
    break;

  case CMD_SPEED_HIGH:
    send("/set/configurable_parameters?params=%7B%22customer%22%3A%7B%22robot_capabilities%22%3A%7B%22speeds%22%3A%7B%22dry%22%3A%7B%22max_trans_speed%22%3A20480%7D%7D%7D%7D%7D");
    break;
  }
}

void resetMap(int newMapId) {
  mapId = newMapId;
  map   = new MapView(BASE, mapId);
  areas = new AreasView(BASE, mapId);
  cgm   = new CGMView(BASE, mapId);
  robot = new RobotPose(BASE, mapId);
}

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
    float bw = width*0.5;
    float bh = BTN_H/4;

    float x = col*bw;
    float y = BTN_Y+row*bh;

    fill(70);
    rect(x+10,y+10,bw-20,bh-20,20);

    fill(255);
    text(label,x+bw/2,y+bh/2);
  }

  boolean hit(float mx,float my) {
    float bw = width*0.5;
    float bh = BTN_H/4;

    float x = col*bw;
    float y = BTN_Y+row*bh;

    return mx>x && mx<x+bw &&
           my>y && my<y+bh;
  }
}
