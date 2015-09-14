// I intend to turn this into a library at some point so I've
//moved those elements into a different tab.
// The sketch is based on the logic that we can create CNC functions
//for every processing draw function. Bezier is the only one done so far
//and I am working on PShape which will allow svg to be printed easily.


// 1) move drill to zero position using control keys
// 2) set a zero initalised point for the work (X,Y,Z) hit 'z' 

// Once macine//program is zeroed send the instruction set to the machine by
// pressing 'w' (write) then send the end of file by hitting 'e' (execute/EOF)
// and the machine will execute the written code.

// control keys:

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


import processing.serial.*;

  Serial myPort;
  
  int scale = 10; //scale cut to cnc machine - there is there is about 4 pixels to a mm of cut. size of current sketch is set to the dimensions of the test material
  int drillUp = 0;// absolute Z point to lift drill between cuts its defined by the current z + drillCut + drillClearance
  int drillCut = 30; //depth of cut - 30 is a good minimum cut for testing etching etc.
  int drillDown = 0; // absolute Z point to drop drill to cutting depth.
  int drillClearance = 100; // height above drilZinit to raise drill by when moving betwen cuts
  int zScale = 3;
  int drillBit = 5;
  int maxDepth = 100;    // need to work out what the max depth is - probably just need to get depth of board and add 30 until we can sort out something better
  int drillXInit,drillYInit,drillZInit; // intialized zero positions X,Y,Z
  int drillZpos,drillXpos,drillYpos;  // current drill program state
  int xPos,yPos,zPos; //last reported positions in reponse to @OC
  String message; // a generic message variable for tecting/reporting 
  
  

  Shape shapes; // this is the super class for all drawing.
  bezierShape beziers; // this is sub class for bezier curves - employed because I thought it's be a good test case.
  lineShape lines; 
  rectShape rects;
  ellipseShape ellipses;
  dotShape dots;
  
  ArrayList<Shape> shapesList  = new ArrayList<Shape>(); 
  
  //and arrayList that holds all the Shape objects
  //(which shapes themselves are arraylist series of coordinates)
  
 
void keyPressed() {
  
// drill move z key definitions
//[ = 50 increment, p = 5 incrment, o = 1 increment, shift and key to raise    
  
if (key == 'w') {
   printAllShapes();
 } else if (key == '[') {
    drillMove(50,'z');
  }  else if (key == 'p') {  
    drillMove(5,'z');
  }  else if (key == 'o') {  
    drillMove(1,'z');
  }  else if (key == '{') {
    drillMove(-50,'z');
 }  else if (key == 'P') {   
    drillMove(-5,'z');
    }  else if (key == 'O') {   
    drillMove(-1,'z');
    
// drill move x key definitions
// ' = 500 increment, ; = 100 incrment, l = 1 increment, shift and key to raise  
  
  } else if (key == 39) {  // apostrophe
    drillMove(500,'x');
  }  else if (key == 59) {  //semi-colon
    drillMove(100,'x');
  }  else if (key == 'l') {  
    drillMove(1,'x');
  }  else if (key == 34) { // inverted commas
    drillMove(-500,'x'); 
 }  else if (key == 58) {  // colon
    drillMove(-100,'x');
    }  else if (key == 'L') {   
    drillMove(-1,'x');
    
 // drill move y key definitions
// /? = 500 increment, .> = 100 incrment, ,< = 1 increment, shift and key to raise  
  
  
  } else if (key == '/') {
    drillMove(500,'y');
  }  else if (key == '.') {  
    drillMove(100,'y');
  }  else if (key == ',') {  
    drillMove(1,'y');
  }  else if (key == '?') {
    drillMove(-500,'y');
 }  else if (key == '>') {   
    drillMove(-100,'y');
    }  else if (key == '<') {   
    drillMove(-1,'y');  
    
  // other control keys 
  // Z for zeroing XYZ - move to Zero position and hit Z. must zero before cutting. this needs to be coded as a check so that W doesn't work before zeroing.
  // X machine initalisation -  currently a bit buggy - check it machine returns MD not UC before continuing
  // R Reset machine - often need to hit this twice and then intialize machine and check for response
  
  
  } else if (key == 'c') {
    println("return current position:");
    myPort.write("@OC;" + (char)13 + (char)26 );  
  } else if (key == 'e'){
    println("Calling end of file");
    myPort.write( "" + (char)13 + (char)26 );
  } else if (key == 'r'){
   resetProcedure();
  } else if (key == 'x'){
  machineInit(myPort);
  } else if (key == 'z'){
   zeroInit(myPort);
  } else if (key == 'v'){
   MovetoZeroInit();
  }
}  
  
  
// main class for all shapes - creates an object that has an ArrayList (p) as its principle element
//this ArrayList holds arrays of integer pairs.
  
