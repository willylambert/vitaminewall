class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  boolean _visible;
  
  PGraphics _g;

  HScrollbar (float xp, float yp, int sw, int sh, int l,PGraphics g) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    _g = g;
  }

  void setVisible(boolean visible){
    _visible = visible;
  }

  void update(int mx,int my,boolean mpressed) {
    if (overEvent(mx,my)) {
      over = true;
    } else {
      over = false;
    }
    if (mpressed && over) {
      locked = true;
    }
    if (!mpressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mx-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent(int mx,int my) {
    if (mx > xpos && mx < xpos+swidth &&
       my > ypos && my < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    if(_visible){
      _g.noStroke();
      _g.fill(204);
      _g.rect(xpos, ypos, swidth, sheight);
      if (over || locked) {
        _g.fill(0, 0, 0);
      } else {
        _g.fill(102, 102, 102);
      }
      _g.rect(spos, ypos, sheight, sheight);
    }
  }

  float getValue() {
    print("scrollValue : " +((spos - xpos)/swidth)*100); 
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return ((spos - xpos)/swidth)*100;
  }
}
