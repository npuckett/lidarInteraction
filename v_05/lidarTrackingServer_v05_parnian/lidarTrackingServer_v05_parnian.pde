import oscP5.*;
import netP5.*;




import controlP5.*;
import java.util.*;
import java.util.Collections;


import java.awt.Polygon;
import java.awt.geom.Point2D;
import java.awt.geom.Path2D;
import java.awt.Rectangle;
import java.awt.geom.Rectangle2D;
import java.awt.geom.Ellipse2D;
import java.util.Arrays;

import java.net.InetAddress;
import java.net.UnknownHostException;

import com.oblac.nomen.*;
import com.oblac.nomen.data.*;

import processing.pdf.*;




ControlP5 cp5;

///OSC variables
int lidarPort1 = 8000;

String connectPattern = "/server/connect";
String serverIP = "localhost";
NetAddress serverLocation; 
int connectPort = 8000;
String connectMessage = "/server/connect";

int broadcastPort = 9000;
OscP5 lidarFeed1;
OscP5 lidarFeed2;
OscP5 trackDataOutput;

NetAddressList broadcastList = new NetAddressList();
///OSC variables

///setting IRL scale and drawing scale

float displayscaleFactor = 0.02;
///setting IRL scale and drawing scale

PrintWriter writeFile;
 

float trackPointJoinDis = 100.0;
int maxTrackPoints = 60;
float persistTolerance = 60.0;

int clipPlane = 5000;
int l1x = 10000;
int l1y = 10000;
float l1Rot = 0.0;
int l2x = 10000;
int l2y = 10000;
float l2Rot = 0.0;
int panX =0;
int panY =0;
int ptMin;

int sensorCount =0;
ArrayList<KeyPoint> kps = new ArrayList<KeyPoint>();

long lastFrame = 0;
int drawMode = 0; 
boolean buffersReady = false;
//0= just draw points , 1= make the backgroudn poly, 2 = track

JSONObject cVals;

TrackPoly tZone = new TrackPoly();; 

boolean createZone = false;
boolean prevCreate = false;
boolean createKP = false;
boolean showRays = false;
boolean showRawPoints = true;

int totalFrames = 10;
int frameCount = 0;
boolean record = false;
boolean firstFrame = true;
String folderTarget;
boolean connectDots = false;
boolean showBlobs = true;

int superSamp = 10;

int sx = 800;

int blobID = 0;
PointStream lidarPoints1 = new PointStream(4,"/lidar1",color(255,0,0));

PFont p;
ControlFont font;
int slPos=25;
int slSpacing = 25;


static final String LOCAL_IP = findLanIp();


PImage controlMenu;
boolean menuToggle = true;

int outSizeX = 1920;
int outSizeY = 1080;
int wPointCount = 0;
float winX1;
float winY1;
float winX2;
float winY2;
boolean createWindow = false;

public void settings()
{
size(1300,1000,P2D);


}

void setup() 
{
controlMenu = loadImage("menuControls.png");
p = createFont("Verdana",20); 
font = new ControlFont(p);
//frameRate(12);
cVals = loadJSONObject("calib.json");
///OSC properties lidar input port
 OscProperties op1 = new OscProperties();
  op1.setListeningPort(lidarPort1);
  op1.setDatagramSize(256);
  lidarFeed1 = new OscP5(this, op1);
 



createGUI();           
///////////////////////////////////////////

buffersReady=true;

////////////////////////////////////////////
//load saved points
JSONArray savedPoly = loadJSONArray("polypoints.json");
tZone.pList.clear();
for(int i=0;i<savedPoly.size();i++)
{
  JSONObject pt = savedPoly.getJSONObject(i);
  tZone.addSavedPoint(pt.getInt("x"),pt.getInt("y"));
}
 //
 JSONArray savedkeypoints = loadJSONArray("keypoints.json");
kps.clear();
for(int i=0;i<savedkeypoints.size();i++)
{
  JSONObject pt = savedkeypoints.getJSONObject(i);
  kps.add(new KeyPoint(pt.getFloat("x"),pt.getFloat("y"),displayscaleFactor,sensorCount));
     sensorCount++;
}


     
connectClient(LOCAL_IP);
}

void draw() 
{
 
//boolean updateCheck = checkRefresh(lastFrame);

        

background(255);     
showIPinfo();          
          if(createZone)
          {
               stroke(0,255,0);
               strokeWeight(40);
               noFill();
               rectMode(CORNER);
               rect(0,0,width,height);

          }
          if(createKP)
          {
               stroke(255,165,0);
               strokeWeight(40);
               noFill();
               rectMode(CORNER);
               rect(0,0,width,height);

          }
          if(createWindow)
          {
               stroke(0);
               noFill();
               rect(winX1,winY1,(mouseX-winX1),(((mouseX-winX1)*outSizeY)/outSizeX));
          }
          
          tZone.display(displayscaleFactor);
          tZone.sendPoints();

          for(KeyPoint pt : kps)
          {
               pt.display(displayscaleFactor);
          }


          if(lidarPoints1.available)
          {    
               lidarPoints1.show();
               lidarPoints1.connect(kps);
          }
  
              
             

if(menuToggle)
{
image(controlMenu,1100,0);

}



}






