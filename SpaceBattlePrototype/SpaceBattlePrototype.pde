ArrayList<Player> players;
ArrayList<Missile> missiles;
Turn turn;

boolean showPing = false;
long pingAt = 0;
long pingLength = 1000;
int pingX;
int pingY;
boolean isAiming = false;
boolean debug = false;

PGraphics stars;

void setup() {
  size(800, 800);
  players = new ArrayList<Player>();
  missiles = new ArrayList<Missile>();

  players.add(new Player("1", 400, 50));
  players.add(new Player("2", 400, height-50));
  turn = new Turn(2);
  turn.setNumActions(3);

  stars = createGraphics(width, height);
  drawStars(stars);
}

void drawStars(PGraphics c) {
  c.beginDraw();
  int numStars = 1000;
  for (int i = 0; i < numStars; i++) {
    float x = random(width);
    float y = random(height);
    float s = random(5);

    c.pushStyle();
    c.noStroke();
    c.fill(255, random(100) + 100);
    c.ellipse(x, y, s, s);
    c.popStyle();
  }
  c.endDraw();
}

void draw() {
  background(0);
  image(stars, 0, 0);
  //drawStars();
  if (turn.isComplete()) {
    for (Missile missile : missiles) {
      missile.move();
    }
    for (Player player : players) {
      boolean isHit = player.checkHits(missiles);
      if (isHit) {
        player.die();
        debug = true;
      }
    }

    turn.next();
  }

  for (Player player : players) {
    player.draw(player.equals(currentPlayer()));
  }

  if (mousePressed && !turn.isComplete() && !keyPressed) {
    pushStyle();
    stroke(255, 150);
    strokeWeight(3);
    line(currentPlayer().pos.x, currentPlayer().pos.y, mouseX, mouseY);
    popStyle();
    isAiming = true;
  }

  if (showPing && (millis() - pingAt < pingLength)) {
    doPing(pingX, pingY);
  }

  if (millis() - pingAt > pingLength) {
    showPing = false;
  }

  if(debug){
    for (Missile missile : missiles) {
      missile.draw();
    }
  }
  
  drawTurns();
}

Player currentPlayer() {
  return players.get(turn.playerNum());
}

void drawTurns(){
  pushMatrix();
  pushStyle();
  
  noStroke();
  fill(currentPlayer().getColor());
  
  PVector p = new PVector(50,50);
  
  for(int i = 0; i < turn.actionsRemaining(); i++){
    ellipse(p.x + i*20, p.y, 15,15);
  }
  
  popStyle();
  popMatrix();
  
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT) {
      if (!turn.isComplete()) {
        currentPlayer().move(keyCode);
        turn.takeAction();
      }
    }
  }
}

void doPing(int x, int y) {
  for (Missile missile : missiles) {
    missile.draw();
  }

  noStroke();
  fill(0);
  rect(0, 0, x-25, height);    
  rect(0, 0, width, y-25);
  rect(x + 25, 0, width-(x + 25), height);
  rect(0, y+25, width, height-(y+25));

  noFill();
  stroke(255, 0, 0);
  rect(x-25, y-25, 50, 50);
}

void dashedLine(float x1, float y1, float x2, float y2) {
  for (int i = 0; i <= 20; i++) {
    float x = lerp(x1, x2, i/20.0) + 20;
    float y = lerp(y1, y2, i/20.0);
    point(x, y);
  }
}

void mouseReleased() {
  if (!turn.isComplete() && isAiming) {
    PVector dir = PVector.sub(new PVector(pmouseX, pmouseY), currentPlayer().pos);
    dir.normalize();
    Missile missile = new Missile(currentPlayer().pos.x, currentPlayer().pos.y, dir, currentPlayer());
    missile.move();
    missiles.add(missile);
    turn.takeAction();
    isAiming = false;
  }
}

void mousePressed() {
  if (!turn.isComplete() && keyPressed) {
    pingAt = millis();
    showPing = true;
    pingX = mouseX;
    pingY = mouseY;
    turn.takeAction();
  }
}

