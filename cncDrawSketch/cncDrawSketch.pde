/// control keys:

//Machine and Program Control

// m : machine initialise
// z : initialize machine zero point for sketch
// r : reset machine and all postions including zero init.
// c : read current drill position
// w : write cut program to machine buffer
// e : send end of file (and execute written descriptions)

// Position Control

// Z Axis

// [ : down my 50
// p : down by 5
// o : down by 1
//  Shift + [,P,O to raise by same increments

// X Axis
 
// ' : increase X by 50
// ; : increase X by 5
// l : increase X by 1
//  Shift + ",:,L to decrease X by same increments

// Y Axis

// / : increase Y by 50
// . : increase Y by 5
// , : increase Y by 1
//  Shift + ?,>,< to decrease Y by same increments


// I've moved this tab out so that drawing is separate to the developing API


// The two functions called first are the necessary handshaking required 
// to first initalise the serial port [serialInit()] and secondly to 
// initialise the machine [machineInit()] and set it to file mode.


void setup(){
  
   //size(600,1400);
   size(800,600);
   noLoop();
   
// Initialise the serial port and the machine
   
   serialInit();
   machineInit(myPort); 
   
 }
 

void draw(){

//bezierTest();
//imageDots();

lineTest();


}

void imageDots() {
 
  //image dot attempt
PImage img = loadImage("dmr.png");
int gridRes=12000;
drillBit=7;
img.resize(width,height);
image(img,0,0);
filter(GRAY);
loadPixels();
background(255);
noFill();
noStroke();
float fwidth = (float)width;
float fheight = (float)height;
int ySide=(int)(sqrt(gridRes/(fwidth/fheight)));
int xSide=(int)(ySide*(fwidth/fheight));
println(ySide);
println(xSide);

for (int i = 0; i < xSide; i++) {
  for (int j = 0; j < ySide; j++) {
    int t=0;
     for (int x = 0; x < width/xSide; x++) {
       for (int y = 0; y < height/ySide; y++) {
          t += brightness((pixels[((j*(height/ySide)*width)+(y*width)+(i*(width/xSide))+x)]));
          
       }
     }
  int m = t/((width/xSide)*(height/ySide));
  fill(m);
  noStroke();
  dotPlot((i*(width/xSide))+(width/xSide/2),(j*(height/ySide))+(height/ySide/2),m,drillBit);
  
       
     }

}

//updatePixels();
  
  
   
  
  
}

void bezierTest() {
  
  // all of the below is just to draw something.
 // the only function that matters is bezierPlot()
 // which is the interface to the rest of the API
  
 int bezIter = 5;
 int randX3=(int)random(width/4);
 int randY3=(int)random(height/4);
 int randX4=(int)random(width);
 int randY4=(int)random(height);
 for (int c=1; c <= bezIter; c++){
 int rand = (int)random(100)+50;
 int randX1=(int)random(width);
 int randY1=(int)random(height);
 int randX2=(int)random(width);
 int randY2=(int)random(height);
 for (int b=1; b <= bezIter; b++){
 // bezierPlot(rand*b,height-rand*b,0,rand*b,width,rand*b,width-rand*b,50+rand*b,100);
  bezierPlot(randX3,randY3,randX1+b*rand,randY1+b*rand,randX2-b*rand,randY2-b*rand,randX4,randY4,60);
 }
} 
  
}

void lineTest() {
  int rows = 10;
   int cols = 20;  
  // noFill();
  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) { 
      linePlot((x+1)*width/(rows+1),2,(y+1)*height/(cols+1),height-2,0);
    }
  }
}