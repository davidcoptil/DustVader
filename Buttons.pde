Button[] buttons;

// layout params (these can stay here or be passed in if you want later)

float BTN_WIDTH_RATIO  = 0.38;
float BTN_HEIGHT_RATIO = 0.10;

float BTN_GAP_X_RATIO = 1.15;
float BTN_GAP_Y_RATIO = 1.3;

float BTN_OFFSET_Y_RATIO = 0.4;


// calculated values

float BTN_AREA_Y;
float BTN_AREA_H;

float BTN_W;
float BTN_H_BTN;

float BTN_SPACING_X;
float BTN_SPACING_Y;

float BTN_START_X;
float BTN_START_Y;


// =======================================================
// INIT
// =======================================================

void ButtonsInit() {

  BTN_AREA_Y = height * BTN_OFFSET_Y_RATIO;
  BTN_AREA_H = height - (height * BTN_OFFSET_Y_RATIO);

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

  for (Button b : buttons)
    b.draw();
}


// =======================================================
// INPUT
// =======================================================

void ButtonsHandleClick(float mx, float my) {
  for (Button b : buttons)
    if (b.hit(mx, my))
      execute(b.cmd);   // uses main file function
}


// =======================================================
// CREATE
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
// BUTTON CLASS
// =======================================================

class Button {

  String label;
  int col, row, cmd;

  Button(String l, int c, int r, int cmd) {
    label = l;
    col = c;
    row = r;
    this.cmd = cmd;
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

  boolean hit(float mx, float my) {

    float cx = BTN_START_X + col * BTN_SPACING_X;
    float cy = BTN_START_Y + row * BTN_SPACING_Y;

    float x = cx - BTN_W/2;
    float y = cy - BTN_H_BTN/2;

    return mx > x && mx < x + BTN_W &&
           my > y && my < y + BTN_H_BTN;
  }
}
