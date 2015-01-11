static class CanonicalLayout {
  
  // we along translate the past point, because we know what the other three points will be, by convention.
  static Point forwardTransform(Point p1, Point p2, Point p3, Point p4, float s) {   
    float xn = -p1.x + p4.x - (-p1.x+p2.x)*(-p1.y+p4.y)/(-p1.y+p2.y); 
    float xd = -p1.x + p3.x - (-p1.x+p2.x)*(-p1.y+p3.y)/(-p1.y+p2.y);
    float np4x = s*xn/xd;
  
    float yt1 = s*(-p1.y+p4.y) / (-p1.y+p2.y);  
    float yt2 = s - (s*(-p1.y+p3.y)/(-p1.y+p2.y));
    float yp = yt2 * xn / xd;
    float np4y = yt1 + yp;
  
    return new Point(np4x, np4y);
  }
  
  // the back-translation is equally easy, since we already know the first three coordinates. we just convert point 4.
  static Point backwardTransform(Point p1, Point p2, Point p3, Point p4, float dx, float dy, float s) {
    return new Point(
      (-dy * p1.x + (-dx+dy)*p2.x + dx*p3.x + s*p4.x) / s, 
      (-dy * p1.y + (-dx+dy)*p2.y + dx*p3.y + s*p4.y) / s
    );
  }
  
  static PGraphics create(PApplet sketch, int width, int height, float s) {
    int w = width / 2;
    int h = height / 2;

    PGraphics buffer = sketch.createGraphics(width, height);
    buffer.beginDraw();
    buffer.background(255);
    buffer.translate(w, h);
    buffer.stroke(150);
    for (int i=-w; i<=w; i+=100) { 
      buffer.line(i, -h, i, h);
    }
    for (int i=-h; i<=h; i+=100) { 
      buffer.line(-w, i, w, i);
    }
    buffer.stroke(0);
    buffer.line(0, -h, 0, h);
    buffer.line(-w, 0, w, 0);

    buffer.stroke(120, 120, 160);
    buffer.fill(0, 255, 0, 50);
    buffer.rect(-w, h/4, 2*w, h);
    buffer.fill(255, 0, 0, 50);
    buffer.beginShape();

    // Do some canonical curve work, following Stone and DeRose,
    // "A Geometric Characterization of Parametric Cubic Curves"
    float B3x, B3y, A, B, C, discriminant, epsilon = 0.01, px=-w*2, py=-h*2;
    for (float x=-10; x<=10; x+=0.01) {
      for (float y=-10; y<=10; y+=0.01) {
        B3x = x;
        B3y = y;
        A = 9 * (x + y - 3);
        B = -9 * (x - 3);
        C = -9;
        // Cusp line
        discriminant = x*x - 2 * x + 4 * y - 3;
        if (-epsilon < discriminant && discriminant < epsilon) {
          buffer.line(px, py, x*s, y*s);
          px = x*s;
          py = y*s;
          if (x<1) buffer.vertex(px, py);
        }
      }
    }

    // loop/arch transition boundary, elliptical section
    px=1*s;
    py=1*s;
    for (float x=1, y; x>=0; x-=0.005) {
      y = 0.5 * (sqrt(3) * sqrt(4*x - x*x) - x);
      buffer.line(px, py, x*s, y*s);
      px = x*s;
      py = y*s;
      buffer.vertex(px, py);
    }

    // loop/arch transition boundary, parabolic section
    px=0;
    py=0;
    for (float x=0, y; x>-w; x-=0.01) {
      y = (-x*x + 3*x)/3;
      buffer.line(px, py, x*s, y*s);
      px = x*s;
      py = y*s;
      buffer.vertex(px, py);
    }
    buffer.endShape();

    // Single inflection line y=3-x
    //buffer.line(-w*2, 3*s + w*2, w*2, 3*s - w*2);

    buffer.fill(0);
    buffer.textAlign(CENTER, CENTER);
    buffer.textFont(sketch.createFont("Arial", 24));
    buffer.text("Canonical Curve", w*0.75, -h+20);

    buffer.text("simple arch", 100, -150);
    buffer.text("loop", -175, -175);
    buffer.text("double inflection", -270, -50);
    buffer.text("single inflection", 0, 250);
    buffer.text("no inflections", 320, 65);

    buffer.textFont(sketch.createFont("Arial", 16));
    buffer.text("cusp line", 180, 80);
    buffer.text("loop on t=0 line", -100, -250);
    buffer.text("loop on t=1 line", 80, 60);

    buffer.text("(0,0)", 0-20, 0+10);
    buffer.text("(0,1)", 0-20, s+10);
    buffer.text("(1,1)", s-20, s+10);

    buffer.endDraw();
  
    return buffer;    
  }
}
