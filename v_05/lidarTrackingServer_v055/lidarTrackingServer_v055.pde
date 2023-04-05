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
int minBlobPoints = 3;
int maxBlobPoints = 100;

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

TrackPoly tZone = new TrackPoly();
ArrayList<TrackPoly> iZones = new ArrayList<TrackPoly>();
ArrayList<SensorZone> sensorZones = new ArrayList<SensorZone>();

boolean sensorZoneFirstPoint = true;
boolean createSensorZone = false;
int szNumber=0;

int outWinX;
int outWinY;

TrackWindow sendWindow = new TrackWindow(0,0);

boolean izFirstPoint = true;
boolean createIgnore = false;
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
boolean menuToggle = false;

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
size(1800,2000,P2D);
//windowResizable(true);

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


JSONArray savedSensorZones = loadJSONArray("szPoints.json");
for(int i=0;i<savedSensorZones.size();i++)
{
     JSONArray singleZone = savedSensorZones.getJSONArray(i);
     sensorZones.add(new SensorZone(i));     
     for(int j=0;j<singleZone.size();j++)
     {
       JSONObject points = singleZone.getJSONObject(j);   
       sensorZones.get(i).addSavedPoint(points.getInt("x"),points.getInt("y"));   
          
     }
     
szNumber++;
}

JSONArray savedMasks = loadJSONArray("maskPoints.json");
for(int i=0;i<savedMasks.size();i++)
{
     JSONArray singleZone = savedMasks.getJSONArray(i);
     iZones.add(new TrackPoly());     
     for(int j=0;j<singleZone.size();j++)
     {
       JSONObject points = singleZone.getJSONObject(j);   
       iZones.get(i).addSavedPoint(points.getInt("x"),points.getInt("y"));   
          
     }
     
}
JSONArray savedWindow = loadJSONArray("windowpoints.json");
JSONObject res = savedWindow.getJSONObject(savedWindow.size()-1);

sendWindow = new TrackWindow(res.getInt("resX"),res.getInt("resY"));
for(int i=0;i<savedWindow.size()-1;i++)
{
  JSONObject pt = savedWindow.getJSONObject(i);
  sendWindow.addSavedPoint(pt.getInt("x"),pt.getInt("y"));
}





     
connectClient(LOCAL_IP);
}

