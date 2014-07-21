import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

Maxim maxim;
AudioPlayer cancan;
Physics physics;
Body bodies[];
int size = 10;
int objects = 64;
float maxV = 1;
float maxP = 0.1;

// CollisionDetector detector;
// boolean removeBody;

void setup() {
  size(1024, 768);
  frameRate(60);
  background(0);
  physics = new Physics(this, width, height);
  physics.setCustomRenderingMethod(this, "visualizerRenderer");
  physics.setDensity(100.0);
  
  // Create bodies
  bodies = new Body[objects];
  for (int i = 0; i < objects; i++) {
    int x1 = (width / (objects + 1)) * (1 + i) - size / 2;
    int x2 = x1 + size;
    int y1 = height - size;
    int y2 = height;
    bodies[i] = physics.createRect(x1, y1, x2, y2);
  }
   
  // detector = new CollisionDetector(physics, this);
  maxim = new Maxim(this);
  cancan = maxim.loadFile("cancan.wav");
  cancan.speed(.5);
  cancan.setAnalysing(true);
  cancan.setLooping(false);
  cancan.play();
}

void draw() {
}

void visualizerRenderer(World world) {
  fill(0, 5);
  rect(0, 0, width, height);
  strokeWeight(0);
  float ps[] = reducedSpectrum();

  for (int i = 0; i < objects; i++)
  {
    float v = bodies[i].getLinearVelocity().length();
    if (v > maxV) {
      maxV = v;
    }
    Vec2 worldCenter = bodies[i].getWorldCenter();
    Vec2 pos = physics.worldToScreen(worldCenter);
    float angle = physics.getAngle(bodies[i]);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-angle);
    int red = (int) map(i, 0, objects, 255, 0);
    int green = (int) map(i, 0, objects, 0, 255);
    int blue = (int) map(v, 0, maxV, 0, 255);
    fill(red, green, blue);
    rect(-size/2, -size / 2, size, size);
    popMatrix();

    if (cancan.isPlaying()) {
      // update model
      float p = ps[i];
      if (p > maxP)
        maxP = p;
        
      // Random choose 10% of the block to move around
      if (p <= 0.01 && random(1, 100) > 90)
        p = maxP;
      if (p > 0.25 && v < 1.0) {
        float dir = random(-1,1);
        float ix = dir * 3000;
        float iy = 7000 * p;
        Vec2 force = new Vec2(ix, iy);
        bodies[i].applyImpulse(force, bodies[i].getWorldCenter());
      }
    }
  }    
}

float[] reducedSpectrum() {
  float[] acc = new float[objects];
  float[] c = new float[objects];
  float[] sp = cancan.getPowerSpectrum();
  int range = round(sp.length / objects + 0.5);
  for (int i = 0; i < objects; i++) {
    acc[i] = 0.0f;
    c[i] = 0.0f;
  }
  for (int i = 0; i < sp.length; i++) {
    int acci = i / range;
    acc[acci] += sp[i];
    c[acci]++;
  }
  for (int i = 0; i < objects; i++) {
    if (c[i] < 1)
      c[i] = 1;
    acc[i] /= c[i];
  }
  return acc;
}
