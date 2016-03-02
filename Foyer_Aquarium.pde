//import processing.video.*;

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

// import the TUIO library
import TUIO.*;
// declare a TuioProcessing client
TuioProcessing tuioClient;

// these are some helper variables which are used
boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

//Audio datatypes using minim
Minim minim;
AudioPlayer sndAqua;
AudioPlayer sndGuitar;
AudioPlayer sndBass;
AudioPlayer sndDrums;
AudioPlayer sndKeys;

//for audio playing
boolean audioPlay;

//Capture video;
PImage prevFrame;

//TuioObjsList


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

void setup() {
  size(1920, 1200, P3D);
  smooth(4);
  /*Camera Setup
   */ 

  //Audio setup
  minim = new Minim(this);
  sndAqua = minim.loadFile("Water.wav", 2048);
  sndGuitar = minim.loadFile("Guitar.wav", 2048);
  sndBass = minim.loadFile("Bass.wav", 2048);
  sndDrums = minim.loadFile("Drums.wav", 2048);
  sndKeys = minim.loadFile("Pads_Keys.wav", 2048);
  audioPlay = false;

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

  // finally we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods in this class (see below)
  tuioClient  = new TuioProcessing(this);
}

void draw() {
  /*/Camera draw
   */
  //background, version 1:31134b
  background(#1a2e3d);

  //range conversion - turn this into function.
  float OldRange = 480 - 0;
  float NewRange = 0 - -80;
  float aquaVolume = (((mouseY) * NewRange) / OldRange) + -80;
  
  //PVector 
  //jellyTrack
  
  //start sounds
  if (!audioPlay) {
    sndAqua.play();
    sndAqua.loop();
    sndKeys.setGain(-2);

    sndGuitar.play();
    sndGuitar.loop();
    sndGuitar.setGain(-5);

    sndBass.play();
    sndBass.loop();
    sndBass.setGain(-80);

    sndDrums.play();
    sndDrums.loop();
    sndDrums.setGain(-80);

    sndKeys.play();
    sndKeys.loop();
    sndKeys.setGain(-80);

    audioPlay=true;
  }
  
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
  
  //popMatrix();//dont forget to debug debug this one

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
  //---TUIO Stuffs
  ArrayList<TuioCursor> tuioCursorList = tuioClient.getTuioCursorList();
  pushStyle();
  noFill();
  blendMode(ADD);
  strokeWeight(8);
  for (int i=0; i<tuioCursorList.size(); i++) {
    TuioCursor tcur = tuioCursorList.get(i);
    stroke(255, 255, 255, 170);
    ellipse(width-tcur.getScreenX(width), tcur.getScreenY(height), 45, 45);
  }
  
  //Set volumes
  //shark bass
  if (shark.location.x > -200.0 && shark.location.x<(width/4)*3) {
      sndBass.setGain(sndBass.getGain()+0.1);
      if (sndBass.getGain()>0.0) {
        sndBass.setGain(0.0); 
      }
    } else if (shark.location.x < 0.0 || shark.location.x>(width/4)*3) {
      sndBass.setGain(sndBass.getGain()-0.05);
      if (sndBass.getGain()<-80.0) {
        sndBass.setGain(-80.0); 
      }
    }
   //Debug
   //text("x:"+shark.location.x, 10, 20);
   //text(sndBass.getGain(), 10, 40);
  //Jelly fish keys
  if (jelly1.location.x > (width/4) && jelly1.location.x<(width/4)*3) {
    if (jelly1.location.y > (height/4) || jelly1.location.y<(height/4)*3) {
        if (jelly2.location.x > (width/4) && jelly2.location.x<(width/4)*3) {
          if (jelly2.location.y > (height/4) || jelly2.location.y<(height/4)*3) {
              if (jelly3.location.x > (width/4) && jelly3.location.x<(width/4)*3) {
                  if (jelly3.location.y > (height/4) || jelly3.location.y<(height/4)*3) {
                      sndKeys.setGain(sndKeys.getGain()+0.1);
                  }
              }
          }
        }
    }
  } else {
      sndKeys.setGain(sndKeys.getGain()-0.05);
    }
    if (sndKeys.getGain()>1.0) {
        sndKeys.setGain(1.0); 
    }
    if (sndKeys.getGain()<-80.0) {
        sndKeys.setGain(-80.0); 
      }
  //Debug    
  //text(sndKeys.getGain(), 10, 100);
  //Drums level interact
  if (tuioCursorList.size()>0) {
      sndDrums.setGain(sndDrums.getGain()+0.05);
      if (sndDrums.getGain()>0.0) {
        sndDrums.setGain(0.0); 
      }
    } else {
      sndDrums.setGain(sndDrums.getGain()-0.03);
      if (sndDrums.getGain()<-80.0) {
        sndDrums.setGain(-80.0); 
      }
    }
    //Debug
   //text(tuioCursorList.size(), 10, 50);
   //text(sndDrums.getGain(), 10, 70);
  popStyle();
}