void draw() 
{
background(255);

  if (menuToggle) {
    image(controlMenu, width - 200, 0);
  }

  showIPinfo();

  if (createZone || createIgnore || createSensorZone || createKP || createWindow) {
    

    String modeText = "";
    color modeColor = color(0);

    if (createZone) {
      modeText = "Create Zone";
      modeColor = color(0, 255, 0);
    } else if (createIgnore) {
      modeText = "Create Ignore Zone";
      modeColor = color(255, 0, 0);
    } else if (createSensorZone) {
      modeText = "Create Sensor Zone";
      modeColor = color(0, 0, 255);
    } else if (createKP) {
      modeText = "Create Key Point";
      modeColor = color(255, 165, 0);
    } else if (createWindow) {
      modeText = "Create Window";
      modeColor = color(151, 17, 247);
    }

    stroke(modeColor);
    strokeWeight(50);
    noFill();
    rectMode(CORNER);
    rect(0, 0, width, height);
    text(modeText, width / 2, height / 2);
  }

  tZone.display(displayscaleFactor, color(0, 255, 0));
  tZone.sendPoints();

  int redColor = color(255, 0, 0);
  for (TrackPoly iz : iZones) {
    iz.display(displayscaleFactor, redColor);
  }

  int blueColor = color(0, 0, 255);
  int blueTransparent = color(0, 0, 255, 50);
  for (SensorZone sz : sensorZones) {
    sz.display(displayscaleFactor, blueColor, blueTransparent, lidarPoints1);
  }

  for (KeyPoint pt : kps) {
    pt.display(displayscaleFactor);
  }

  if (lidarPoints1.available) {
    lidarPoints1.show();
    lidarPoints1.connect(kps);
  }

  if (sendWindow.pList.size() > 0) {
    int purpleColor = color(151, 17, 247);
    sendWindow.display(displayscaleFactor, purpleColor, lidarPoints1);
    sendWindow.sendPoints();
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
               saveCalibration();
          
     }
     if(key=='m')
     {
          if(!createIgnore&&izFirstPoint)
          {
               iZones.add(new TrackPoly());
              // iZone = new TrackPoly();
          }
         // println("TTTTTTTTTTTTTTTTTTTTTT");
               createIgnore = !createIgnore;
               izFirstPoint = !izFirstPoint;
               saveCalibration();
          
     }
     if(key=='M')
     {
          if(iZones.size()>0)
          {
            iZones.remove(iZones.size()-1);
               saveCalibration();

          }
     }
     if(key=='z')
     {
          if(!createSensorZone&&sensorZoneFirstPoint)
          {
               sensorZones.add(new SensorZone(szNumber));
               szNumber++;
              // iZone = new TrackPoly();
          }
         // println("TTTTTTTTTTTTTTTTTTTTTT");
               createSensorZone = !createSensorZone;
               sensorZoneFirstPoint = !sensorZoneFirstPoint;
               saveCalibration();
          
     }
     if(key=='Z')
     {
         if(sensorZones.size()>0)
         { 
         sensorZones.remove(sensorZones.size()-1);
         szNumber--;
         saveCalibration();
         }     
      
          
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
     
     sensorCount=0;
     iZones.clear();

     sensorZones.clear();
     szNumber = 0;
     saveCalibration();
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
     if(key=='W')
     {
         sendWindow = new TrackWindow(0,0);
         saveCalibration();
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
     cVals.setInt("minBlobPoints",minBlobPoints);
     cVals.setInt("maxBlobPoints",maxBlobPoints);

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



     JSONArray allSenseZones = new JSONArray();
     for(int i=0;i<sensorZones.size();i++)
     {

     polyPoints = new JSONArray();
     arrayIndex = 0;
     for(PolyPoint pt : sensorZones.get(i).pList)
     {
      JSONObject pointData = new JSONObject();
      pointData.setInt("x",pt.worldX);
      pointData.setInt("y",pt.worldY);
      polyPoints.setJSONObject(arrayIndex,pointData);
      arrayIndex++;
     }
     allSenseZones.setJSONArray(i,polyPoints);
     }
     saveJSONArray(allSenseZones, "data/szPoints.json");

     JSONArray allMaskZones = new JSONArray();
     for(int i=0;i<iZones.size();i++)
     {

     polyPoints = new JSONArray();
     arrayIndex = 0;
     for(PolyPoint pt : iZones.get(i).pList)
     {
      JSONObject pointData = new JSONObject();
      pointData.setInt("x",pt.worldX);
      pointData.setInt("y",pt.worldY);
      polyPoints.setJSONObject(arrayIndex,pointData);
      arrayIndex++;
     }
     allMaskZones.setJSONArray(i,polyPoints);
     }
     saveJSONArray(allMaskZones, "data/maskPoints.json");



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


     JSONArray windowPoints = new JSONArray();
     arrayIndex = 0;
     for(PolyPoint pt : sendWindow.pList)
     {
      JSONObject pointData = new JSONObject();
      pointData.setInt("x",pt.worldX);
      pointData.setInt("y",pt.worldY);
      windowPoints.setJSONObject(arrayIndex,pointData);
      arrayIndex++;
     }
     JSONObject resData = new JSONObject();
     resData.setInt("resX",sendWindow.resolutionX);
     resData.setInt("resY",sendWindow.resolutionY);
     windowPoints.setJSONObject(arrayIndex,resData);
     saveJSONArray(windowPoints, "data/windowpoints.json");

  

}

void mousePressed()
{

if(mouseButton == LEFT)
{
     if(createZone)
     {
     tZone.addPoint(mouseX,mouseY,displayscaleFactor);
     }
     if(createIgnore)
     {
     iZones.get(iZones.size()-1).addPoint(mouseX,mouseY,displayscaleFactor);
     }
     if(createSensorZone)
     {
     sensorZones.get(sensorZones.size()-1).addPoint(mouseX,mouseY,displayscaleFactor);
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
               sendWindow = new TrackWindow(outWinX,outWinY);


               
               sendWindow.addPoint(round(winX1),round(winY1),displayscaleFactor);
               sendWindow.addPoint(mouseX,round(winY1),displayscaleFactor); 
               sendWindow.addPoint(mouseX,round(winY1+(((mouseX-winX1)*outWinY)/outWinX)),displayscaleFactor); 
               sendWindow.addPoint(round(winX1),round(winY1+(((mouseX-winX1)*outWinY)/outWinX)),displayscaleFactor); 
               createWindow=false;
               wPointCount=0; 
               saveCalibration(); 
          }
     }
}



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
