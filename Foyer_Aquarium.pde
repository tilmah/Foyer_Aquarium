
//Hand Size
float handSize=50.0;

//Shark
Shark shark;

//Fish
Flock flock;

//Jellyfish
Jellyfish jelly1;
Jellyfish jelly2;
Jellyfish jelly3;

//Bubbles
ArrayList<Bubble> bubbles = new ArrayList<Bubble>();

int border;

// Set number of rectangles/bars
int count = int(random(5, 10));
// Build float array to store rect properties
float[][] f = new float[count][8];

// For noise animation
//Animation noiseAnimation;

//PFont secrcode;

void setup() {
  size(720, 720, P3D);
  smooth(4);
  /*Camera Setup
   */ 

  //Audio setup
 // frameRate(45); //45

  //Shark
 shark = new Shark(width/2, height/2);

  flock = new Flock();

  // Add an initial set of fish into the system
  for (int i = 0; i < 50; i++) {
    flock.addBoid(new Fish(width/2, height/2));
  }

  // Jellyfishes
  jelly1 = new Jellyfish(width/2, height/2, 60);
  jelly2 = new Jellyfish(width/2, height/2, 60);
  jelly3 = new Jellyfish(width/2, height/2, 35);

  //Light Rays
  for (int j=0; j< count; j++) {
    f[j][0]=random(width); // X 
    f[j][1]=height; // Y
    f[j][2]=random(-.5, .5); // X Speed
    f[j][3]=random(30, 50); // opacity
    f[j][4]=200; // red
    f[j][5]=200; // green
    f[j][6]=random(200, 255); // blue
    f[j][7]=random(10, width/(30)); // bar width
  }  
  //Bubbles
  for (int i = 0; i < 5; i++) {
    bubbles.add(new Bubble());
  }
  //Screen noise
  //noiseAnimation = new Animation("Noise", 10);
  
  //secrcode = createFont("monofonto.ttf", 12);
}

void draw() {
  //background, version 1:31134b
  background(#211238);
  
  // pushMatrix();//pushed back.. 
  // translate(0.0,0.0,-200.0);//..for debugging
  
  //Update Shark
  //--needs work to get shark to be aware of fish... leave for now.
  shark.run(flock.fish);
  
  //Update the Fish
  //--Actually done in flock class.
  flock.run();

  // Jellyfishes
  jelly1.update();
  jelly2.update();
  jelly3.update();

  //Update Bubbles
  //Add, move, destroy
  for (int i = 0; i < 2; i++) {
    bubbles.add(new Bubble());
  }
  for (int i = (bubbles.size ()-1); i >= 0; i--) {
    Bubble b = bubbles.get(i);
    b.update();
    if (b.pos.x > width + border) {
      bubbles.remove(i);
    }
    if (b.pos.x < 0 - border) {
      bubbles.remove(i);
    }
    if (b.pos.y > height + border) {
      bubbles.remove(i);
    }
    if (b.pos.y < 0 - border) {
      bubbles.remove(i);
    }
  }

  //Updat random beams
  // Begin looping through rectangle array
  for (int i=0; i< count; i++) {
    // Disable shape stroke/border
    noStroke();
    //  fill color
    fill( f[i][4], f[i][5], f[i][6], f[i][3]);  
    // Draw rectangles
    rect(f[i][0], 0, f[i][7], height);
    // Move rect horizontally
    f[i][0]+=f[i][2];
    // Wrap edges of canvas so rectangles get removed if they go out of bounds
    if ( f[i][0] < -f[i][7]      ) { 
      f[i][0] = random(width);
    } 
    if ( f[i][0] > width+f[i][7]  ) { 
      f[i][0] = random(width);
    }
  }
 
  //Update Noise animation
    //noiseAnimation.display(0, 0);
    
   //Circle display for interaction placement/GUI  
   //or
   //handCursor(tcur.getScreenX(width),height-tcur.getScreenY(height),50.0);
}

//// The Boid class ////

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
  String[] fishTalk = {"Wow!", "No!"};
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
    //textFont(secrcode);
    fill(0);
    text(_line, location.x, location.y-20.0, location.z);
  }
}
////Bubbles////
class Bubble{
  PVector pos;
  PVector vel;
  float time;
  float st;
  float sz = random(1,8);
  Bubble(){
    time = 0;
    st = random(0.1,0.5);
    pos = new PVector(random(width), random(height));
    vel = new PVector(random(-2,2),random(-2,-4));
  }
   
