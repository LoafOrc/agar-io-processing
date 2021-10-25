ArrayList<int[]> blobColours = new ArrayList();

float speed = 3;

void createColours() {
  int[] colour1 = {193, 121, 185};
  blobColours.add(colour1);
  
  int[] colour2 = {96, 211, 148};
  blobColours.add(colour2);
  
  int[] colour3 = {67, 146, 241};
  blobColours.add(colour3);
  
  int[] colour4 = {213, 137, 54};
  blobColours.add(colour4);
  
  int[] colour5 = {42, 127, 98};
  blobColours.add(colour5);
}

class Blob {
  PVector position;
  float mass;
  
  final int[] colour;
  
  String name = " ";
  
  Blob(PVector position) {
    this.position = position;
    this.mass = startingSize;
    colour = randomColour();
  }
  Blob(PVector position, float mass) {
    this.position = position;
    this.mass = mass;
    colour = randomColour();
  }
  
  void show() {
    fill(colour[0], colour[1], colour[2]);
    stroke(255);
    strokeWeight(2);
    randomColour();
    ellipse(position.x,position.y,mass,mass);
    
    fill(255);
    textAlign(CENTER,CENTER);
    textSize(mass/2.56-20);
    text(mass, position.x, position.y);
  }
  
  boolean eats(Blob other) {
    if(mass < other.mass*1.25) return false;
    float distance = PVector.dist(position, other.position);
    if(distance < (mass/2 + other.mass/2)-other.mass) {
      float sum = calculateArea() + other.calculateArea();
      mass = sqrt(sum / PI);
      return true;
    }
    return false;
  }
  
  float calculateArea() {
    return PI * mass * mass;
  }
  
  void update() {
    PVector premove = position.copy();
    
    PVector velocity = new PVector(mouseX-width/2, mouseY-height/2);
    velocity.setMag(speed);
    position.add(velocity);
    
    //Will we intersect with map boundaries?
    if(position.x > mapX || position.x < 0) {
      position.x = premove.x;
    }
    if(position.y > mapY || position.y < 0) {
      position.y = premove.y;
    }

    localClient.write("LOCAL_BLOB\n" + name + " " + position.x + " " + position.y + " " + mass + "\n");
  }
  
  void focus() {
    //https://www.youtube.com/watch?v=JXuxYMGe4KI&ab_channel=TheCodingTrain
    translate(width/2, height/2);
    
    float newscale = startingSize / mass*2;
    zoom = lerp(zoom, newscale, 0.1);
    
    scale(zoom);
    translate(-position.x,-position.y);
  }
  
  private int[] randomColour() {
    return blobColours.get((int)(Math.random() * blobColours.size()));
  }
}
