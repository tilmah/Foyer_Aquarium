// The Boid class


class Boid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector prey;
  float r;
  float d;
  float outCam;
  float maxforce;    
  float maxspeed;    
  float neighborhoodRadius; 
  boolean hadSay;
  String fishTalk[] = loadStrings("fish_talk.txt");
  String fishLine;
  float wanderTheta;


  //Constructor
  Boid(float locationX, float locationY, float _maxspeed, float _maxforce) {
    acceleration = new PVector(0, 0, 0);
    neighborhoodRadius = 40.0;
    hadSay = false;

    float angle = random(TWO_PI);
    velocity = new PVector(random(0, 1), random(0, 1), random(0, 1));
    location = new PVector(locationX, locationY, 0.0);

    r = 2.0;
    outCam=300.0;
    maxspeed = _maxspeed;
    maxforce = _maxforce;
  }

  //Run 
  void run(ArrayList<Boid> boids) {
    update();
    borders();
  }

  //Update vectors reset acceleration
  void update() {
    avoidWalls();
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }

  void avoidWalls() {
    if (location.y<0.0) {
      PVector desired = new PVector(velocity.x*maxspeed, maxspeed/2, velocity.z);
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
    if (location.y>height) {
      PVector desired = new PVector(velocity.x*maxspeed, -maxspeed/2, velocity.z);
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
    if (location.z<-100) {
      PVector desired = new PVector(velocity.x*maxspeed, velocity.y, maxspeed/2);
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
    if (location.z>10) {
      PVector desired = new PVector(velocity.x*maxspeed, velocity.y, -maxspeed/2);
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
  }

  //Apply the forces
  protected void applyForce(PVector force) {
    acceleration.add(force);
  }

  //Steering with arrival
  private PVector steer(PVector _target, boolean arrival) {
    PVector steer = new PVector(); 
    PVector target = _target;
    if (!arrival)
    {
      steer.set(PVector.sub(target, location));
      steer.limit(maxforce);
    } else
    {
      PVector targetOffset = PVector.sub(target, location);
      float distance=targetOffset.mag();
      float rampedSpeed = maxspeed*(distance/100);
      float clippedSpeed = min(rampedSpeed, maxspeed);
      PVector desiredVelocity = PVector.mult(targetOffset, (clippedSpeed/distance));
      steer.set(PVector.sub(desiredVelocity, velocity));
      steer.limit(maxforce);
    }
    return steer;
  }

  //Seek Target
  protected PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  //Avoid. If weight == true avoidance vector is larger the closer the boid is to the target
  protected void avoid(PVector _target)
  {
    PVector steer = new PVector(0, 0, 0); 
    float dis = PVector.dist(_target, location);//find distance to target
    if (dis>0 && dis<neighborhoodRadius) {
      steer = PVector.sub(_target, location);//angle to target
      steer.mult(1/sqrt(dis)+1);//ramp function
      steer.mult(-1);//flip direction to away
    }
    applyForce(steer);
  }

  //Flee - with Seperate/Scatter
  protected void flee(PVector _target, ArrayList<Boid> boids) {
    PVector flee = steer(_target, false);
    flee.mult(-1);
    PVector sep = separate(boids);   // Separation
    applyForce(flee);
    applyForce(sep);
  }

  //Evade - predicting where the other is going to be
  protected void evade(PVector _target, ArrayList<Boid> boids) {
    float lookAhead = location.dist(_target)/(maxspeed*2);
    PVector predictedTarget = new PVector( _target.x - lookAhead, _target.y - lookAhead, _target.z - lookAhead );
    flee( predictedTarget, boids);
  }

  //Flock
  protected void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);  
    PVector ali = align(boids);      
    PVector coh = cohesion(boids);   

    sep.mult(1.55);
    ali.mult(1.0);
    coh.mult(1.0);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  //Seek and Flock
  protected void seeker(PVector seeking, ArrayList<Boid> boids) {
    PVector desired = PVector.sub(seeking, location); 
    float distance = mag2(desired);  
    PVector seek = steer(seeking, false);
    PVector sep = separate2(boids);   
    PVector ali = align(boids);      
    PVector coh = cohesion(boids); 

    seek.mult(3.0);

    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);

    applyForce(seek);
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }
  //Seperate
  protected PVector separate (ArrayList<Boid> boids)
  {
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid b : boids) {
      float d = PVector.dist(location, b.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < neighborhoodRadius)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, b.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  //Align
  protected PVector align(ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid b : boids) {
      float d = PVector.dist(location, b.location);
      if ((d > 0) && (d < neighborhoodRadius)) {
        sum.add(b.velocity);
        // For an average, we need to keep track of
        // how many boids are within the distance.
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
      //[full] If we don’t find any close boids,
      // the steering force is zero.
    } else {
      return new PVector(0, 0);
    }
    //[end]
  }

  //Cohesion
  protected PVector cohesion (ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid b : boids) {
      float d = PVector.dist(location, b.location);
      if ((d > 0) && (d < neighborhoodRadius)) {
        sum.add(b.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return steer(sum, false);  // Steer towards the location
    } else {
      return new PVector(0, 0, 0);
    }
  }
  protected PVector separate2 (ArrayList<Boid> boids)
  {
    PVector locationSum = new PVector(0, 0, 0);
    PVector repulse;
    for (int i=0; i<boids.size (); i++)
    {
      Boid b = (Boid)boids.get(i);
      float d = PVector.dist(location, b.location);
      if (d>0&&d<=neighborhoodRadius)
      {
        repulse = PVector.sub(location, b.location);
        repulse.normalize();
        repulse.div(d);
        locationSum.add(repulse);
      }
    }
    return locationSum;
  }
  //Wander
  protected void wander() {
    float wanderR   = 5;
    float wanderD   = 100;
    float change   = 0.10;

    wanderTheta += random(-change, change);

    PVector circleLocation = velocity.copy();
    circleLocation.normalize();
    circleLocation.mult( wanderD );
    circleLocation.add( location );

    PVector circleOffset = new PVector(wanderR*sin(wanderTheta), wanderR*cos(wanderTheta), wanderR*tan(wanderTheta));
    float xC, yC, zC;
    xC = circleOffset.x;
    yC = circleOffset.y;
    zC = circleOffset.z;
    if (yC > .2) {
      yC = .2;
    }
    circleOffset.set(xC, yC, zC);
    PVector target= PVector.add(circleLocation, circleOffset);

    seek(target);
  }

  //Check Borders
  protected void borders() {
    if (location.x < 0.0-outCam) location.x = width+outCam; //wrap
    if (location.x > width+outCam) location.x = 0-outCam; //wrap

    //if (location.y < 0.0-outCam) location.y = height+outCam; //wrap
    //if (location.y > height+outCam) location.y = 0-outCam; //wrap

    //if (location.z < -width-outCam) location.z = 0.0+outCam; //wrap
    //if (location.z > outCam) location.z = -width; //wrap
  }

  //Mag Function
  protected float mag2(PVector v) {
    return (v.x*v.x + v.y*v.y + v.z*v.z);
  }
  //Fish Talk
  public void followingText(String _line) {
    float bubLen = _line.length()*6;
    PVector bubPos = new PVector(location.x+bubLen/2,location.y-27.75);
    float ang1 = PVector.angleBetween(location,bubPos);
    fill(255);
    pushMatrix();
    translate(0,0,location.z-5);
    rect(location.x-5, location.y-32.5, bubLen+10, 20);
    triangle(location.x,location.y-10,bubPos.x+10*sin(ang1+-90),bubPos.y+10*cos(ang1+-90),bubPos.x+10*sin(ang1+90),bubPos.y+10*cos(ang1+90));
    popMatrix();
    textFont(secrcode);
    fill(0);
    text(_line, location.x, location.y-20.0, location.z);
  }
}