  void update(){
    time += st;
    if (time > 64) time = 64;
    move();
    render();
  }
   
  void move(){
    pos.add(vel);
  }
   
  void render(){
    fill(255,time);
    noStroke();
    ellipse(pos.x, pos.y,sz,sz);
  }
}
/////Fish/////
class Fish extends Boid {

  private Flagellum body;
  private Flagellum tail;

  private int numBodySegments;
  private int numTailSegments;

  private float bodySizeW;
  private float bodySizeH;
  private float tailSizeW;
  private float tailSizeH;

  private color eyeColour;
  private color mainColour;
  private color c1;
  private color c2;

  private PVector YawNorm;

  //Decision variables
  //
  private float fear;
  private float curiosity;
  private float happiness;
  //private float 

  //timers
  private int lastFearTalk;
  private int lastCuriousTalk;
  private int fleeInterActTimer;
  //knowledge
  private PVector interAct;
  private float predatorDist;
  private float interActDist;
  private PVector interActFlee;

  public Fish(float locationX, float locationY) {
    //Initial boid attributes
    super(locationX, locationY, 1.5, 0.03);
    //Static body size
    bodySizeW    = random(15,50);
    bodySizeH    = bodySizeW*.35;
    //Fish colour
    c1 = #d44fff;
    c2 = #8EEEDF;
    mainColour = lerpColor(c1,c2,(bodySizeW)/30);
    eyeColour = #FFFFFF;
    //For flagellum
    numBodySegments = 17;
    //Tail sizes from bodySize
    tailSizeW    = bodySizeW * 0.7;
    tailSizeH    = bodySizeH * 1.5;
    //For flagellum
    numTailSegments = 10;
    //Initalize Flagellums
    body = new Flagellum( bodySizeW, bodySizeH, numBodySegments, 0.2 );
    tail = new Flagellum( tailSizeH, tailSizeW, numTailSegments, 0.3 );
    //smaller out camera
    outCam = 70.0;
    happiness = 50;
    fear = 0;
    curiosity = 0;
  }

