class Jellyfish {
  ArrayList<Tentacle> t;
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector target;
  float wanderTheta;
  Body body;
  float outCam;
  boolean gainSwitch=false;

  public Jellyfish(float locX, float locY, int size) {
    location = new PVector(locX, locY, 0);
    velocity = new PVector(random(-1.0, 1), -3.0, 0);
    acceleration = new PVector(0, 0, 0);
    int numTentacles = 9;

    outCam = 200.0;

    t = new ArrayList<Tentacle>();

    body = new Body(0.0, 0.0, 0.1,size);

    for (int i = 0; i < numTentacles; i++) {
      t.add(new Tentacle(locX, locY, body.radius, i, numTentacles));
    }
  }

  void update() {
    //seek(target);
    wander2();
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(body.getSpeed());
    location.add(velocity);
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);
    borders();
    //if near middle
    //if (location.x > width*.2 && location.x < width*.8 && location.y>height*.2 && location.y<height*.8 && !gainSwitch) {
   //int gainCurrent = getGain();
   // sndBass.setGain(gainCurrent+20);
   // gainswitch =true;
 // }
  //  } else if gainSwitch{
  //  
  //  }
    pushMatrix();
    translate(location.x, location.y);
    PVector rot = velocity;
    rot.normalize();
    rotate((PI)+atan2(-1*(rot.x), rot.y));
    fill(255);
    //rotate(PI/270);
    for (Tentacle tent : t ) {
      tent.update(1*(body.getRadius()), -2*(body.ha*1.2)+10, velocity);  // Passing the entire list of boids to each boid individually
    }
    body.update(0, 0, velocity);
    popMatrix();
  }

  //Vector Maths
  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
    acceleration.limit(1+(body.getSpeed()*5.0));
  }
  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  void seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(body.getSpeed());

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(body.getSpeed());  // Limit to maximum steering force
    applyForce(steer);
  }
  void wander2() {
    float wanderR   = 3;
    float wanderD   = 900;
    float change   = 0.01;

    wanderTheta += random(-change, change);

    PVector circleLocation = velocity.copy();
    circleLocation.normalize();
    circleLocation.mult( wanderD );
    circleLocation.add( location );

    PVector circleOffset = new PVector(wanderR*sin(wanderTheta), wanderR*cos(wanderTheta));
    float xC, yC, zC;
    xC = circleOffset.x;
    yC = circleOffset.y;
    //zC = circleOffset.z;
    if (yC > .2) {
      yC = .2;
    }
    circleOffset.set(xC, yC, 0.0);
    PVector target= PVector.add(circleLocation, circleOffset);

    seek( target );
  }

  // Wraparound
  void borders() {
    if (location.x < -outCam) location.x = width+outCam;
    if (location.y < -outCam) location.y = height+outCam;
   // if (location.z < -250) location.z = (width+outCam);
    if (location.x > width+outCam) location.x = -outCam;
    if (location.y > height+outCam) location.y = -outCam;
   // if (location.z > (outCam)) location.z = -250;
  }
}
class Body {
  float radius;
  float midX;
  float ha;
  float radius2;
  float ha2;
  float radius_ini;
  float radius_ini2;
  float ha_ini;
  float x, y, z;

  int segments;
  int steps;

  float fpsSpeed;
  float fpsSpeedFactor;
  float speed;
  float maxSpeed;

  PVector location;
  PVector velocity;
  boolean isVertexNormalActive = false;

  Body(float locX, float locY, float spd, float _radius) {
    radius = _radius/2;
    midX = _radius*0.416;
    radius2 = _radius*0.80;
    ha = -1*(_radius/6);
    ha2 = -1*(_radius/5);
    radius_ini = (_radius/6)*7;
    radius_ini2 = _radius/2;
    ha_ini = ha;

    segments = 18;
    steps = 8;

    fpsSpeedFactor = random(20.0, 24.0);
    location = new PVector(locX, locY, 0.0);

    speed = spd;
    maxSpeed= 1.0;
  }

  void update(float locX, float locY, PVector vel) {
    location = new PVector(locX, locY, 0.0);
    velocity = vel;
    velocity.normalize();
    // expand / contract motion
    // using sin & cos waves
    fpsSpeed = frameCount / fpsSpeedFactor;
    radius = (radius_ini * 0.5) +  (1.0 + sin(fpsSpeed)) * (radius_ini * 0.2);
    radius2 = (radius_ini2 * 0.5) +  (1.0 - sin(fpsSpeed)) * (radius_ini2 * 0.2);
    ha     = (ha_ini * 0.9)     +  (1.0 + cos(fpsSpeed)) * (ha_ini * 0.1);
    ha2     = (ha_ini * 0.9)     +  (1.0 + cos(fpsSpeed)) * (ha_ini * 0.1);
    display();
  }

  void display() {
    fill(255);
    rect(location.x-radius2/2, location.y, radius2, ha2);//top part
    rect(location.x-radius/2, location.y+midX, radius, ha*1.2);//bottom part
  }

  float getSpeed() {
    speed = maxSpeed-radius*.01;
    return speed;
  }
  float getRadius() {
    return radius;
  }
}