class Button {    
 
  // Button location and size
  float x;   
  float y;   
  float w;   
  float h;   
  
  // Is the button on or off?
  boolean on;
  color buttonColor; 
 
  // Constructor initializes all variables
  Button(float tempX, float tempY, float tempW, float tempH) {    
    x  = tempX;   
    y  = tempY;   
    w  = tempW;   
    h  = tempH;   
    on = false;  // Button always starts as off
  }    
 
  void click(int mx, int my) {
    // Check to see if a point is inside the rectangle
    if (mx > x && mx < x + w && my > y && my < y + h) {
      on = !on;
      buttonColor = color(0);
    }
  }
 
  // Draw the rectangle
  void display() {
    rectMode(CORNER);
    stroke(0);
    
    // The color changes based on the state of the button
    if (on) {
      fill(buttonColor);
    } 
    else {
      fill(255, 0);
    }
    rect(x, y, w, h);
  }
}