  public void run(ArrayList <Boid> fish) {
   
    //feelings limits
    if (happiness>100) {
      happiness=100;
    }
    if (happiness<0) {
      happiness=0;
    }
    if (fear>100) {
      fear=100;
    }
    if (fear<0) {
      fear=0;
    }
    maxspeed = 1.5 + (fear/100);
    //Figure out how far away the predator is?
    predatorDist = PVector.dist(location, shark.location);
    curiosity = happiness - fear;
    if (predatorDist < 50.0+curiosity) {
      fear+=predatorDist/2;
      happiness-=fear;
    } else {
      fear-=1;
    }
    for (Boid f : fish) {
      float d = PVector.dist(location, f.location);
      if (d < neighborhoodRadius) {
        happiness+=10;
      }
    }
    //Decide what to do
    if (fleeInterActTimer>0 && PVector.dist(location, interActFlee)<200) { //if still scared keep fleeing interaction
      super.evade(interActFlee, fish);
    } else if (fear>=80) //--add a multiplication utility with the knowlegde on how far it will kick in.
    {
      //Run away
      super.evade(shark.location, fish); //keep evading shark also
      //Say something
      if (lastFearTalk == 0) {
        int i = int(random((fishTalk.length/2+1), fishTalk.length-1));
        fishLine = fishTalk[i];
        lastFearTalk = int(random(600,800));
      }
    } /*else if (tuioCursorList.size ()>0 && curiosity>=70) { //cursor list exists and actually curious
      //need to add a find closest tuio object loop.
      TuioCursor tcur0 = tuioCursorList.get(0);
      interAct = new PVector(tcur0.getScreenX(width), height-tcur0.getScreenY(height), 0.0);
      interActDist = PVector.dist(interAct, location);
      for (int i=1; i<tuioCursorList.size (); i++) {//look through find the closest tuio cursor
        TuioCursor tcur = tuioCursorList.get(i);
        PVector PVtcur = new PVector(tcur.getScreenX(width), height-tcur.getScreenY(height), 0.0);
        float tcurDist = PVector.dist(location, PVtcur);
        if (tcurDist < interActDist) { //remember and replace first cursor if closer
          interAct = PVtcur.copy();
          interActDist = tcurDist;
          tcurGet = i;//rememberwhat number so we can get its speed futher down
        }
      }
      TuioCursor tcur = tuioCursorList.get(tcurGet);//grab the list again
      tcurSpeed=tcur.getMotionSpeed();//get the speed
      if (interActDist < (curiosity+100) && tcurSpeed<0.8) {
        super.seeker(interAct, fish);
        happiness+=1;
        //say something
        if (lastCuriousTalk == 0 && curiosity>80) {
          int i = int(random(0, fishTalk.length/2));
          fishLine = fishTalk[i];
          lastCuriousTalk = int(random(800, 1200));
        }
      } else if (interActDist < (curiosity)) {
        //Say something
        lastCuriousTalk=0;
        if (lastFearTalk == 0) {
          int i = int(random((fishTalk.length/2+1), fishTalk.length-1));
          fishLine = fishTalk[i];
          lastFearTalk = int(random(600, 800));
        }
        interActFlee = interAct.copy();//Pass on position to swim away from
        fleeInterActTimer = 300;//set timer for runaway time

        happiness/=2;//make more unhappy
        fear+=20;//add to the fear
      }
    }*/ else {
      super.flock(fish);//Flock - School with friends.
    }

    if (lastFearTalk > 500 || lastCuriousTalk > 500) {
      followingText(fishLine);
    }
    //Count timers down by 1
    lastFearTalk--;
    fleeInterActTimer--;

    //unless less than 0
    if (lastFearTalk<0) {
      lastFearTalk = 0;
    }

    lastCuriousTalk--;
    //unless less than 0
    if (lastCuriousTalk<0) {
      lastCuriousTalk = 0;
    }

    //update the boid part
    super.run(fish);
    
    // update location and direction
    YawNorm = velocity.copy();
    float theta =atan2(-(-YawNorm.z), (YawNorm.x)) ;
    
    pushMatrix();
    //Translate/move to position
    translate(location.x, location.y, location.z);
    //Rotate whole fish
    float tiltZ = atan(YawNorm.y/YawNorm.x);
    if (tiltZ>.5) {
      tiltZ = .5;
    }
    if (tiltZ<-0.5) {
       tiltZ=-0.5; 
    }
    rotateY(atan2((-YawNorm.z), (YawNorm.x)));
    rotateZ((asin(YawNorm.y/2)));
    //rotateZ(tiltZ);
    //Run the renders
    renderHead( body, 0.5, 0.25, tiltZ);
    renderBody( body, 0.5, 0.25, tiltZ);
   // PVector tailLocation = new PVector(body.spine[numBodySegments - 1][0], 0, body.spine[numBodySegments - 1][1] );
   // renderTail(tail, tailLocation, 0.75);
    
    // update flagellum body rotation
    body.theta = theta;
    //body.theta += TWO_PI;
    //Move muscle
    body.muscleFreq = norm(velocity.mag(), 0, 1) * 0.07;
    //Swim
    body.swim();

    //text(YawNorm.x,30,0);
    //text(YawNorm.z,30,10);
    //text(tiltZ,30,20);
    popMatrix();
  }
  
