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