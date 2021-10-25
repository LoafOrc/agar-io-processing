import processing.net.*;

HashMap<String, Blob> blobs = new HashMap();
HashMap<String, Blob> players = new HashMap();

int mapX = 4000;
int mapY = 4000;

int smallBlobs = 0;
int maxBlobs = 250;
int totalSmallBlobs = 0;

float zoom;

Server server;

ArrayList<Object> garbageCollector = new ArrayList();

void settings() {
  size(1000,1000);
  server = new Server(this, 5204);
}

void setup() { 
  createColours();
  
  int spawn = int(maxBlobs - random(0,maxBlobs*0.25));
  while(smallBlobs < spawn) {
    randomSmallBlob();
    smallBlobs++;
    totalSmallBlobs++;
  }
}


void handleClientInput(Client sendingClient) {
  if(sendingClient == null) return;
  
  String[] request = split(sendingClient.readString(), "\n");
  String[] rawClientData = split(request[1], " ");

  if(request[0].equals("LOCAL_BLOB")) {
    //Un-pack the raw client data
    String name = rawClientData[0];
    Blob client = players.get(name);
    
    if(client == null) client = createNewClient(name, sendingClient);
    float x = client.position.x;
    if(!rawClientData[1].equals("NaN")) x = float(rawClientData[1]);
    float y = client.position.x;
    if(!rawClientData[2].equals("NaN")) y = float(rawClientData[2]);
    
    PVector position = new PVector(x, y);
    
    client.position = position;
  }
  
  sendingClient.clear();
}

Blob createNewClient(String name, Client c) {
  Blob b = new Blob(new PVector(random(mapX), random(mapY)));
  players.put(name, b);
  blobs.put(name, b);
  return b;
}

void randomSmallBlob() {
  blobs.put("_" + String.valueOf(totalSmallBlobs), new Blob(new PVector(random(0,mapX), random(0,mapY)), int(random(24,40))));
}

void draw() {
  background(0);
  handleClientInput(server.available());
  
  if(smallBlobs != maxBlobs) {
    int spawn = int(random(0, (maxBlobs-smallBlobs)-5));
    for(int i = 0; i < spawn; i++) {
      randomSmallBlob();
      smallBlobs++;
      totalSmallBlobs++;
    }
  }
  
  //Update clients
  server.write(getBlobData());
  
  //Display (it looks nice)
  scale(0.25);
  stroke(255);
  strokeWeight(10);
  noFill();
  rect(0,0,mapX,mapY);
  noStroke();
  
  fill(255);
  textAlign(LEFT,TOP);
  textSize(50);
  text(int(frameRate) + "fps", 0,0);
  
  try {
    for(HashMap.Entry<String, Blob> entry : blobs.entrySet()) {
      entry.getValue().show();
      for(HashMap.Entry<String, Blob> blob : players.entrySet()) {
        Blob focusedBlob = blob.getValue();
        if(focusedBlob.eats(entry.getValue())) {
          if(entry.getValue().mass <= 40) smallBlobs--;
          entry.getValue().mass = 0;
          garbageCollector.add(entry.getKey());
        }
      }
    }
  } catch(Exception exception) {
    exception.printStackTrace();
  }
 for(Object o : garbageCollector) {
    if(blobs.containsKey(o)) blobs.remove(o);
  }
  garbageCollector.clear();
}

String getBlobData() {
  String message = "BLOB_DATA\n";
  for (HashMap.Entry<String, Blob> entry : players.entrySet()) {
    Blob b = entry.getValue();
    message += entry.getKey() + " " + b.position.x + " " + b.position.y + " " + b.mass + "\n";
  }
  for (HashMap.Entry<String, Blob> entry : blobs.entrySet()) {
    Blob b = entry.getValue();
    message += entry.getKey() + " " + b.position.x + " " + b.position.y + " " + b.mass + "\n";
  }
  return message;
}

String getLeaderboardData() {
  String message = "LEADERBOARD_DATA\n";
  Blob highest = null;
  String highestString = "";
  message += highestString;
  return message;
}