 private void renderBody( Flagellum _flag, float _sizeOffsetA, float _sizeOffsetB , float _tilt) {
 //render body
  pushMatrix();
  rotateY(-atan2((-YawNorm.z),(YawNorm.x)));
    fill(mainColour);
      for ( int n = 1; n < _flag.numNodes-6; n++ ) {
  
        float x1  = _flag.spine[n][0];
        float z1   = _flag.spine[n][1];
        float x2   = _flag.spine[n][0];
        float z2   = _flag.spine[n][1];
  
        beginShape();
        vertex( x1+.3, (bodySizeH/2)-(n*.15), z1 );
        vertex( x1-.3, (bodySizeH/2)-(n*.15), z1 );
        vertex( x2-.3, -(bodySizeH/2)+(n*.15), z2 );
        vertex( x2+.3, -(bodySizeH/2)+(n*.15), z2 );
        endShape();
      }
        //Top Strip Tail
    beginShape(QUAD_STRIP);
    for ( int n = 11; n < _flag.numNodes; n++ ) {
      float x1  = _flag.spine[n][0];
      float z1   = _flag.spine[n][1];
      vertex( x1, -bodySizeH*.5, z1 );
      vertex( x1, -bodySizeH*0.35, z1 );
    }
    endShape();
    //Top MID Strip Tail
    beginShape(QUAD_STRIP);
    for ( int n = 11; n < _flag.numNodes-2; n++ ) {
      float x1  = _flag.spine[n][0];
      float z1   = _flag.spine[n][1];
      vertex( x1, -bodySizeH*0.2, z1 );
      vertex( x1, -bodySizeH*0.05, z1 );
    }
    endShape();
    //Bottom MID Strip Tail
    beginShape(QUAD_STRIP);
    for ( int n = 11; n < _flag.numNodes-2; n++ ) {
      float x1  = _flag.spine[n][0];
      float z1   = _flag.spine[n][1];
      vertex( x1, bodySizeH*0.05, z1 );
      vertex( x1, bodySizeH*0.2, z1 );
    }
    endShape();
    //Bottom Strip Tail
    beginShape(QUAD_STRIP);
    for ( int n = 11; n < _flag.numNodes; n++ ) {
      float x1  = _flag.spine[n][0];
      float z1   = _flag.spine[n][1];
      vertex( x1, bodySizeH*0.35, z1 );
      vertex( x1, bodySizeH*.5, z1 );
    }
    endShape();
    popMatrix();
 }
 
  private void renderHead( Flagellum _flag, float _sizeOffsetA, float _sizeOffsetB, float _tilt) {
    pushMatrix();
    //rotateZ(_tilt);
    
    //Head
    fill(mainColour);
    beginShape();
    //start at top corner.
    vertex(_flag.spine[0][0], -(bodySizeH/2), _flag.spine[0][1]);
    //top mid
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.45, -(bodySizeH/2)*.75, _flag.spine[0][1]);
    //futherest end/beak
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.75, -(bodySizeH/2)*.1, _flag.spine[0][1]);
    //back to start
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.5, -(bodySizeH/2)*.1, _flag.spine[0][1]);
    //inside mid
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.3, -(bodySizeH/2)*.35, _flag.spine[0][1]);
    //inside end
    vertex(_flag.spine[0][0], -(bodySizeH/2)*.35, _flag.spine[0][1]);
    endShape();
    //Eye
    fill(eyeColour);
    beginShape();
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.1, 0, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.15, -(bodySizeH/2)*.2, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.2, -(bodySizeH/2)*.2, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.25, -(bodySizeH/2)*.2, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.3, 0, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.25, (bodySizeH/2)*.2, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.2, (bodySizeH/2)*.2, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.15, (bodySizeH/2)*.2, _flag.spine[0][1]);
    endShape();
    //head
    fill(mainColour);
    beginShape();
    vertex(_flag.spine[0][0], (bodySizeH/2), _flag.spine[0][1]);
    //top mid
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.45, (bodySizeH/2)*.75, _flag.spine[0][1]);
    //futherest end/beak
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.75, (bodySizeH/2)*.1, _flag.spine[0][1]);
    //back to start
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.5, (bodySizeH/2)*.1, _flag.spine[0][1]);
    //inside mid
    vertex(_flag.spine[0][0]+(bodySizeW/2)*.3, (bodySizeH/2)*.35, _flag.spine[0][1]);
    //inside end
    vertex(_flag.spine[0][0], (bodySizeH/2)*.35, _flag.spine[0][1]);
    endShape();
    popMatrix();
  }

  PVector getLoc() {
    return super.location;
  }
}
//////Flagellum//////
class Flagellum {

  int numNodes;

  float[][] spine;

