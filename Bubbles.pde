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