class Fader {
  private int x, y;
  private String label;
  private int cursorWidth = 20;
  private int cursorHeight = 30;
  private int faderWidth = 300;
  private int faderHeight = 10;
  private int minCursorX, maxCursorX;
  private int cursorX, cursorY;
  private boolean dragging = false;
  private PFont f;
  
  Fader(int ix, int iy, String ilabel) {
    x = ix;
    y = iy;
    int hcw = cursorWidth / 2;
    minCursorX = x - hcw;
    maxCursorX = x + faderWidth - hcw;
    cursorX = x + faderWidth / 2 - hcw;
    cursorY = y + faderHeight /2 - cursorHeight / 2;
    f = createFont("Arial", 16, true);
    label = ilabel;
  }
  
  float getValue() {
    return map(cursorX, minCursorX, maxCursorX, 0.0f, 1.0f);
  }
  
  void draw() {
    strokeWeight(0);
    fill(128,128,128);
    rect(x, y, faderWidth, faderHeight);
    stroke(200,200,200);
    strokeWeight(2);
    rect(cursorX, cursorY, cursorWidth, cursorHeight);
    textFont(f, 16);
    text(label, x + faderWidth + 20, y + faderHeight);
  }
  
  void mousePressed() {
    int tx = mouseX - cursorX;
    int ty = mouseY - cursorY;
    
    if (tx > 0 && tx < cursorWidth && ty > 0 && ty < cursorHeight)
      dragging = true;
  }

  void mouseReleased() {
    dragging = false;
  }
  
  void mouseDragged() {
    if (dragging) {
      cursorX = mouseX - cursorWidth / 2;
      if (cursorX < minCursorX)
        cursorX = minCursorX;
      if (cursorX > maxCursorX)
        cursorX = maxCursorX;
    }
  }
}