  float MUSCLE_RANGE   = 0.15;
  float muscleFreq  = 0.08;

  float sizeW, sizeH;
  float spaceX, spaceZ;
  float theta;
  float count;
  float thetaVel;
  float tiltZ = 0.0;

  Flagellum( float _sizeW, float _sizeH, int _numNodes, float _muscleRange ) {

    sizeW    = _sizeW;
    sizeH    = _sizeH;

    numNodes  = _numNodes;
    
    MUSCLE_RANGE   = _muscleRange;
    
    spine     = new float[numNodes][2];

    spaceX     = sizeW / float(numNodes + 1);
    spaceZ     = sizeH / 2.0;

    count     = 0;
    theta     = PI;
    thetaVel   = 0;
    tiltZ=0.0;

    // Initialize spine positions
    for ( int n = 0; n < numNodes; n++ ) {
      float x  = spaceX * n;
      float z = spaceZ;

      spine[n][0] = x;
      spine[n][1] = z;
    }
  }


  void swim() {
    spine[0][0] = cos( theta );
    spine[0][1] = sin( theta );

    count += muscleFreq;
    float thetaMuscle = MUSCLE_RANGE * sin( count );

    spine[1][0] = -spaceX * cos( theta + thetaMuscle ) + spine[0][0];
    spine[1][1] = -spaceX * sin( theta + thetaMuscle ) + spine[0][1];

    for ( int n = 2; n < numNodes; n++ ) {
      float x  = spine[n][0] - spine[n - 2][0];
      float z = spine[n][1] - spine[n - 2][1];
      float l = sqrt( (x * x) + (z * z) );

      if ( l > 0 ) {
        spine[n][0] = spine[n - 1][0] + (x * spaceX) / l;
        spine[n][1] = spine[n - 1][1] + (z * spaceX) / l;
      }
    }
  }


  void debugRender() {
    for ( int n = 0; n < numNodes; n++ ) {
      stroke( 0 );
      if ( n < numNodes - 1 ) {
        line( spine[n][0], spine[n][1], spine[n + 1][0], spine[n + 1][1] );
      }
      fill( 90 );
      ellipse( spine[n][0], spine[n][1], 6, 6 );
    }
  }
}
///////Flock///////
// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> fish; // An ArrayList for all the boids

  Flock() {
    fish = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid f : fish) {
      f.run(fish);  // Passing the entire list of boids to each boid individually
    }
  }
  void addBoid(Boid f) {
    fish.add(f);
  }
}
////////Jellyfish////////
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
    zC = 0.0;
    //zC = circleOffset.z;
    if (yC > .2) {
      yC = .2;
    }
    circleOffset.set(xC, yC, zC);
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
//////////Particle//////////

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
////////
class Shark extends Boid {

  private Flagellum body;
  private Flagellum tail;

  private int numBodySegments;
  private int numTailSegments;

  private float bodySizeW;
  private float bodySizeH;
  private float tailSizeW;
  private float tailSizeH;

  private color mainColor;

  private boolean preyTarget = false;
  private float d = 200.0;
  private PVector preyLoc = new PVector(0, 0, 0);

  private PVector YawNorm;
  
  //Constructor
  public Shark(float locationX, float locationY) {
    super(locationX, locationY, 0.5, 0.03);
    
    velocity.set(0.5,0,0);
    
    mainColor = #000000;

    bodySizeW  = 150;
    bodySizeH = 50;

    numBodySegments = 16;

    numTailSegments = 7;
    tailSizeW    = bodySizeW;
    tailSizeH    = bodySizeH;

    body = new Flagellum( bodySizeW, bodySizeH/2, numBodySegments, 0.3 );

    tail = new Flagellum( tailSizeH, tailSizeW, numTailSegments, 0.4);
    
    r= 2.0;
    outCam=300.0;
  }
  
  //Run
  public void run(ArrayList<Boid> flock) {
    update(flock);
    render();
  }
  
