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
int objects = 128;
// CollisionDetector detector;
// boolean removeBody;

void setup() {
  size(1024, 768);
  frameRate(60);

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
  cancan.play();
}

void draw() {
}

void visualizerRenderer(World world) {
  background(0);
  float ps[] = cancan.getPowerSpectrum();
  int range = ps.length / objects;
  for (int i = 0; i < objects; i++)
  {
    Vec2 worldCenter = bodies[i].getWorldCenter();
    Vec2 pos = physics.worldToScreen(worldCenter);
    float angle = physics.getAngle(bodies[i]);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-angle);
    int red = (int) map(i, 0, objects, 255, 0);
    int green = (int) map(i, 0, objects, 0, 255);
    fill(red, green, 0);
    rect(-size/2, -size / 2, size, size);
    popMatrix();

    // update model
    float p = ps[range*i];
    if (p > 0.25 && bodies[i].getLinearVelocity().length() < 1.0) {
      float dir = random(-1,1);
      println("Dir: " + dir);
      float ix = dir * 3000;
      float iy = 7000 * p;
      Vec2 force = new Vec2(ix, iy);
      bodies[i].applyImpulse(force, bodies[i].getWorldCenter());
    }
  }    
}
  
