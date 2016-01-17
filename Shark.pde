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

    body = new Flagellum( bodySizeW, bodySizeH, numBodySegments );

    tail = new Flagellum( tailSizeH, tailSizeW, numTailSegments);
    
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
    vertex(_flag.spine[0][0]+bodySizeW*.16, bodySizeW*.13, _flag.spine[0][1]);
    vertex(_flag.spine[0][0]+bodySizeW*.14, bodySizeW*.15, _flag.spine[0][1]);
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