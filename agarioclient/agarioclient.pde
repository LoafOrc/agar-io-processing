import processing.net.*;
Client localClient;

enum Scene {
  NAME,
  IN_GAME
}

Scene currentScene = Scene.NAME;

ArrayList<Object> garbageCollector = new ArrayList();

HashMap<Integer, Blob> localPlayer = new HashMap();
HashMap<String, Blob> localBlobs = new HashMap();

int mapX = 4000;
int mapY = 4000;

final int startingSize = 100;
int p = startingSize;

float zoom;

String localName;

//int totalMass;

void settings() {
  size(1080,720);
}

void setup() {
  arial = createFont("arial", 20);
  smallArial = createFont("arial", 10);
  ui = new ControlP5(this);
  createColours();
  setupGui();
}

public void connect(int theValue) {
  String ip = ui.get(Textfield.class, "ip").getStringValue();
  
  Blob startingPlayer = new Blob(new PVector(random(0,mapX), random(0,mapY)));
  startingPlayer.name = ui.get(Textfield.class, "name").getStringValue();
  
  localPlayer.put(0, startingPlayer);
  localName = startingPlayer.name;
  
  localClient = new Client(this, ip, 5204);
  
  zoom = startingSize / startingSize*2;
  
  currentScene = Scene.IN_GAME;
}

void disconnect() {
  localPlayer = null;
  
  localClient.stop();
  localClient = null;
  
  currentScene = Scene.NAME;
}

void keyPressed() {
  if(key == 'p') disconnect();
}

void draw() {
  if(currentScene == Scene.IN_GAME) {
    if(!localClient.active()) disconnect();
  }
  
  if(localClient != null && localPlayer != null) {
    if(localClient.available() > 0) {
      String recieved = localClient.readString();
      String[] rawServerData = split(recieved, "\n");
      if(rawServerData[0].equals("BLOB_DATA")) {
        for(int i = 1; i < rawServerData.length-1; i++) {
          String[] data = split(rawServerData[i], " ");
          if(data[0].equals(localName)) {
            println(data);
            Blob playerBlob = localPlayer.get(int(data[1]));
              if(data[2].equals("NaN")) {}
              else playerBlob.position.x = float(data[2]);
              if(data[3].equals("NaN") || data[3] == null) {}
              else playerBlob.position.y = float(data[3]);
              if(data[4].equals("NaN") || data[4] == null) {}
              else playerBlob.mass = float(data[4]);
          } else {
            if(localBlobs.containsKey(data[0])) {
              Blob exisiting = localBlobs.get(data[0]);
              if(PVector.dist(new PVector(float(data[2]), float(data[3])), exisiting.position) > speed + (speed * 0.75)) {
                if(data[1].equals("NaN")) {}
                else exisiting.position.x = float(data[2]);
                if(data[2].equals("NaN")) {}
                else exisiting.position.y = float(data[3]);
              }
              if(data[3].equals("NaN")) {}
              else exisiting.mass = float(data[3]);
            } else {
              if(data.length != 5) continue;
              localBlobs.put(data[0], new Blob(new PVector(float(data[2]), float(data[3])), float(data[4])));
              localBlobs.get(data[0]).name = data[0];
            }
          }
        }
      }
    }
  }
  
  background(0);
  gui();
  
  if(currentScene == Scene.IN_GAME) localPlayer.get(0);
  
  stroke(255);
  strokeWeight(10);
  noFill();
  rect(0,0,mapX,mapY);
  noStroke();
  
  if(currentScene == Scene.IN_GAME) {
    
    int aliveBlobs = localPlayer.size();
    for(HashMap.Entry<String, Blob> entry : localBlobs.entrySet()) {
      Blob playerBlob = entry.getValue();
      playerBlob.update();
      if(playerBlob.mass <= 0) {
        aliveBlobs--;
      }
    }
    if(aliveBlobs <= 0) {
      disconnect();
      currentScene = Scene.NAME;
    }
    
  }
  
  if(localPlayer != null) {
    for(HashMap.Entry<String, Blob> entry : localBlobs.entrySet()) {
      if(entry.getValue().mass == 0) {
        garbageCollector.add(entry.getKey());
      } else {
        for(HashMap.Entry<Integer, Blob> playerEntry : localPlayer.entrySet()) {
          Blob playerBlob = playerEntry.getValue();
          if(playerBlob.eats(entry.getValue())) {
            entry.getValue().mass = 0;
          }
        }
      }
      entry.getValue().show();
    }
  }
  
  for(Object o : garbageCollector) {
    if(localBlobs.containsKey(o)) localBlobs.remove(o);
  }
  if(currentScene == Scene.IN_GAME) {
    //totalMass = startingSize;
    for(HashMap.Entry<Integer, Blob> playerEntry : localPlayer.entrySet()) {
      Blob playerBlob = playerEntry.getValue();
      playerBlob.show();
      //totalMass += playerBlob.mass;
    }
  }
  garbageCollector.clear();
}