class Shape { 
  
  ArrayList<int[]> p = new ArrayList<int[]>(); //create an arrayList that will hold pairs of coordinates.
  
  Shape() {  //constructor is empty...every shape will be different...
   } 
  
  // Shape has two functions which I hope to make work for all shape objects 
  //- a screen draw function drawPoints() and a printToCNC()
  // both need rewriting because the logic at the moment is to print the drawn screen coords to the CNC
  //it should be the other way round - the CNC coordinates are calculated at its resolution then that reduced for the screen.
  
  //Draw to screen:
  
  void drawPoints () { 
  int a,b,z,c=0,d=0; //holders for stepped coordinates
  //noStroke();
  fill(0); //default fill needs removing
  for( int j = 0; j < p.size(); j++ ) {   // run though arrayList of shape called p    
           a = (p.get(j)[0]);             // get X coordinate
           b = (p.get(j)[1]); 
           z = (p.get(j)[2]);
          
          //  get y coordinate           
          if (p.size()==1){
          fill(z);
          ellipse(a,b,drillBit,drillBit);  
          }
          stroke(z);
           if (j > 0) {                   // skip if this is first point and therefore not yet a line
             line(c,d,a,b);              // draw the line 
           }
           c = a;                        // hold X point for next step
           d = b;                        // hold y point for next step
       //  ellipse(a,b,4,4);             // leave in to draw actually points as ellipses
        }
  }
  
  //see notes above at beginning of methods
  // this writes a set of commands that format the shape in HPGL.
  // currently scaleing to 10* the window resolution set as a public int at top (scale)
  // scale is approx 4 pixels per mm.
  
  void printToCNC(){
    int a,b,z;                       // x,y,z  
    float zQuotient = ((float)(maxDepth-drillCut))/255;
    println(zQuotient);
  
    message=("@ZD 40.0;" );        // set z move speed.
    myPort.write(message);         // write z move speed to machine
    println(message);              //print command to console  
    delay(100);                           // not sure why this delay is here - probably a remnant of old code 
    drillDown = drillZInit + drillCut;    // calculate absolute z value to cutting depth (drillCut defined at head, drillZinit defined by zeroInit function toward end of code))
    drillUp = drillZInit - drillClearance; // calculte absolute z value to lift drill between cuts (drillClearance set at head. drillZInit set by zeroInit function below)

    
      for( int j = 0; j < p.size(); j++ ) {                // run through arrayList p of shape (a list of paired coordinates) 
           a = (p.get(j)[0]);                              // get x coordinate
           a = a*scale+drillXInit;                         // scale x (scale set at head) and add offset based on zeroInit() values (drillXinit)
           b = (p.get(j)[1]);                              // get y coordinate
           b = b*scale+drillYInit;                       // scale y and add offset based in zeroInit() function
           z = (int)(zQuotient * (255-(p.get(j)[2]))); // (maxDepth-drillCut)/255  = Zquotient
           
           drillDown = drillZInit + drillCut + z; 
           message=("PA " + (a) +", " + (b) + " ;");       // write point command 
           myPort.write(message);                          // to serial myPort
           println(message);                               // print to console   
           if (j==0){                                      // if this is the first point move drill down to cut base don set drillCut, drillZInit & drillXlearance set at head or in zeroInit() function
                          
              message=("@ZA " + drillDown + ";");
              myPort.write(message);
              println(message);
             
           }
          
          
   }
   message=("@ZA " + drillUp + ";" );                      // lift drill at end of each cut
    myPort.write(message);
    println(message);
   
  
  }
}
 
 
// this is the first subclass of shape and provides a model/prototype for others....
// line and point should be the nex ones and easy to do.
// circles and arcs not so easy and pShapes are in progress and pretty complicated