  //Update
  public void update(ArrayList<Boid> flock) {
    super.run(flock);

  //Muscle updates 
    // Align body TO OBJECT
    body.theta=TWO_PI;
    //Move muscle
    body.muscleFreq = norm(velocity.mag(), 0, 1) * 0.04;
    //Swim
    body.swim();
    //Tail Align
    tail.theta     = PI;
    tail.muscleFreq   = norm(velocity.mag(), 0, 1 ) * 0.06;
    tail.swim();
    //behaviour
    /*PVector prey = new PVector(flock.getFish (super.location, 300));
    if (prey != null) {
      seek(prey);
    } else
    {*/
    //hunt(flock);
    //}
    wander();
  }

  protected void debugRender() {
    noStroke();
    fill(255, 0, 0);
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphere(5);
    popMatrix();
    translate(0.0, 0.0, 0.0);
  }

  //Rendering Stuff
  public void render() {
    noStroke();
    fill(mainColor);

    pushMatrix();
    //rotate body
    translate(location.x, location.y, location.z);
    YawNorm = velocity.copy();
    rotateX(PI);
    rotateY(atan2(-(-YawNorm.z), (YawNorm.x)));
    rotateZ((asin(-YawNorm.y/2)));
    //render body
    renderBody( body, 0.5, 0.25 );
    popMatrix();
  }

  private void renderBody( Flagellum _flag, float _sizeOffsetA, float _sizeOffsetB ) {
    pushMatrix();
    //Head
    fill(#f77400);
    beginShape();
    //start at top corner.
    vertex(_flag.spine[0][0]+bodySizeW*.16, bodySizeW*.155, _flag.spine[0][1]);
    //vertex(_flag.spine[0][0]+bodySizeW*.14, bodySizeW*.15, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.53, bodySizeW*.13, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.56, bodySizeW*.11, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.44, 0, _flag.spine[0][1]);
    //Eye Socket
    vertex(_flag.spine[0][0]+bodySizeW*.33, 0, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.35, bodySizeW*.03, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.335, bodySizeW*.045, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.32, bodySizeW*.06, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.30, bodySizeW*.06, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.285, bodySizeW*.045, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.27, bodySizeW*.03, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.29, 0, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.23, 0, _flag.spine[0][1]);
    endShape();
    //Eyes
    fill(255);
    ellipse(_flag.spine[0][0]+bodySizeW*.308, bodySizeW*.03, 5, 5);
    popMatrix();
    //Jaw
    fill(#f77400);
    beginShape();
    vertex(_flag.spine[0][0]+(bodySizeW*.23), -(bodySizeW*.02), _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW*.42), -(bodySizeW*.02), _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW*.36), -(bodySizeW*.04), _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW*.24), -(bodySizeW*.06), _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+(bodySizeW*.18), -(bodySizeW*.06), _flag.spine[0][1]);
    endShape();
    //Back of skull
    beginShape();
    vertex(_flag.spine[0][0]+bodySizeW*.20, bodySizeW*-.01, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.12, bodySizeW*.16, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.09, bodySizeW*.16, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.09, bodySizeW*-.08, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.12, bodySizeW*-.07, _flag.spine[0][1]);
    endShape();
    //gill1 lowest
    beginShape();
    vertex(_flag.spine[0][0]+bodySizeW*.065,bodySizeW*-.08,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*-.03,bodySizeW*-.08,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*-.0225,bodySizeW*-.04,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.065,bodySizeW*-.04,_flag.spine[0][1]);
    endShape();
    //gill2
    beginShape();
    vertex(_flag.spine[0][0]+bodySizeW*.065,bodySizeW*.02,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*-.015,bodySizeW*.02,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*-.01,bodySizeW*.06,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.065,bodySizeW*.06,_flag.spine[0][1]);    
    endShape();
    //gill3 highest
    beginShape();
    vertex(_flag.spine[0][0]+bodySizeW*.065,bodySizeW*.16,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.01,bodySizeW*.16,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.005,bodySizeW*.12,_flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.065,bodySizeW*.12,_flag.spine[0][1]);    
    endShape();
    
