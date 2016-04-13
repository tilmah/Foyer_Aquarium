
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