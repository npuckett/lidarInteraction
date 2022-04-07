/*
Basic client for reading from the data server
*/

import oscP5.*;
import netP5.*;
import java.awt.Polygon;
import java.awt.geom.Point2D;
import java.awt.geom.Path2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.Ellipse2D;
import java.util.Collections;
import java.util.*;
import controlP5.*;
import processing.sound.*;
///
 PImage colorRead;
//change this to false to hide background image by default
boolean hideShowBackground = false;



color targetColor1 = color(255,0,0);
color targetColor2 = color(255,0,255);
color targetColor3 = color(149,93,253);
color targetColor4 = color(9,0,255);
color targetColor5 = color(0,187,255);
color targetColor6 = color(67,253,107);
color targetColor7 = color(255,255,0);
color targetColor8 = color(255,136,0);
color targetColor9 = color(94,0,0);

int imageSelect = 0;
PImage image1;
PImage image2;
PImage image3;
PImage image4;
PImage image5;
PImage image6;
PImage image7;
PImage image8;
PImage image9;


color currentColor;

////
Point2D testPt;
ControlP5 cp5;
boolean messageDebug = true;

OscP5 trackDataFeed;
int trackDataPort = 9000;

boolean guiShow = true;

//get this from the data server
String serverIP = "localhost";
NetAddress serverLocation; 
int connectPort = 8000;
String connectMessage = "/server/connect";

///
String blobDataFilter = "/blobs";
String distanceFilter = "/distanceSensors";


float displayScaleFactor = 0.17;
float bx;
float by;


ArrayList<KeyPoint> kps = new ArrayList<KeyPoint>();

PointStream blobManager = new PointStream(3, blobDataFilter, color(255));

float xp =0;
float yp =0;
float distanceTo =0;
float angleTo= 0;
int totalSensors = 0;


int adjustX = 0;
int adjustY = 0;

void setup() 
{
  size(1280,800);

  //osc feed of tracking data
  trackDataFeed = new OscP5(this,trackDataPort);
  
  //server location to send connect message
  serverLocation = new NetAddress(serverIP,8000);
  
  
  /* connect to the broadcaster */
     OscMessage serverControl = new OscMessage(connectMessage,new Object[0]);
      trackDataFeed.flush(serverControl,serverLocation);
      
      
      cp5 = new ControlP5(this);
      cp5.addSlider("displayScaleFactor")
     .setPosition(10,10)
     .setSize(300,30)
     .setRange(0.00,0.5)
     .setValue(0.25)
     .setDecimalPrecision(2)
     ; 
      cp5.addSlider("adjustX")
     .setPosition(10,40)
     .setSize(300,30)
     .setRange(-500,500)
     .setValue(0)
     .setDecimalPrecision(1)
     ; 
      cp5.addSlider("adjustY")
     .setPosition(10,70)
     .setSize(300,30)
     .setRange(-500,500)
     .setValue(0)
     .setDecimalPrecision(1)
     ;   
////
  colorRead = loadImage("colorRead.png");
  
  image1 = loadImage("image1.png");
  image2 = loadImage("image2.png");
  image3 = loadImage("image3.png"); 
  image4 = loadImage("image4.png");
  image5 = loadImage("image5.png");
  image6 = loadImage("image6.png");
  image7 = loadImage("image7.png"); 
  image8 = loadImage("image8.png"); 
  image9 = loadImage("image9.png"); 
         
}


void draw() 
{
  background(0);
if(blobManager.population>0)
{
int locationX = round(((xp*displayScaleFactor)+adjustX));
int locationY = round(((yp*displayScaleFactor)+adjustY));
  
  
//blobManager.show();
ellipse(locationX, locationY, 10,10);


imageSelect = readColorAtCoordinate(locationX,locationY,colorRead);
println("IMAGE: "+imageSelect);

///use that number to select which image to show
  if(imageSelect==1)
  {
   image(image1,0,0); 
  }
  if(imageSelect==2)
  {
   image(image2,0,0); 
  }
    if(imageSelect==3)
  {
   image(image3,0,0); 
  }
    if(imageSelect==4)
  {
   image(image4,0,0); 
  }
  if(imageSelect==5)
  {
   image(image5,0,0); 
  }
  if(imageSelect==6)
  {
   image(image6,0,0); 
  }
    if(imageSelect==7)
  {
   image(image7,0,0); 
  }
    if(imageSelect==8)
  {
   image(image8,0,0); 
  }  
    if(imageSelect==9)
  {
   image(image9,0,0); 
  } 




}




}

int readColorAtCoordinate(int posX, int posY, PImage backgroundColorMasks)
{
 int choice = 0; 
 color currentColor = backgroundColorMasks.get(posX,posY);

 println("RGB Value at: "+mouseX+"|"+mouseY+" : "+round(red(currentColor))+","+round(green(currentColor))+","+round(blue(currentColor)));
 
 //check if it matches target 1
 if(red(currentColor)==red(targetColor1) && green(currentColor)==green(targetColor1) && blue(currentColor)==blue(targetColor1))
 {
  choice = 1; 
 }
 //check if it matches target 2
  if(red(currentColor)==red(targetColor2) && green(currentColor)==green(targetColor2) && blue(currentColor)==blue(targetColor2))
 {
  choice = 2; 
 }
 //check if it matches target 3
 if(red(currentColor)==red(targetColor3) && green(currentColor)==green(targetColor3) && blue(currentColor)==blue(targetColor3))
 {
  choice = 3; 
 }
  //check if it matches target 4
 if(red(currentColor)==red(targetColor4) && green(currentColor)==green(targetColor4) && blue(currentColor)==blue(targetColor4))
 {
  choice = 4; 
 }
 //check if it matches target 5 
  if(red(currentColor)==red(targetColor5) && green(currentColor)==green(targetColor5) && blue(currentColor)==blue(targetColor5))
 {
  choice = 5; 
 }
 //check if it matches target 6
  if(red(currentColor)==red(targetColor6) && green(currentColor)==green(targetColor6) && blue(currentColor)==blue(targetColor6))
 {
  choice = 6; 
 }
 //check if it matches target 7
 if(red(currentColor)==red(targetColor7) && green(currentColor)==green(targetColor7) && blue(currentColor)==blue(targetColor7))
 {
  choice = 7; 
 }
  //check if it matches target 8
 if(red(currentColor)==red(targetColor8) && green(currentColor)==green(targetColor8) && blue(currentColor)==blue(targetColor8))
 {
  choice = 8; 
 }
  //check if it matches target 9
 if(red(currentColor)==red(targetColor9) && green(currentColor)==green(targetColor9) && blue(currentColor)==blue(targetColor9))
 {
  choice = 9; 
 } 
  return choice;
}


//data from server
void oscEvent(OscMessage incoming) 
{
  //send the message to the datamanager
      blobManager.readNewData(incoming);
   
}

void keyPressed()
{
  
 guiShow = !guiShow;
 
 if(guiShow)
 {
   cp5.show();
 }
 else
 {
  cp5.hide(); 
 }
  
}
