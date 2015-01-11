int w, h;

float s = 100;

Point p1, p2, p3, p4;

Point np1 = new Point(0, 0), 
      np2 = new Point(0, s), 
      np3 = new Point(s, s), 
      np4;

PGraphics buffer = null;

void setup() {
  size(800, 800);
  w = width/2;
  h = height/2;
  noLoop();

  p1 = new Point(random(w), random(h));
  p2 = new Point(random(w), random(h));
  p3 = new Point(random(w), random(h));
  p4 = new Point(random(w), random(h));

  buffer = CanonicalLayout.create(this,width,height,s);
}

void draw() {
  noFill();
  image(buffer, 0, 0);
  translate(w, h);
  // canonically transformed last point: 
  np4 = CanonicalLayout.forwardTransform(p1, p2, p3, p4, s);
  // translated canonical point based on mouse interaction
  Point moved = new Point(np4.x + dx, np4.y + dy);
  // render the curve
  f(np1, np2, np3, moved, 150, 0, 150);
  // show move point  
  ellipse(moved.x, moved.y, 5, 5);  
  fill(0);
  text("("+(moved.x/s)+","+(moved.y/s)+")", moved.x+5, moved.y);
  // reconstructed original curve, based on the moved fourth point
  Point op4 = CanonicalLayout.backwardTransform(p1, p2, p3, p4, dx, dy, s);
  inset(-w, h/2, w*0.75, h/2, p1, p2, p3, p4, op4);
  // mouse handling...
  if (commitDelta) {
    commitDelta = false;
    p4.x = op4.x;
    p4.y = op4.y;
    dx = 0;
    dy = 0;
  }
}

// curve visualisation

void f(Point p1, Point p2, Point p3, Point p4, int r, int g, int b) {
  strokeWeight(2);
  stroke(r, g, b, 50);
  line(p1.x, p1.y, p2.x, p2.y);
  line(p3.x, p3.y, p4.x, p4.y);
  ellipse(p2.x, p2.y, 3, 3);
  ellipse(p3.x, p3.y, 3, 3);

  strokeWeight(1);
  stroke(r, g, b);
  bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
  ellipse(p1.x, p1.y, 3, 3);
  ellipse(p2.x, p2.y, 3, 3);
  ellipse(p3.x, p3.y, 3, 3);
  ellipse(p4.x, p4.y, 3, 3);
}

void inset(float x, float y, float w, float h, Point p1, Point p2, Point p3, Point p4, Point op4) {
  fill(255);
  stroke(155);
  rect(x, y, w, h);
  x += 20;
  y += 20;
  w -= 40;
  h -= 40;
  // scale points to fit inside (0,0)--(w,h)
  Point[] ps = {
    p1, p2, p3, p4, op4
  };
  float minx=999999, miny=minx, maxx=-minx, maxy=maxx;
  for (Point p : ps) {
    if (p.x<minx) minx = p.x;
    if (p.x>maxx) maxx = p.x;
    if (p.y<miny) miny = p.y;
    if (p.y>maxy) maxy = p.y;
  }
  // scale points to fit the inset
  float sx = w / (maxx-minx), sy = h / (maxy-miny);
  Point[] np = {
    new Point( x + sx * (p1.x - minx), y + sy * (p1.y - miny)), 
    new Point( x + sx * (p2.x - minx), y + sy * (p2.y - miny)), 
    new Point( x + sx * (p3.x - minx), y + sy * (p3.y - miny)), 
    new Point( x + sx * (p4.x - minx), y + sy * (p4.y - miny)), 
    new Point( x + sx * (op4.x - minx), y + sy * (op4.y - miny))
  };
  line(np[0].x, np[0].y, np[1].x, np[1].y);
  line(np[2].x, np[2].y, np[4].x, np[4].y);
  stroke(0);
  ellipse(np[1].x, np[1].y, 3, 3);
  ellipse(np[2].x, np[2].y, 3, 3);
  noFill();  
  bezier(
  np[0].x, np[0].y, 
  np[1].x, np[1].y, 
  np[2].x, np[2].y, 
  np[4].x, np[4].y
    );
  fill(50);
  text("true curve", x-10, y);
}  

// mouse interaction

boolean mouseDown = false, commitDelta = false;
float markx, marky;
float dx, dy;
void mousePressed() {
  noCursor();
  markx = mouseX;
  marky = mouseY;
  mouseDown = true;
}
void mouseReleased() {
  cursor();
  mouseDown = false;
  commitDelta = true;
  redraw();
}
void mouseDragged() {
  noCursor();
  dx = mouseX - markx;
  dy = mouseY - marky;
  redraw();
}

