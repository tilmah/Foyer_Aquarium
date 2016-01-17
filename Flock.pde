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