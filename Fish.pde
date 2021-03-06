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
  private float tcurSpeed;

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
    int tcurGet = 0;
    
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
    //Get Tuio Cursors
    ArrayList<TuioCursor> tuioCursorList = tuioClient.getTuioCursorList();
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
    } else if (tuioCursorList.size ()>0 && curiosity>=70) { //cursor list exists and actually curious
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
    } else {
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