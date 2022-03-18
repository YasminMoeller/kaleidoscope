// The following tutorials have been used as references:
// https://comp.anu.edu.au/courses/comp1720/labs/05-kaleidoscope/
// https://www.youtube.com/watch?v=BWFO-NgSLGo

import processing.serial.*;

// Constants Kaleidoscope
int slices = 6; // Number of triangular slices of base shape
int numShapes = 500; //Number of moving shapes within kaleidoscope
int detail = 4; // Size of polygon
int number = 19; // Number of polygon

IntDict shape, inventory;
PGraphics imgMask, mask;
PImage img;

// Serial Communication
Serial myPort;        // Create object from Serial class
char HEADER = 'H';    // character to identify the start of a message
short LF = 10;        // ASCII linefeed
short portIndex = 0;  // select the com port
boolean firstContact = false;

int y_rotation = 10;

void setup() {
  
    fullScreen();
    //size(800, 800);
    noStroke();
    
    shape = calcStuff(width,height,slices);
    mask = createMaskGraphics(shape.get("c"),shape.get("h"));
    
    //link processing to serial port (COM6)
    myPort = new Serial(this,Serial.list()[portIndex], 9600);
    myPort.bufferUntil('\n');

}

void draw() {

    background(#355C7D);
    drawShapes();
    mirror();
    
}

void drawShapes() {
    // draw lots of random moving shapes on the canvas
     
    for(var i=0; i < numShapes; i++) {

      fill(#F25E6B);
      ellipse(sin(y_rotation/100+i*0.4)*width,
                cos(i*0.23)*height,
                80+cos(y_rotation/40+400-i)*50,
                80+cos(y_rotation/30+i)*50); 
               
      fill(#F24949);
      ellipse(cos(i*0.23)*height,
                sin(y_rotation/100+i*0.4)*width,
                80+cos(y_rotation/30+i)*50,
                80+cos(y_rotation/40+400-i)*50);

      fill(#05F2DB);
      rect(cos(y_rotation/300+i*0.4)*width,
                sin(i*0.23)*height,
                80+cos(y_rotation/40+400-i)*50,
                80+tan(y_rotation/430+i)*50);
  
      fill(#04ADBF);
      rect(sin(i*0.23)*height,
                cos(y_rotation/300+i*0.4)*width, 
                80+cos(y_rotation/40+400-i)*50,
                80+tan(y_rotation/430+i)*50);
    };
    
}

void mirror() {
  
    // copy a section of the canvas
    img = get(0,0,shape.get("c"),shape.get("h"));
    // cut it into a triangular shape
    img.mask(imgMask);
    background(#355C7D);

    push();
    imageMode(CENTER);
    // move origin to centre
    translate(width/2,height/2);
    // turn the whole sketch over time
    rotate(radians(y_rotation)/2);
    
        for(var j=0; j<number; j++){
      for(var i=0; i<slices; i++) {
        if(i%2==0) {
          push();
          scale(1,-1); // mirror
          tint(255, 255-i*10-j*5);
          image(img,0,shape.get("h")/2); // draw slice
          pop();
        } else {
          rotate(radians(360/slices)*2); // rotate
          tint(255, 255-i*12-j*5);
          image(img,0,shape.get("h")/2); // draw slice
        }
      }
      
      var x = 0;
      var y = 0;
      
      if(j==0 || j==5 || j==6 || j==16 || j == 17){
        x = 0;
        y = 2*shape.get("h");
      } else if(j==1 || j==8 || j==9){
        x = shape.get("a")+shape.get("c")/2;
        y = - shape.get("h");
      } else if(j==2 || j==10 || j==11){
        x = 0;
        y = -2*shape.get("h");
      } else if(j==3 || j==12 || j==13){
        x = - shape.get("a")-shape.get("a")/2;
        y = - shape.get("h");
      } else if(j==4 || j==14 | j==15){
        x = - shape.get("a")-shape.get("c")/2;
        y = shape.get("h");
      } else if(j==7){
        x = shape.get("a")+shape.get("c")/2;
        y = shape.get("h");
      } 
      
      translate(x,y);
    
    }
    
    pop();
    
}

IntDict calcStuff(float width,float height, int s){

  var a = sqrt(sq(width/2)+sq(height/2))/detail;
  var theta = radians(360 / s);
  var c = 2*a*sin(theta/2);
  var h = a*sin((PI-theta)/2);

  inventory = new IntDict();
  inventory.set("a", round(a));
  inventory.set("c", round(c));
  inventory.set("h", round(h));
  return inventory;
  
}


PGraphics createMaskGraphics(int c,int h){
  // creates Mask out of a graphics object

  imgMask = createGraphics(c,h);
  imgMask.noStroke();
  imgMask.beginDraw();
  imgMask.beginShape();
  imgMask.vertex(0, imgMask.height);
  imgMask.vertex(imgMask.width / 2, 0);
  imgMask.vertex(imgMask.width, imgMask.height);
  imgMask.endShape(CLOSE);
  imgMask.endDraw();
 
  return imgMask;
  
}

void serialEvent(Serial p)
{
   // put the incoming data into a string
  //the LF/ '\n' is our end delimiter indicating the end of a complete packet
  String message = myPort.readStringUntil(LF); // read serial data

  // make sure our data isn't empty before continuing
  if(message != null)
  {

    print(message);
    String [] data  = message.split(","); // Split the comma-separated message
    if(data[0].charAt(0) == HEADER)       // check for header character in the first field
    {
      for( int i = 1; i < data.length-1; i++) // skip the header and terminatingcr and lf
      {
        int value = Integer.parseInt(data[i]);
        println("Value" +  i + " = " + value);  //Print the value for each field
        y_rotation = (value)/100;
      }
      println();
    }
  }
}
