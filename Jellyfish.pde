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

class Tentacle {
  static final int MAX_NUM_PARTICLES = 2048;
  static final int MAX_NUM_SPRINGS = 2048;
  Particle[] particles = new Particle[MAX_NUM_PARTICLES];
  Spring[] springs = new Spring[MAX_NUM_SPRINGS];
  float widthR;
  float partWidth;
  float radius;
  int numberOfInstances = int(random(7, 14));
  PVector velocity;

  public Tentacle(float locX, float locY, float radiusUp, int number, int outOf) {
    radius = radiusUp;
    Particle startParticle = new Particle((radius/outOf)*(number)-(radius/2)+((radius/outOf)/2), 10.0, 0.0);

    for (int i = 0; i < numberOfInstances; i++) {
      Particle endParticle = new Particle(0.0,10.0, 0.0);
      particles[i] = endParticle;
      springs[i] = new Spring(startParticle, endParticle);

      startParticle = endParticle;
    }
    widthR = radius;
    Particle p = springs[0].startParticle;
    partWidth = widthR-p.posX;
  }



  public void update(float radiusUp, float locY, PVector vel) {
    velocity = vel;
    velocity.normalize();
    radius = radiusUp;
    for (int i = 0; i < numberOfInstances; i++) {
      springs[i].update();
    }
    for (int i = 0; i < numberOfInstances; i++) {
      particles[i].update();
      for (int j = i; j < numberOfInstances; j++) {
        //              particles[i].bounce(particles[j]);
      }
    }
    Particle p = springs[0].startParticle;
    //float perCent = (widthR-p.posX);
    p.posX = (-1*radius)+(radius*(partWidth/widthR));
    p.posY = locY;
    render();
  }
  public void render() {
    for (int i = 0; i < numberOfInstances; i++) {
      Spring spring = springs[i];
      ellipse((float) spring.startParticle.posX, 
      (float) spring.startParticle.posY, (5-(i*.3)), (5-(i*.3)));
      /*line((float) spring.startParticle.posX, 
       (float) spring.startParticle.posY, 
       (float) spring.endParticle.posX, 
       (float) spring.endParticle.posY);*/
    }
  }
}
class Spring {
  private double dt;
  static final double SPRING_FORCE = 3.0;
  Particle startParticle;
  Particle endParticle;


  Spring(Particle start, Particle end) {
    startParticle = start;
    endParticle = end;
    dt = 0.05;
  }

  void update() {
    applySpringForce();
  }

  void applySpringForce() {
    startParticle.vX += (endParticle.posX - startParticle.posX)
      * SPRING_FORCE * dt;
    startParticle.vY += (endParticle.posY - startParticle.posY)
      * SPRING_FORCE * dt;
    endParticle.vX += (startParticle.posX - endParticle.posX)
      * SPRING_FORCE * dt;
    endParticle.vY += (startParticle.posY - endParticle.posY)
      * SPRING_FORCE * dt;
  }
}
class Particle {
  static final double GRAVITY = 3;
  static final double BOUNCE_DAMPENING = 1.0;
  static final double RESISTANCE = 5.0;
  private double dt;
  float posX;
  float posY;

  double vX = 0;
  double vY = 0;

  float radius;

  Particle(float x, float y, float r) {
    posX = x;
    posY = y;
    radius = r;
    dt = 0.1;
  }

  float getVelocity() {
    return sqrt((float) (vX * vX + vY * vY));
  }

  float getMotionDirection() {
    return atan2((float) vX, (float) vY);
  }

  void update() {
    // apply resistance
    double v = getVelocity()*0.01;
    float r = (float) max((float)0, (float) (1 - RESISTANCE*v*v));
    vX *= r;
    vY *= r;

    // apply Gravity
    vY += GRAVITY * dt;

    posX += vX * dt;
    posY += vY * dt;
  }

  void bounce(Particle theOtherParticle) {
    if (sqrt(pow((float) (theOtherParticle.posX - posX), 2)
      + pow((float) (theOtherParticle.posY - posY), 2)) < (theOtherParticle.radius + radius)) {
      if (sqrt(pow((float) (theOtherParticle.posX - posX), 2)
        + pow((float) (theOtherParticle.posY - posY), 2)) > sqrt(pow(
      (float) (theOtherParticle.posX + theOtherParticle.vX
        - posX - vX), 2)
        + pow((float) (theOtherParticle.posY
        + theOtherParticle.vY - posY - vY), 2))) {

        float commonTangentAngle = atan2(
        (float) (posX - theOtherParticle.posX), 
        (float) (posY - theOtherParticle.posY))
          + asin(1);

        float v1 = theOtherParticle.getVelocity();
        float v2 = getVelocity();
        float w1 = theOtherParticle.getMotionDirection();
        float w2 = getMotionDirection();

        theOtherParticle.vX = sin(commonTangentAngle) * v1
          * cos(w1 - commonTangentAngle)
          + cos(commonTangentAngle) * v2
            * sin(w2 - commonTangentAngle);
        theOtherParticle.vY = cos(commonTangentAngle) * v1
          * cos(w1 - commonTangentAngle)
          - sin(commonTangentAngle) * v2
            * sin(w2 - commonTangentAngle);
        vX = sin(commonTangentAngle) * v2
          * cos(w2 - commonTangentAngle)
          + cos(commonTangentAngle) * v1
            * sin(w1 - commonTangentAngle);
        vY = cos(commonTangentAngle) * v2
          * cos(w2 - commonTangentAngle)
          - sin(commonTangentAngle) * v1
            * sin(w1 - commonTangentAngle);

        theOtherParticle.vX *= (1 - BOUNCE_DAMPENING);
        theOtherParticle.vY *= (1 - BOUNCE_DAMPENING);
        vX *= (1 - BOUNCE_DAMPENING);
        vY *= (1 - BOUNCE_DAMPENING);
      }
    }
  }
//  public PVector getPos() {
//     return location;
//  }
}