void handCursor(float x, float y, float size) {
      pushMatrix();
      translate(x,y);
      pushStyle();
      blendMode(ADD);
      fill(#FFCC88);
      //thumb
      beginShape();
      vertex(handSize*-0.265,handSize*-0.25,0.0);
      vertex(handSize*-0.265,handSize*0.0,0.0);
      vertex(handSize*-0.2,handSize*0.15,0.0);
      vertex(handSize*-0.2,handSize*-0.15,0.0);
      endShape();
      //palm
      beginShape();
      vertex(handSize*-0.15,handSize*-0.15, 0,0);
      vertex(handSize*-0.15,handSize*0.15,0.0);
      vertex(handSize*0.1,handSize*0.15,0.0);
      vertex(handSize*0.2,handSize*0.075,0.0);
      vertex(handSize*0.2,handSize*-0.15,0.0);
      endShape();
      //pointer
      beginShape();
      vertex(handSize*-0.1,handSize*-0.5, 0,0);
      vertex(handSize*-0.1,handSize*-0.2,0.0);
      vertex(handSize*-0.15,handSize*-0.2,0.0);
      vertex(handSize*-0.15,handSize*-0.5,0.0);
      endShape();
      //rude
      beginShape();
      vertex(0.0,handSize*-0.55, 0,0);
      vertex(0.0,handSize*-0.2,0.0);
      vertex(handSize*-0.05,handSize*-0.2,0.0);
      vertex(handSize*-0.05,handSize*-0.55,0.0);
      endShape();
      //ring
      beginShape();
      vertex(handSize*0.1,handSize*-0.5, 0,0);
      vertex(handSize*0.1,handSize*-0.2,0.0);
      vertex(handSize*0.05,handSize*-0.2,0.0);
      vertex(handSize*0.05,handSize*-0.5,0.0);
      endShape();
      //pinky
      beginShape();
      vertex(handSize*0.2,handSize*-0.425, 0,0);
      vertex(handSize*0.2,handSize*-0.2,0.0);
      vertex(handSize*0.15,handSize*-0.2,0.0);
      vertex(handSize*0.15,handSize*-0.425,0.0);
      endShape();
      popStyle();
      popMatrix();
    }
  