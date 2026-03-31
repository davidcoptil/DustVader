Button[] buttons;
Button[] mapButtons;



// original config
float BTN_WIDTH_RATIO  = 0.38;
float BTN_HEIGHT_RATIO = 0.10;

float BTN_GAP_X_RATIO = 1.15;
float BTN_GAP_Y_RATIO = 1.35;

float BTN_OFFSET_Y_RATIO = 0.6;

// calculated
float BTN_W, BTN_H_BTN;
float BTN_SPACING_X, BTN_SPACING_Y;
float BTN_START_X, BTN_START_Y;


// =======================================================
// INIT
// =======================================================

void ButtonsInit(float infoY, float infoH,
                 float btnY, float btnH) {

  INFO_Y = infoY;
  INFO_H = infoH;

  BTN_AREA_Y = btnY;
  BTN_AREA_H = btnH;

  BTN_W = width * BTN_WIDTH_RATIO;
  BTN_H_BTN = BTN_AREA_H * BTN_HEIGHT_RATIO;

  BTN_SPACING_X = BTN_W * BTN_GAP_X_RATIO;
  BTN_SPACING_Y = BTN_H_BTN * BTN_GAP_Y_RATIO;

  BTN_START_X = width * 0.5 - BTN_SPACING_X / 2;
  BTN_START_Y = BTN_AREA_Y + BTN_SPACING_Y * BTN_OFFSET_Y_RATIO;

  createButtons();
}


// =======================================================
// DRAW
// =======================================================

void ButtonsDraw() {

  drawInfoBar();

  fill(30);
  rect(0, BTN_AREA_Y, width, BTN_AREA_H);

  for (Button b : buttons)
    b.draw();
}


// ---------------- INFO BAR ----------------

void drawInfoBar() {

  fill(25);
  rect(0, INFO_Y, width, INFO_H);

  // MAP BUTTONS
  for (Button b : mapButtons) {

    boolean selected =
      (selectedMapId == 2 && b.cmd == CMD_MAP_HOUSE) ||
      (selectedMapId == 55 && b.cmd == CMD_MAP_LIVING);

    b.drawSpecial(selected ? color(120,180,255) : color(60,90,140));
  }

  // BATTERY TEXT (NO EMOJIS)
  fill(255);
  textSize(28);

  String status = isCharging ? "CHG" : "IDLE";
  String txt = (batteryLevel >= 0 ? batteryLevel + "% " + status : "--");

  text(txt, width * 0.85, INFO_Y + INFO_H/2);
}


// =======================================================
// INPUT
// =======================================================

boolean ButtonsHandleClick(float mx, float my) {

  for (Button b : mapButtons)
    if (b.hit(mx, my)) {
      execute(b.cmd);
      return true;
    }

  for (Button b : buttons)
    if (b.hit(mx, my)) {
      execute(b.cmd);
      return true;
    }

  return false;
}


// =======================================================
// CREATE
// =======================================================

void createButtons() {

  mapButtons = new Button[] {
    new Button("HOUSE", 0.2, INFO_Y, 0.22, INFO_H, CMD_MAP_HOUSE),
    new Button("LIVING", 0.45, INFO_Y, 0.22, INFO_H, CMD_MAP_LIVING)
  };

  buttons = new Button[] {

    new Button("CLEAN ALL", 0, 0, CMD_CLEAN_ALL),
    new Button("CLEAN ROOMS", 1, 0, CMD_CLEAN_ROOMS),

    new Button("STOP", 0, 1, CMD_STOP),
    new Button("CONTINUE", 1, 1, CMD_CONTINUE),

    new Button("INTENSIVE", 0, 2, CMD_INTENSIVE),
    new Button("SILENT", 1, 2, CMD_SILENT),

    new Button("NORMAL SPEED", 0, 3, CMD_SPEED_NORMAL),
    new Button("HIGH SPEED", 1, 3, CMD_SPEED_HIGH)
  };
}


// =======================================================
// BUTTON CLASS
// =======================================================

class Button {

  String label;
  int col, row, cmd;

  float x, y, w, h;
  boolean custom = false;

  Button(String l, int c, int r, int cmd) {
    label = l;
    col = c;
    row = r;
    this.cmd = cmd;
  }

  Button(String l, float cx, float y, float wRatio, float h, int cmd) {
    label = l;
    this.cmd = cmd;

    this.w = width * wRatio;
    this.h = h;

    this.x = cx * width - w/2;
    this.y = y;

    custom = true;
  }

  void draw() {

    if (custom) {
      drawRect(x, y, w, h, color(80));
      return;
    }

    float cx = BTN_START_X + col * BTN_SPACING_X;
    float cy = BTN_START_Y + row * BTN_SPACING_Y;

    drawRect(cx - BTN_W/2, cy - BTN_H_BTN/2, BTN_W, BTN_H_BTN, color(70));
  }

  void drawSpecial(int colr) {
    drawRect(x, y, w, h, colr);
  }

  void drawRect(float x, float y, float w, float h, int colr) {

    fill(colr);
    rect(x, y, w, h, 20);

    fill(255);
    textSize(24);
    text(label, x + w/2, y + h/2);
  }

  boolean hit(float mx, float my) {

    if (custom)
      return mx > x && mx < x + w && my > y && my < y + h;

    float cx = BTN_START_X + col * BTN_SPACING_X;
    float cy = BTN_START_Y + row * BTN_SPACING_Y;

    float x = cx - BTN_W/2;
    float y = cy - BTN_H_BTN/2;

    return mx > x && mx < x + BTN_W &&
           my > y && my < y + BTN_H_BTN;
  }
}
