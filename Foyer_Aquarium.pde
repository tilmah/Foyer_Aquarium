
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

PFont secrcode;

void setup() {
  size(720, 720, P3D);
  smooth(4);
  /*Camera Setup
   */ 

  //Audio setup
  frameRate(45); //45

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
  
  secrcode = createFont("monofonto.ttf", 12);
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