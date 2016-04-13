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