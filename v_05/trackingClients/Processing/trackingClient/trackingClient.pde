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


Point2D testPt;

boolean messageDebug = true;

OscP5 trackDataFeed;
int trackDataPort = 9000;



//get this from the data server
String serverIP = "172.17.135.107";
NetAddress serverLocation; 
int connectPort = 8000;
String connectMessage = "/server/connect";

///
String blobDataFilter = "/trackdata/blobs";
String distanceFilter = "/trackdata/distanceSensors";


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

void setup() 
{
  size(1500,1500);

  //osc feed of tracking data
  trackDataFeed = new OscP5(this,trackDataPort);
  
  //server location to send connect message
  serverLocation = new NetAddress(serverIP,8000);
  
  
  /* connect to the broadcaster */
     OscMessage serverControl = new OscMessage(connectMessage,new Object[0]);
      trackDataFeed.flush(serverControl,serverLocation);
}


void draw() 
{
  background(0);
if(blobManager.population>0)
{
blobManager.show();
}


if(totalSensors>0)
{
  drawSensors(displayScaleFactor);
  
  
}


}

void drawSensors(float dsf)
{
 fill(255,165,0);
 ellipse(xp*dsf,yp*dsf,20,20);
 textAlign(CENTER,CENTER);
 text("D: "+distanceTo+" A: "+angleTo,xp*dsf,(yp*dsf)+30);
  
  
}





//data from server
void oscEvent(OscMessage incoming) 
{
  //send the message to the datamanager
      blobManager.readNewData(incoming);
   

 
    if(incoming.addrPattern().equals(blobDataFilter))
   {   
  if(messageDebug)
  {
  //print debug data
  println("### received an osc message with addrpattern "+incoming.addrPattern()+" and typetag "+incoming.typetag());
  incoming.print();
  }
   }
}
