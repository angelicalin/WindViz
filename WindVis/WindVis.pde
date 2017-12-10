// uwnd stores the 'u' component of the wind.
// The 'u' component is the east-west component of the wind.
// Positive values indicate eastward wind, and negative
// values indicate westward wind.  This is measured
// in meters per second.
Table uwnd;

// vwnd stores the 'v' component of the wind, which measures the
// north-south component of the wind.  Positive values indicate
// northward wind, and negative values indicate southward wind.
Table vwnd;

// An image to use for the background.  The image I provide is a
// modified version of this wikipedia image:
//https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg
// If you want to use your own image, you should take an equirectangular
// map and pick out the subset that corresponds to the range from
// 135W to 65W, and from 55N to 25N
PImage img;
Particle[] particles = new Particle[2000];

void setup() {
  // If this doesn't work on your computer, you can remove the 'P3D'
  // parameter.  On many computers, having P3D should make it run faster
  size(700, 400, P3D);
  pixelDensity(displayDensity());
  
  img = loadImage("background.png");
  uwnd = loadTable("uwnd.csv");
  vwnd = loadTable("vwnd.csv");
  
  for (int i = 0; i < 2000; i++){
    particles[i] = new Particle();
  }
}

void draw() {
  background(255);
  image(img, 0, 0, width, height);
  drawMouseLine();
  drawParticles();
}

void drawParticles(){
  stroke(color(255, 0, 0));
  strokeWeight(4);
  beginShape(POINTS);
  for (Particle p: particles){
    vertex(p.getX(), p.getY());
  }
  endShape();
  
  for (Particle p: particles){
    p.decreaseLife();
    float a = p.getX() * uwnd.getColumnCount() / width;
    float b = p.getY() * uwnd.getRowCount() / height;
    float newX = readInterp(uwnd, a, b)*0.1+p.getX();
    float newY = -readInterp(vwnd, a, b)*0.1+p.getY();
    p.updateLocation(newX, newY);
  }
}

void rungeKutta(float initial, float di){
  float k1 = di;
  float k2 = initial;
}

void drawMouseLine() {
  // Convert from pixel coordinates into coordinates
  // corresponding to the data.
  float a = mouseX * uwnd.getColumnCount() / width;
  float b = mouseY * uwnd.getRowCount() / height;
  
  // Since a positive 'v' value indicates north, we need to
  // negate it so that it works in the same coordinates as Processing
  // does.
  float dx = readInterp(uwnd, a, b) * 10;
  float dy = -readInterp(vwnd, a, b) * 10;
  line(mouseX, mouseY, mouseX + dx, mouseY + dy);
}

// Reads a bilinearly-interpolated value at the given a and b
// coordinates.  Both a and b should be in data coordinates.
float readInterp(Table tab, float a, float b) {
  int x1 = int(a);
  int y1 = int(b);
  int x2 = int(a)+1;
  int y2 = int(b)+1;
  // TODO: do bilinear interpolation
  float q11 = readRaw(tab, x1, y1);
  float q12 = readRaw(tab, x1, y2);
  float q21 = readRaw(tab, x2, y1);
  float q22 = readRaw(tab, x2, y2);
  
  float fxy1 = ((float)x2-a)/((float)x2-(float)x1)*q11 + (a-x1)/((float)x2-(float)x1)*q21;
  float fxy2 = ((float)x2-a)/((float)x2-(float)x1)*q12 + (a-x1)/((float)x2-(float)x1)*q22;
  float fxy = ((float)y2-b)/((float)y2-(float)y1)*fxy1 + (b-y1)/((float)y2-(float)y1)*fxy2;

  return fxy;
}

// Reads a raw value 
float readRaw(Table tab, int x, int y) {
  if (x < 0) {
    x = 0;
  }
  if (x >= tab.getColumnCount()) {
    x = tab.getColumnCount() - 1;
  }
  if (y < 0) {
    y = 0;
  }
  if (y >= tab.getRowCount()) {
    y = tab.getRowCount() - 1;
  }
  return tab.getFloat(y,x);
}