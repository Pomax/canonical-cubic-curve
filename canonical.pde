int w, h;

float s = 100;

Point p1, p2, p3, p4;

Point np1 = new Point(0, 0), 
      np2 = new Point(0, s), 
      np3 = new Point(s, s), 
      np4;

Point[] pts;

PGraphics buffer = null, canonical = null;

void setup() {
  size(1200, 800);
  w = height/2;
  h = height/2;
  noLoop();

  p1 = new Point(random(width-2*w), random(height));
  p2 = new Point(random(width-2*w), random(height));
  p3 = new Point(random(width-2*w), random(height));
  p4 = new Point(random(width-2*w), random(height));
  
  pts = new Point[]{p1,p2,p3,p4};
  
  buffer = CanonicalLayout.create(this,2*w,2*h,s);
  canonical = createGraphics(2*w, 2*h);
}

void draw() {
  background(255);
  
  if(mouseDown && !onAnalysis) {
    handlePointMovement();
  }
  
  np4 = CanonicalLayout.forwardTransform(p1, p2, p3, p4, s);
  Point moved = onAnalysis ? new Point(np4.x + dx, np4.y + dy) : np4;

  canonical.beginDraw();
  canonical.image(buffer, 0, 0);
  f(canonical, w, h, np1, np2, np3, moved, 150, 0, 150);
  canonical.endDraw();
  image(canonical, width - 2*w, 0);

  Point op4 = onAnalysis ? CanonicalLayout.backwardTransform(p1, p2, p3, p4, dx, dy, s) : p4;
  inset(p1, p2, p3, onAnalysis ? op4 : p4);
  // mouse handling...
  if (commitDelta) {
    commitDelta = false;
    if(onAnalysis) {
      p4.x = op4.x;
      p4.y = op4.y;
    } else {}
    dx = 0;
    dy = 0;
  }
}

// curve visualisation

void f(PGraphics context, float tx, float ty, Point p1, Point p2, Point p3, Point p4, int r, int g, int b) {
  context.translate(tx,ty);
  context.noFill();
  
  context.strokeWeight(2);
  context.stroke(r, g, b, 50);
  context.line(p1.x, p1.y, p2.x, p2.y);
  context.line(p3.x, p3.y, p4.x, p4.y);
  context.ellipse(p2.x, p2.y, 3, 3);
  context.ellipse(p3.x, p3.y, 3, 3);

  context.strokeWeight(1);
  context.stroke(r, g, b);
  context.bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
  context.ellipse(p1.x, p1.y, 3, 3);
  context.ellipse(p2.x, p2.y, 3, 3);
  context.ellipse(p3.x, p3.y, 3, 3);
  context.ellipse(p4.x, p4.y, 3, 3);

  context.ellipse(p4.x, p4.y, 5, 5);  
  context.fill(0);
  context.text("("+(p4.x/s)+","+(p4.y/s)+")", p4.x+5, p4.y);
  context.translate(-tx,-ty);
}

void inset(Point p1, Point p2, Point p3, Point p4) {
  fill(255);
  stroke(155);
  line(p1.x,p1.y,p2.x,p2.y);
  line(p3.x,p3.y,p4.x,p4.y);
  stroke(0);
  ellipse(p2.x,p2.y, 3, 3);
  ellipse(p3.x,p3.y, 3, 3);
  noFill();  
  bezier(
    p1.x, p1.y, 
    p2.x, p2.y, 
    p3.x, p3.y, 
    p4.x, p4.y
  );
  fill(50);
  text("true curve", 10, 10);
}  

// mouse interaction

void handlePointMovement() {
  tomove.x = refpoint.x + dx;
  tomove.y = refpoint.y + dy;
}

boolean mouseDown = false,
        commitDelta = false,
        onAnalysis = false;
Point tomove = null;
Point refpoint = null;
float markx, marky;
float dx, dy;

void mousePressed() {
  noCursor();
  markx = mouseX;
  marky = mouseY;
  mouseDown = true;
  onAnalysis = (mouseX >= width-2*w);
  for(Point p: pts) {
    if(p.over(mouseX, mouseY)) {
      tomove = p;
      refpoint = new Point(p.x,p.y);
      cursor(HAND);
    }
  }
}

void mouseMoved() {
  for(Point p: pts) {
    if(p.over(mouseX, mouseY)) {
      cursor(HAND);
    }
  }
}

void mouseReleased() {
  cursor();
  mouseDown = false;
  commitDelta = true;
  tomove = null;
  redraw();
}

void mouseDragged() {
  noCursor();
  dx = mouseX - markx;
  dy = mouseY - marky;
  redraw();
}