class bezierShape extends Shape {                            
  
  int x1,y1,c1,d1,c2,d2,x2,y2,steps,z1;                    // kept exactly the same as Bezier() with the steps added a a way of defining resolution of curve.

  bezierShape(int x1,int y1,int c1,int d1,int c2,int d2,int x2,int y2,int steps,int z1) {  //this is what I hope to do with each of procssing draw functions - a shape/subclass for each
 
    super();
    this.x1 = x1;
    this.y1 = y1;
    this.c1 = c1;
    this.d1 = d1;
    this.c2 = c2;
    this.d2 = d2;
    this.x2 = x2;
    this.y2 = y2;
    this.steps = steps;
    this.z1 = z1;
    
  }
  
  
  // bezierFill() interpolates the bezier to a series of points dependent on the variable 'steps' 
  // it then fills the arraylist (initialised in the constructor) for the shape with these coords  
  
 void bezierFill () { 

    for (int i = 0; i <= steps; i++) {      //steps through all points in the curve and gets xy coords
    float t = i / float(steps);
    float x = bezierPoint(x1,c1,c2,x2,t);
    float y = bezierPoint(y1,d1,d2,y2,t);

      if (x > 0 && x <= width && y > 0 && y<=height){   //if the point is on the screen add it to the                                                    
      p.add(new int[]{(int)x,(int)y,z1}); // int array pair within the shapes array list.
    } else {
      return;
    }
   
   
    
   }
   
   

 }

}


// working on line addition

class lineShape extends Shape {                            
  
  int x1,y1,x2,y2,z1,z2;

  lineShape(int x1,int y1,int x2,int y2, int z1, int z2) {  
 
    super();
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.z1 = z1;
    this.z2 = z2;
    
    
    
  }
  
  
 void lineFill () { 
  
    if (x1 > 0 && x1 <= width && y1 > 0 && y1<=height && x2 > 0 && x2 <= width && y2 > 0 && y2 <= height){                                                   
      p.add(new int[]{x1,y1,z1});                                                 
      p.add(new int[]{x2,y2,z1}); 
    } else {
      return;
    }
   
   
    
 }
}

// working on rect addition

class rectShape extends Shape { 
  
  
  int a,b,c,d,z1;
  

  rectShape(int a,int b,int c,int d,int z1) {  
 
    super();
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.z1 = z1;
    //this.tl = tl;
    //this.tr = tr;
    //this.br = br;
    //this.bl = bl;
    
  }
  
  
 void rectFill () { 
  
    if (a > 0 && a <= width && b > 0 && b<=height && a+c > 0 && a+c <= width && b+d > 0 && b+d <= height){                                                   
      p.add(new int[]{a,b,z1});                                                 
      p.add(new int[]{a+c,b,z1});
      p.add(new int[]{a+c,b+d,z1});                                                 
      p.add(new int[]{a,b+d,z1}); 
      p.add(new int[]{a,b,z1});
    } else {
      return;
    }
   
   
    
 }
}

class dotShape extends Shape { 
  
  
  int a,b,depth,bitSize;
  

    dotShape(int a,int b,int depth,int bitSize) {  
 
    super();
    this.a = a;
    this.b = b;
    this.bitSize = bitSize;
    this.depth = depth;
  }
  
  
 void dotFill () { 
  
    if (a > 0 && a <= width && b > 0 && b<=height){                                                   
      p.add(new int[]{(int)a,(int)b,(int)depth});                                                 
    } else {
      return;
    }
   
   
    
 }
}

// working on ellipse addition

class ellipseShape extends Shape { 
  
  int x,y,v,w,z1;
  float a,b,steps;
  

