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
  size(1920,1080);

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

         
}


void draw() 
{
  background(0);
if(blobManager.population>0)
{
int locationX = round(xp+adjustX);
int locationY = round(yp+adjustY);
  
  
//blobManager.show();
ellipse(locationX, locationY, 10,10);





}




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
