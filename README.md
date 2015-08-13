# colinbusP5
The beginning of an API for using processing with a colinbus CNC machine


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


The draw sketch is in a seperate tab in order to keep the draw functions seprate form the api functions which I will eventually consrtuct as a library.

