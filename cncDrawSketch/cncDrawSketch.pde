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
   size(1024,800);
   noLoop();
   
// Initialise the serial port and the machine
   
   serialInit();
   machineInit(myPort); 
   
 }
 

void draw(){
 
 // all of the below is just to draw something.
 // the only function that matters is bezierPlot()
 // which is the interface to the rest of the API
 
 
 linePlot(500,100,500,height-100);
 rectPlot(100,100,200,400);
  
 //int bezIter = 5;
 // int randX3=(int)random(width/4);
 // int randY3=(int)random(height/4);
 // int randX4=(int)random(width);
 // int randY4=(int)random(height);
 //for (int c=1; c <= bezIter; c++){
 // int rand = (int)random(100)+50;
 // int randX1=(int)random(width);
 // int randY1=(int)random(height);
 // int randX2=(int)random(width);
 // int randY2=(int)random(height);
 // for (int b=1; b <= bezIter; b++){
 //   //  bezierPlot(rand*b,height-rand*b,0,rand*b,width,rand*b,width-rand*b,50+rand*b,100);
 // bezierPlot(randX3,randY3,randX1+b*rand,randY1+b*rand,randX2-b*rand,randY2-b*rand,randX4,randY4,60);
 // linePlot(randX1*b*rand,randY1*b*rand,randX2*b*rand,randY2*b*rand);
 // }
//}
}