Button[] buttons;
Button[] mapButtons;

// ================= USER BUTTON CONFIG (UNCHANGED) =================
float BTN_WIDTH_RATIO  = 0.38;
float BTN_HEIGHT_RATIO = 0.15;

float BTN_GAP_X_RATIO = 1.15;
float BTN_GAP_Y_RATIO = 1.35;

float BTN_OFFSET_Y_RATIO = 0.6;

// ================= CALCULATED =================
float BTN_W;
float BTN_H_BTN;

float BTN_SPACING_X;
float BTN_SPACING_Y;

float BTN_START_X;
float BTN_START_Y;

// =======================================================
// INIT
// =======================================================
void ButtonsInit(float infoY, float infoH, float btnY, float btnH) {
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
  fill(30);
  rect(0, BTN_AREA_Y, width, BTN_AREA_H);

  for (Button b : buttons) b.draw();
  drawInfoBar();
}

// ---------------- INFO BAR ----------------
void drawInfoBar() {
  fill(25);
  rect(0, INFO_Y, width, INFO_H);

  if (selectedMapId == 2) {
    mapButtons[0].drawSpecial(color(120, 180, 255));
    mapButtons[1].drawSpecial(color(60, 90, 140));
  } else if (selectedMapId == 55) {
    mapButtons[0].drawSpecial(color(60, 90, 140));
    mapButtons[1].drawSpecial(color(120, 180, 255));
  }
}



// =======================================================
// INPUT
// =======================================================
boolean ButtonsHandleClick(float mx, float my) {
  for (Button b : mapButtons) if (b.hit(mx, my)) {
    execute(b.cmd);
    return true;
  }
  for (Button b : buttons) if (b.hit(mx, my)) {
    execute(b.cmd);
    return true;
  }
  return false;
}

// =======================================================
// CREATE (absolute XY+WH)
// =======================================================
void createButtons() {
  mapButtons = new Button[] {
    new Button("HOUSE", 0.2 * width - (0.22*width)/2, INFO_Y, 0.22 * width, INFO_H, CMD_MAP_HOUSE),
    new Button("LIVING", 0.45 * width - (0.22*width)/2, INFO_Y, 0.22 * width, INFO_H, CMD_MAP_LIVING)
  };

  // Compute absolute positions from current grid layout
  float bx0 = BTN_START_X - BTN_W/2;
  float bx1 = BTN_START_X + BTN_SPACING_X - BTN_W/2;
  float by0 = BTN_START_Y - BTN_H_BTN/2;
  float by1 = BTN_START_Y + BTN_SPACING_Y - BTN_H_BTN/2;
  float by2 = BTN_START_Y + BTN_SPACING_Y*2 - BTN_H_BTN/2;
  float by3 = BTN_START_Y + BTN_SPACING_Y*3 - BTN_H_BTN/2;

  // Split STOP button horizontally
  float stopWidth = BTN_W / 2;
  float stopHomeGap = 8;

  buttons = new Button[] {
    new Button("CLEAN ALL", bx0, by0, BTN_W, BTN_H_BTN, CMD_CLEAN_ALL),
    new Button("CLEAN ROOMS", bx1, by0, BTN_W, BTN_H_BTN, CMD_CLEAN_ROOMS),

    new Button("STOP", bx0, by1, stopWidth - stopHomeGap, BTN_H_BTN, CMD_STOP),
    new Button("GO HOME", bx0 + stopWidth + stopHomeGap, by1, stopWidth - stopHomeGap, BTN_H_BTN, CMD_GO_HOME),
    new Button("CONTINUE", bx1, by1, BTN_W, BTN_H_BTN, CMD_CONTINUE),

    new Button("INTENSIVE", bx0, by2, BTN_W, BTN_H_BTN, CMD_INTENSIVE),
    new Button("SILENT", bx1, by2, BTN_W, BTN_H_BTN, CMD_SILENT),

    new Button("NORMAL SPEED", bx0, by3, BTN_W, BTN_H_BTN, CMD_SPEED_NORMAL),
    new Button("HIGH SPEED", bx1, by3, BTN_W, BTN_H_BTN, CMD_SPEED_HIGH)
  };
}

// =======================================================
// BUTTON CLASS
// =======================================================
class Button {
  String label;
  int col, row, cmd;
  float x, y, w, h;
  boolean custom = true; // always absolute now

  Button(String l, float x, float y, float w, float h, int cmd) {
    label = l;
    this.cmd = cmd;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void draw() {
    drawRect(x, y, w, h, color(80));
  }

  void drawSpecial(int colr) {
    drawRect(x, y, w, h, colr);
  }

  void drawRect(float x, float y, float w, float h, int colr) {
    fill(colr);
    rect(x, y, w, h, 20);
    fill(255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
  }

  boolean hit(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}