  ellipseShape(int x,int y,int a,int b,int steps,int z1) {  
 
    super();
    this.x = x;
    this.y = y;
    this.a = float(a/2);
    this.b = float(b/2);
    this.steps = float(steps);
    this.z1 = z1;
    
  }
  
  
 void ellipseFill () { 
   
        
      float angle=TWO_PI/(float)steps;
      println(degrees(angle));
    
      for(int i=1; i<steps; i++) {
        
          println("angle:" + degrees(angle)*i);
          v= (int)((a*b)/sqrt(b*b+a*a*(tan(angle*i))*(tan(angle*i))));
          w= (int)((a*b*tan(angle*i))/sqrt(b*b+a*a*tan(angle*i)*tan(angle*i)));
          x += v;
          y += w;
          
          //(int)((a*b)/sqrt(a*a+(b*b/tan(angle*i)*tan(angle*i))));
          println(x,y); 
          if (x > 0 && x <= width && y > 0 && y<=height){            //if the point is on the screen add it to the                                                    
               
              p.add(new int[]{(int)x,(int)y,z1});                     // int array pair within the shapes array list.
          } else {
              //return;
          }
        
        
      }
    
  }
}
   
  

// end of the ellipseShape subclass.


// below function is just a control function used to hide/contain new shape/fill/drawPoints
// so that they cn all be called via the one function from the draw...in a manner like the original bezier

void bezierPlot(int x1,int y1,int c1,int d1,int c2,int d2,int x2,int y2,int steps,int...z){
 
 int z1 = z.length > 0 ? z[0] : 0;
  
 beziers = new bezierShape(x1,y1,c1,d1,c2,d2,x2,y2,steps,z1);           //make a new bezier instance
  shapesList.add(beziers);                                           // add the new shape to a master arrayList of shapes
  beziers.bezierFill();                                              // fill the coordinate arrayList with coords
  beziers.drawPoints();                                              // draw the curve on the screen  
  
  
}

void linePlot(int x1,int y1,int x2,int y2,int...z){
 
   int z1 = z.length > 0 ? z[0] : 0;
   int z2 = z.length > 1 ? z[1] : 0;
  println(z1);
  lines = new lineShape(x1,y1,x2,y2,z1,z2);           //make a new line instance
  shapesList.add(lines);                     // add the new shape to a master arrayList of shapes
  lines.lineFill();                        // fill the coordinate arrayList with coords
  lines.drawPoints();                        // draw the line on the screen  
  
  
}

void rectPlot(int a,int b,int c,int d,int...z){
 
  int z1 = z.length > 0 ? z[0] : 0;
  int z2 = z.length > 1 ? z[1] : 0;
  int z3 = z.length > 2 ? z[2] : 0;
  int z4 = z.length > 3 ? z[3] : 0;
  
  rects = new rectShape(a,b,c,d,z1);           //make a new rect instance
  shapesList.add(rects);                               // add the new shape to a master arrayList of shapes
  rects.rectFill();                                    // fill the coordinate arrayList with coords
  rects.drawPoints();                                  // draw the line on the screen  
  
  
}


void dotPlot(int a,int b, int depth, int bitSize){
 
  dots = new dotShape(a,b,depth,bitSize);           //make a new rect instance
  shapesList.add(dots);                               // add the new shape to a master arrayList of shapes
  dots.dotFill();                                    // fill the coordinate arrayList with coords
  dots.drawPoints();                                  // draw the line on the screen  
  
  
}


void ellipsePlot(int x,int y,int a,int b,int steps, int...z){
 
   int z1 = z.length > 0 ? z[0] : 0;
  
  ellipses = new ellipseShape(x,y,a,b,steps,z1);           //make a new rect instance
  shapesList.add(ellipses);                               // add the new shape to a master arrayList of shapes
  ellipses.ellipseFill();                                    // fill the coordinate arrayList with coords
  ellipses.drawPoints();                                  // draw the line on the screen  
  
  
}



void readResponse(Serial myPort) {                    //don't think this is called anymore .... can probably delete
    print("....");
    print(" ...OK");println("");
    while (myPort.available() > 0) {
      
    int inByte = myPort.read();
      
        
    print(char(inByte));

  }
  println("");

}

