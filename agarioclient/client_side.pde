import controlP5.*;
ControlP5 ui;

PFont arial;
PFont smallArial;

void setupGui() {
  ui.addTextfield("name")
  .setPosition(width/2-125,height/2-230)
  .setSize(250,40)
  .setFont(arial)
  .setFocus(true)
  .setAutoClear(false)
  .setColor(color(255));
  
  ui.addTextfield("ip")
  .setPosition(width/2-125,height/2+170)
  .setSize(190,40)
  .setFont(arial)
  .setFocus(false)
  .setAutoClear(false)
  .setText("172.16.0.140")
  .setColor(color(255));
  
  ui.addButton("connect")
  .setPosition(width/2+70,height/2+170)
  .setSize(60,40)
  .setFont(smallArial);
  
}

void gui() {
  fill(255);
  if(currentScene == Scene.IN_GAME) {
    textAlign(LEFT,TOP);
    textSize(25);
    text(int(frameRate) + "fps", 0,0);
    //text("mass: " + totalMass, 0,25);
    ui.get(Textfield.class, "name").hide();
    ui.get(Textfield.class, "ip").hide();
    ui.get(Button.class, "connect").hide();
  } else if(currentScene == Scene.NAME) {
    fill(57, 62, 65);
    rect(width/2-150,height/2-250,300,500,15);
    ui.get(Textfield.class, "name").show();
    ui.get(Textfield.class, "ip").show();
    ui.get(Button.class, "connect").show();
      
    textFont(arial);
  }
}

public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
    if(theEvent.getName().equals("name")) {
      if(theEvent.getStringValue().contains(" ")) return;
      
    }
  }
}