    fill(#f77400);

    for ( int n = 1; n < _flag.numNodes-1; n++ ) {

      if (n!=16)
      {
        float x1   = _flag.spine[n-1][0];
        float x2   = _flag.spine[n][0];
        float x3   = _flag.spine[n+1][0];
        float z1   = _flag.spine[n][1];

        beginShape(TRIANGLE_STRIP);
        vertex( x1-3, (bodySizeH/2)-(n*.75), z1 );
        vertex( x2, -(bodySizeH/4)+(n*.75), z1 );
        vertex( x3+3, (bodySizeH/2)-(n*.75), z1);
        endShape();
        ++n;
      }
    }
    for ( int n = 2; n < _flag.numNodes-1; n++ ) {

      if (n!=16)
      {
        float x1   = _flag.spine[n-1][0];
        float x2   = _flag.spine[n][0];
        float x3   = _flag.spine[n+1][0];
        float z1   = _flag.spine[n][1];

        beginShape(TRIANGLE_STRIP);
        vertex( x1-4, -(bodySizeH/4)+(n*.75), z1 );
        vertex( x2, (bodySizeH/2.5)-(n*.75), z1 );
        vertex( x3+4, -(bodySizeH/4)+(n*.75), z1);
        endShape();
        ++n;
      }
    }
    //fins
    beginShape();
    vertex(_flag.spine[3][0], (bodySizeH/1.75), _flag.spine[3][1] );
    vertex(_flag.spine[6][0]-10, (bodySizeH), _flag.spine[6][1] );
    vertex(_flag.spine[6][0], (bodySizeH/1.75), _flag.spine[6][1] );
    endShape();

    beginShape();
    vertex(_flag.spine[0][0], -(bodySizeH/3), _flag.spine[0][1]-15 );
    vertex(_flag.spine[2][0]-15, -(bodySizeH), _flag.spine[2][1]-(bodySizeH/2)*.75 );
    vertex(_flag.spine[2][0], -(bodySizeH/3), _flag.spine[2][1]-15 );
    endShape();

    beginShape();
    vertex(_flag.spine[0][0], -(bodySizeH/3), _flag.spine[0][1]+15 );
    vertex(_flag.spine[2][0]-15, -(bodySizeH), _flag.spine[2][1]+(bodySizeH/2)*.75 );
    vertex(_flag.spine[2][0], -(bodySizeH/3), _flag.spine[2][1]+15 );
    endShape();

    //tail
    PVector tailLocation = new PVector(body.spine[numBodySegments - 1][0], 0, body.spine[numBodySegments - 1][1] );
    translate(tailLocation.x, 0.0, tailLocation.z);
    pushMatrix();
    renderTail(tail, tailLocation, 0.75);
    popMatrix();
  }

  private void renderTail( Flagellum _flag, PVector _location, float _sizeOffset ) {
    //Top Tail
    beginShape();
    vertex(_flag.spine[0][0]+2, tailSizeH*.25, _flag.spine[0][1] );
    vertex(-_flag.spine[3][0], tailSizeH*.7, _flag.spine[3][1] );
    vertex(-_flag.spine[6][0]-10, tailSizeH, _flag.spine[6][1] );
    vertex(-_flag.spine[5][0]-5, tailSizeH*.7, _flag.spine[5][1] );
    vertex(-_flag.spine[5][0], tailSizeH*.75, _flag.spine[5][1] );
    vertex(-_flag.spine[3][0]+2, tailSizeH*.25, _flag.spine[2][1] );
    endShape();
    //MID Strip Tail
    beginShape(QUAD_STRIP);
    for ( int n = 0; n < 4; n++ ) {
      float x1  = -_flag.spine[n][0];
      float z1   = _flag.spine[n][1];
      vertex( x1-3, -tailSizeH*.03, z1 );
      vertex( x1+2, tailSizeH*.18, z1 );
    }
    endShape();
    beginShape();
    vertex(_flag.spine[0][0]-3, -tailSizeH*.1, _flag.spine[0][1] );
    vertex(-_flag.spine[3][0]-5, -tailSizeH*.35, _flag.spine[3][1] );
    vertex(-_flag.spine[5][0]-6, -tailSizeH*.55, _flag.spine[5][1] );
    vertex(-_flag.spine[3][0]-3, -tailSizeH*.1, _flag.spine[3][1] );
    endShape();
  }
}
////////Spring
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
//////Tentacle
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