void resetProcedure(){                      // print the Reset command to the machine. called via r key
  
  print("0");
  message =  (char)0x1b + "RS:" + (char)0x0d + (char)0x1a;
  myPort.write( message );
  xPos = yPos = zPos = drillXpos = drillYpos = drillZpos = drillXInit = drillYInit = drillZInit = 0; //intialise all points
  println("All positions initialized to 0 and machine reset");
  
}

// Initalise the serial port - called one in setup 

void serialInit(){
 
  println(Serial.list());
   // Open the port you are using at the rate you want:
   myPort = new Serial(this, Serial.list()[0], 38400, 'Y', 8, 1.0);
   println("Serial ready");
   myPort.bufferUntil((char)0x1a); ///ASCII LineFeed.
  
}

// Initialise the machine -set file mode - called via X key

void machineInit(Serial myPort){
    
  
  // ASk for MD
  println("Calling MD");
  String message =  (char)0x1b + "MD:" + (char)0x0d + (char)0x1a;
  myPort.write(message);
  delay(100);
  //readResponse(myPort);

  println("Calling LM");
  // Set to LM
  message = (char)27 + "FM:" + (char)13 + (char)26;
  myPort.write( message );
  delay(100);
  //readResponse(myPort);
  
  println("Calling MD");
  message =  (char)0x1b + "MD:" + (char)0x0d + (char)0x1a;
  myPort.write( message );
  delay(100);
  //readResponse(myPort);
  
  println("READY");
  
  }
  
  
  // this function controls all manual drill moves increments and axis defined in keypress
  
   void drillMove(int increment, char axis){

    
    myPort.write("@ZD 40.0;");// + (char)13 + (char)26 );
    //delay(100);
    
    if (axis == 'z') { 
    drillZpos = drillZpos + increment;
    myPort.write("@ZA " + drillZpos + ";" + (char)13 + (char)26 );
    }
     if (axis == 'x') { 
    drillXpos = drillXpos + increment;      
    myPort.write("PA " + drillXpos + ", " + drillYpos + ";" + (char)13 + (char)26 );
    
    }
     if (axis == 'y') { 
    drillYpos = drillYpos + increment;   
     myPort.write("PA " + drillXpos + ", " + drillYpos + ";" + (char)13 + (char)26 );
    }
    println("moved to " + drillXpos + ", " + drillYpos  + ", " + drillZpos);
 }
 
 
void MovetoZeroInit(){      
     myPort.write("PA " + drillXInit + ", " + drillYInit + ", " + drillZInit +  ";" + (char)13 + (char)26 );
     drillXpos = drillYpos = drillZpos =0;
  }

 

// this function zeros the current cut position - set the XYZ 0 and press C to intialize the back od drill and start it.
 
  void zeroInit(Serial myPort){
    
     myPort.write("@OC;" + (char)13 + (char)26 );
     delay(100);
    // init x,y,z start drill positions - use 'd,s,a' (down) and "u/y/t" (up) to increment down to desired height then 'i' to use OC to return Z and set as drillCut
    println("Setting surface height at current 'z' value");
    // machine spits out coords in below format ("X: 005600;Y: 000200;Z: 000900;" + (char)0x0d + (char)0x1a);
    drillZInit = zPos;
    drillXInit = xPos;
    drillYInit = yPos;  
    //testing drillZInit assignment.
    println("Work zeroed at position (XYZ): " + drillXInit + ", " + drillYInit + ", " + drillZInit);
    
    
}
  
  
// print all the shapes stored in shapes list by pressing W key...  
  
  void printAllShapes() {
   
    for (Shape shapes: shapesList) shapes.printToCNC();

}

// Serial Event listen..... bufferuntil() is set in serialInit() and allows us to read string rather than char


public void serialEvent(Serial myPort){
  
  String serialString = myPort.readString();
  print(serialString);
  
  if(serialString.startsWith("X:")){                        // if we get an X: than later the lats known position.
    String coords[] = serialString.split("[^0-9]+");        // move X,Y,Z reported into an array of coords
     xPos = Integer.parseInt(coords[1]);                    // parse the string to integers and assign to XYZ   
     yPos = Integer.parseInt(coords[2]);
     zPos = Integer.parseInt(coords[3]); 
   
  } 
 
  

}