void keyPressed() 
{
     if(key=='s')
     {
          saveCalibration();
     }
     if(key=='t')
     {
          if(!createZone)
          {
               
               tZone = new TrackPoly();
          }
         // println("TTTTTTTTTTTTTTTTTTTTTT");
               createZone = !createZone;
          
     }
     if(key=='r')
     {
          showRays = !showRays;
     }
     if(key=='b')
     {
          showRawPoints = !showRawPoints;
     }
     if(key=='p')
     {
          record = true;
     }
     if(key=='c')
     {
      connectDots = !connectDots; 
     }
     if(key=='B')
     {
      showBlobs =  !showBlobs;   
     }
     if(key=='x')
     {
     kps.clear();
     tZone.pList.clear();
     tZone.trackArea = new Polygon();
     saveCalibration();
     sensorCount=0;
     }
     if(key=='k')
     {
       createKP = !createKP;   
     }
     if(key=='K')
     {
          removePoint(kps);
     }
          if(key=='h')
     {
          menuToggle = !menuToggle;
     }
     if(key=='w')
     {
          createWindow = !createWindow;
          if(!createWindow)
          {
               wPointCount=0;
          }
     }
}


void saveCalibration()
{
     

     cVals = new JSONObject();
     cVals.setInt("clipPlane", clipPlane);
     cVals.setInt("l1x",l1x);
     cVals.setInt("l1y",l1y);
     cVals.setFloat("l1Rot",l1Rot);
     cVals.setInt("l2x",l2x);
     cVals.setInt("l2y",l2y);
     cVals.setFloat("l2Rot",l2Rot);
     cVals.setFloat("displayscaleFactor",displayscaleFactor);

     saveJSONObject(cVals, "data/calib.json");


     JSONArray polyPoints = new JSONArray();
     int arrayIndex = 0;
     for(PolyPoint pt : tZone.pList)
     {
      JSONObject pointData = new JSONObject();
      pointData.setInt("x",pt.worldX);
      pointData.setInt("y",pt.worldY);
      polyPoints.setJSONObject(arrayIndex,pointData);
      arrayIndex++;
     }
     saveJSONArray(polyPoints, "data/polypoints.json");

     JSONArray kPoints = new JSONArray();
     arrayIndex = 0;
     for(KeyPoint k : kps)
     {
      JSONObject pointData = new JSONObject();
      pointData.setFloat("x",k.pixelX);
      pointData.setFloat("y",k.pixelY);
      pointData.setInt("number",k.sNumber);
      kPoints.setJSONObject(arrayIndex,pointData);
      arrayIndex++;
     }
     saveJSONArray(kPoints, "data/keypoints.json");

}

void mousePressed()
{

if(mouseButton == LEFT)
{
     if(createZone)
     {
     tZone.addPoint(mouseX,mouseY,displayscaleFactor);
     }

     if(createKP)
     {
     kps.add(new KeyPoint(mouseX,mouseY,displayscaleFactor,sensorCount));
     sensorCount++;
     }

     if(createWindow)
     {
          if(wPointCount==0)
          {
               winX1 = mouseX;
               winY1 = mouseY;
               wPointCount++;
          }
          else 
          {
               tZone.pList.clear();
               tZone.trackArea = new Polygon();
               tZone.addPoint(round(winX1),round(winY1),displayscaleFactor);
               tZone.addPoint(mouseX,round(winY1),displayscaleFactor); 
               tZone.addPoint(mouseX,round(winY1+(((mouseX-winX1)*outSizeY)/outSizeX)),displayscaleFactor); 
               tZone.addPoint(round(winX1),round(winY1+(((mouseX-winX1)*outSizeY)/outSizeX)),displayscaleFactor); 
               createWindow=false;
               wPointCount=0;  
          }
     }
}



}


void createGUI()
{
cp5 = new ControlP5(this);
cp5.setFont(font);
Group calibration = cp5.addGroup("calibration")
               .setPosition(0,slPos)
                .activateEvent(true)
                .setBarHeight(130)
                .setBackgroundColor(color(0,0,0,80))
                .setWidth(sx+300)
                .setBackgroundHeight(225)
                .setLabel("calibration")
                ;

cp5.addSlider("clipPlane")
     .setPosition(10,slPos)
     .setSize(sx,slSpacing-1)
     .setRange(0,20000)
     .setValue(cVals.getInt("clipPlane"))
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("trackPointJoinDis")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,300)
     .setValue(215)
     .setDecimalPrecision(2)
     .setGroup(calibration)
     ;
cp5.addSlider("persistTolerance")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,300)
     .setValue(250)
     .setDecimalPrecision(2)
     .setGroup(calibration)
     ;
cp5.addSlider("displayscaleFactor")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0.00,0.5)
     .setValue(cVals.getFloat("displayscaleFactor"))
     .setDecimalPrecision(2)
     .setGroup(calibration)
     ;     
cp5.addSlider("l1x")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,15000)
     .setValue(cVals.getInt("l1x"))
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("l1y")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,15000)
     .setValue(cVals.getInt("l1y"))
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("l1Rot")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(-360,360)
     .setValue(cVals.getFloat("l1Rot"))
     .setDecimalPrecision(1)
     .setGroup(calibration)
     ;
/*       
cp5.addSlider("l2x")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,15000)
     .setValue(cVals.getInt("l2x"))
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("l2y")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,15000)
     .setValue(cVals.getInt("l2y"))
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("l2Rot")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(-360,360)
     .setValue(cVals.getFloat("l2Rot"))
     .setDecimalPrecision(1)
     .setGroup(calibration)
     ;
cp5.addSlider("panX")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,15000)
     .setValue(0)
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("panY")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,15000)
     .setValue(0)
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("ptMin")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,1000)
     .setValue(150)
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
cp5.addSlider("superSamp")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(1,200)
     .setValue(1)
     .setDecimalPrecision(0)
     .setGroup(calibration)
     ;
*/

}
static final String findLanIp() 
{
  try {
    return InetAddress.getLocalHost().getHostAddress();
  }
  catch (final UnknownHostException notFound) {
    System.err.println("No LAN IP found!");
    return "";
  }
}

void showIPinfo()
{
fill(0);
textSize(30);
textAlign(LEFT,BOTTOM);
text(LOCAL_IP+" : "+broadcastPort,10,height-20);

}
