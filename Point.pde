static class Point { 
  float x, y; 
  public Point(float _x, float _y) { 
    x=_x; 
    y=_y;
  }
  boolean over(float x, float y) {
    return abs(x-this.x) < 3 && abs(y-this.y) < 3;
  }
}

