import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import controlP5.*; 
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

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class lidarTrackingServer_v05 extends PApplet {





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

float displayscaleFactor = 0.02f;
///setting IRL scale and drawing scale

PrintWriter writeFile;
 

float trackPointJoinDis = 100.0f;
int maxTrackPoints = 60;
float persistTolerance = 60.0f;

int clipPlane = 5000;
int l1x = 10000;
int l1y = 10000;
float l1Rot = 0.0f;
int l2x = 10000;
int l2y = 10000;
float l2Rot = 0.0f;
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

public void settings()
{
size(1300,1100,P2D);


}

public void setup() 
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

public void draw() 
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






public void keyPressed() 
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
}


public void saveCalibration()
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

public void mousePressed()
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

}



}


public void createGUI()
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
     .setRange(0,12000)
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
     .setRange(0.00f,0.5f)
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
public static final String findLanIp() 
{
  try {
    return InetAddress.getLocalHost().getHostAddress();
  }
  catch (final UnknownHostException notFound) {
    System.err.println("No LAN IP found!");
    return "";
  }
}

public void showIPinfo()
{
fill(0);
textSize(30);
textAlign(LEFT,BOTTOM);
text(LOCAL_IP+" : "+broadcastPort,10,height-20);

}
class LidarPoint implements Comparable<LidarPoint>
{
  Point2D local;
  Point2D world;

  float angle;
  float dist;
  float originX;
  float originY;
  
  boolean bgPoint;
  
    LidarPoint(float in_angle, float in_dist, float worldPosX, float worldPosY)
    {
      
      
        ///come back to this seems like an error check 
        //maxDist = (lidarDistance>maxDist) ? lidarDistance : maxDist;
        float localX = 0 + in_dist * sin(radians(in_angle));
        float localY = 0 - in_dist * cos(radians(in_angle)); 
        local = new Point2D.Float(localX,localY);

      
      //angle = (in_angle > 0) ? in_angle : (360+in_angle);
      angle = in_angle;
      dist = in_dist;
      originX = worldPosX;
      originY = worldPosY;
      float wx = localX+worldPosX;
      float wy = localY+worldPosY;

      world = new Point2D.Float(wx,wy);

      //println(localX+"\t"+localY+"\t"+wx+"\t"+wy);
    }


////to use this:  Collections.sort(ldPoints);
  public @Override
    int compareTo(LidarPoint other) 
    {
      return Float.compare(this.angle,other.angle);
    } 

  public void display(float drawScale, int dotColor, boolean drawAsNumbers)
  {
    fill(dotColor);
    noStroke();
      //ellipse(ctrX+map(xPos, 0.0f , scaleFactor, 0.0f, width/2.0f),ctrY+map(yPos, 0.0f , scaleFactor, 0.0f, width/2.0f),width/200,width/200);
     if(drawAsNumbers)
     {
       textAlign(CENTER,CENTER);
       textSize(10);
       text(""+angle,(float)world.getX()*drawScale,(float)world.getY()*drawScale);


     }
     else
     {
      ellipse((float)world.getX()*drawScale,(float)world.getY()*drawScale,width/500,width/500);
      
      if(showRays)
      {
      stroke(dotColor);
      strokeWeight(0.3f);
      line(originX*drawScale,originY*drawScale,(float)world.getX()*drawScale,(float)world.getY()*drawScale);
      }
     }
  }  


  public void adjust(float adjDist, float clipRad)
  {
    dist = (dist<clipRad) ? dist : clipRad;

    dist += adjDist;
    float localX = 0 + dist * sin(radians(angle));
    float localY = 0 - dist * cos(radians(angle)); 
    local.setLocation(localX,localY);
    
    world.setLocation((originX+localX),(originY+localY));

  }
  
  
}
class PointStream
{
int totalFeeds;
int bufferSlots;
PointSet pointBuffer;
ArrayList<TrackBlob> prevBlobs = new ArrayList<TrackBlob>();
ArrayList<TrackBlob> currentBlobs = new ArrayList<TrackBlob>();
DrawBuffer activePoints;
int fillCount;
int streamColor;
String oscTag;
int startPoint;
int prevPoint;
int currentWrite =0;

int ssCount = 0;
PointSet ssPoints = new PointSet(0,0, color(0,0,0), 0);

boolean available = false;
PointStream(int bufferSize, String prefix, int dCol)
{
//pointBuffer = new PointSet(0,0,dCol,fillCount);
oscTag=prefix;
activePoints = new DrawBuffer(bufferSize);
bufferSlots = bufferSize;
fillCount=0;
  for(int i =0;i<bufferSize;i++)
  {
    fillCount++;
    activePoints.pts.add(new PointSet(0.0f, 0.0f, streamColor, fillCount));
  }

}



  public void packagePoints(float ldrAngle, int ldrDistance, int pointNumber, float farClip, int lidarNumber, float ox, float oy, float rAdjust)
    {
      if(buffersReady)
      { 
      PointSet pointBuffer = activePoints.pts.get(currentWrite);
      pointBuffer.originX = ox;
      pointBuffer.originY = oy;
      pointBuffer.angleAdjust = rAdjust;
    
      pointBuffer.lidarNumber = lidarNumber;  
          if(ldrDistance<=farClip)
          {
             
              LidarPoint bufferPoint = new LidarPoint(ldrAngle+pointBuffer.angleAdjust,ldrDistance,pointBuffer.originX,pointBuffer.originY);

              
                if((pointNumber>prevPoint)||(pointBuffer.ldPoints.size()==0))
                {
                  //add the point to the current active slot
                  pointBuffer.addPoint(bufferPoint);
                }
                else
                {
                  //set the birthday for that pointset  
                  fillCount++;
                  if(fillCount>4){available=true;}
                  pointBuffer.birthday=fillCount;
                  //println(fillCount+"\t"+pointBuffer.ldPoints.size()+"\t"+currentWrite+"\t"+activePoints.pts.size());

                  //find the new target, clear it, add the point
                  currentWrite=find(0);
                  //
                  //println("** "+currentWrite);
                  activePoints.pts.get(currentWrite).ldPoints.clear();
                  activePoints.pts.get(currentWrite).addPoint(bufferPoint);
                }

                    
              prevPoint=pointNumber;

          }
      }

      else
      {
        print("..");
      }
    }

 public PointSet getDrawPoints()
 {
   PointSet testPoints = new PointSet(0,0, color(0,0,0), 0);
   for(int i=3;i>=0;i--)
    {
      try 
      {
        testPoints = activePoints.pts.get(find(i));
        break;
      } catch (ConcurrentModificationException e) 
      {
       println("nope"); 
      }
    }
  return testPoints;
 }
  
  public void testing()
  {
println("********************"+find(2));
  }

public void superSample(int samples)
{
ssCount++;
ArrayList<LidarPoint> tempPoints = new ArrayList<LidarPoint>();
if(ssCount<=samples)
{
PointSet freshPoints = getDrawPoints();  
tempPoints = (ArrayList)freshPoints.ldPoints.clone();
ssPoints.ldPoints.addAll(tempPoints);
  if(ssCount==samples)
  {
    background(255);   

    //sort the list
    Collections.sort(ssPoints.ldPoints);
    //draw the list
    
        if(ssPoints.ldPoints.size()>0)
        {
          if(record)
          {
            //folderTarget=("frames/set_"+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second());
            beginRecord(PDF, ("frames/set_"+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second()+"res_"+samples+"_frame_####.pdf")); 
          } 

          if(connectDots)
          {
          ssPoints.connect(displayscaleFactor,color(0,0,0,50),3);
          }

          if(showRawPoints)
            {
              for(LidarPoint pt : ssPoints.ldPoints)
              {
              pt.display(displayscaleFactor,freshPoints.dotColor,false);
              }  
            }
            
          
            endRecord();
            record = false;
            
        }
        ssPoints.ldPoints.clear();
    //reset ssCount
    ssCount = 0;
  }

}


}


  public void show()
  {
    
    
    
    PointSet freshPoints = getDrawPoints();
        if(freshPoints.ldPoints.size()>0)
        {
          if(connectDots)
          {
          freshPoints.connect(displayscaleFactor,color(0,0,0,50),3);
          }

          if(showRawPoints)
            {
              for(LidarPoint pt : freshPoints.ldPoints)
              {
              pt.display(displayscaleFactor,freshPoints.dotColor,false);
              }  
            }

          if(showBlobs)
          {
            ArrayList<TrackBlob> freshBlobs = sortToBlobs(freshPoints.ldPoints,trackPointJoinDis,tZone.trackArea);
            currentBlobs.clear();
            currentBlobs = checkPersistance(freshBlobs,prevBlobs,persistTolerance);

            OscMessage blobData = new OscMessage("/blobs");
            blobData.add(currentBlobs.size());
            for(TrackBlob tb : currentBlobs)
              {
              tb.display(displayscaleFactor,true,true,true,streamColor);
              //send the blob data
              blobData.add(tb.name);
              blobData.add(tb.blobNumber);
              blobData.add((float)tb.center.getX());
              blobData.add((float)tb.center.getY());
              blobData.add((float)tb.boundingBox.getWidth());
              blobData.add((float)tb.boundingBox.getHeight());

              }
              lidarFeed1.send(blobData,broadcastList);
              


              prevBlobs.clear();
              prevBlobs.addAll(currentBlobs);  

          }
        }
      }

    public ArrayList<TrackBlob> sortToBlobs(ArrayList<LidarPoint> rawPts, float jTolerance, Polygon testArea)
    {
    ArrayList<LidarPoint> bgFilteredPts = new ArrayList<LidarPoint>();

    for(LidarPoint testPt : rawPts)
      {
        if(testArea.contains(testPt.world))
        {
          bgFilteredPts.add(testPt);
        }

      }

      ArrayList<TrackBlob> blobList = new ArrayList<TrackBlob>();
      boolean currentlyAdding = false;
      boolean prevState = false;
      for (int i = 0; i<(bgFilteredPts.size()-1); i++)
      {
        double testDist = bgFilteredPts.get(i).world.distance(bgFilteredPts.get(i+1).world);
        
        if((float)testDist<=jTolerance)
          {
          if(currentlyAdding==false)   /////this is where to add the max points filter
          {
            blobList.add(new TrackBlob());
            blobList.get(blobList.size()-1).addPoint(bgFilteredPts.get(i));
            currentlyAdding=true;
          }
          blobList.get(blobList.size()-1).addPoint(bgFilteredPts.get(i+1));    
        }
        else
        {
          currentlyAdding=false;
        }

      }


    if(blobList.size()>1)
    {
    int lastBlob = blobList.size()-1;
    int lastPoint = blobList.get(lastBlob).blobPoints.size()-1;  

    double edgeDistance = blobList.get(lastBlob).blobPoints.get(lastPoint).world.distance(blobList.get(0).blobPoints.get(0).world);

      if((float)edgeDistance<=jTolerance)
      {
        for(LidarPoint ep : blobList.get(0).blobPoints)
        {
          blobList.get(lastBlob).addPoint(ep);
        }
        blobList.remove(0);

      }
    }

    for(int i=0;i<blobList.size();i++)
    {
      if(blobList.get(i).totalPoints<=2)
      {
        blobList.remove(i);
      }
    }



return blobList;


}
 
public void connect(ArrayList<KeyPoint> kp)
{
     OscMessage dsData = new OscMessage("/distanceSensors");
     dsData.add(displayscaleFactor); //0
     dsData.add(kp.size()); //1
     dsData.add(currentBlobs.size()); //2
     
     for(KeyPoint point : kp)
     {
       dsData.add(point.sNumber); //3
       dsData.add((float)point.xPos); //4
       dsData.add((float)point.yPos); //5
       
     
          for(TrackBlob blob : currentBlobs)
          {
            
            float aT = atan2((float)point.center.getY()-(float)blob.center.getY(),(float)point.center.getX()-(float)blob.center.getX());
            float angleTo = degrees(aT);
            //angle = atan2(y2 - y1, x2 - x1) * 180 / PI;
            
               strokeWeight(2);
               stroke(255,165,0);
               line((float)blob.center.getX()*displayscaleFactor,(float)blob.center.getY()*displayscaleFactor,(float)point.center.getX()*displayscaleFactor,(float)point.center.getY()*displayscaleFactor);
              fill(streamColor);
              float sDist = (float)blob.center.distance(point.center);
              float xp = (((float)blob.center.getX()*displayscaleFactor)+((float)point.center.getX()*displayscaleFactor))/2.0f;
              float yp = (((float)blob.center.getY()*displayscaleFactor)+((float)point.center.getY()*displayscaleFactor))/2.0f;
              text(""+sDist+" @ "+angleTo,xp,yp);

              dsData.add(blob.name); //6
              dsData.add(blob.blobNumber);//7
              dsData.add(sDist); //8
              dsData.add(angleTo); //9
          }
     }
     lidarFeed1.send(dsData,broadcastList);


}

    public int find(int ageRank)
    {
      int returnIndex =0; 
      IntList bdays = new IntList();
      for(int i=0;i<activePoints.pts.size();i++)
      {
        int birthday = (int)activePoints.pts.get(i).birthday;
        bdays.append(birthday);
      }
      bdays.sort();
      int found = bdays.get(ageRank);
      for(int i=0;i<activePoints.pts.size();i++)
      {
        if((int)activePoints.pts.get(i).birthday==found)
        {
          returnIndex=i;
          break;         
        }
        
      }
      return returnIndex;


    }

}

class DrawBuffer
{
int bufferSize;
ArrayList<PointSet> pts = new ArrayList<PointSet>();
DrawBuffer(int bSize)
{
  bufferSize = bSize;


}


}




public void oscEvent(OscMessage inputData) 
{

 if(inputData.addrPattern().equals("/lidar1"))
 {
   lidarPoints1.packagePoints(inputData.get(0).floatValue(),inputData.get(1).intValue(),inputData.get(2).intValue(),clipPlane,1,l1x+panX,l1y+panY,l1Rot);
 }
else if(inputData.addrPattern().equals(connectPattern))
{
   connectClient(inputData.netAddress().address());
}


}


 private void connectClient(String theIPaddress) {
     if (!broadcastList.contains(theIPaddress, broadcastPort)) {
       broadcastList.add(new NetAddress(theIPaddress, broadcastPort));
       println("### adding "+theIPaddress+" to the list.");
     } else {
       println("### "+theIPaddress+" is already connected.");
     }
     println("### currently there are "+broadcastList.list().size()+" remote locations connected.");
 }


/*
private void disconnect(String theIPaddress) {
if (broadcastList.contains(theIPaddress, myBroadcastPort)) {
		broadcastList.remove(theIPaddress, myBroadcastPort);
       println("### removing "+theIPaddress+" from the list.");
     } else {
       println("### "+theIPaddress+" is not connected.");
     }
       println("### currently there are "+broadcastList.list().size());
 }

*/




  
class PointSet
{
ArrayList<LidarPoint> ldPoints;
float originX = 0;
float originY = 0;
float angleAdjust =0;
float prevAng;
boolean firstSpin = true;
float startAngle;
int lidarNumber;
int birthday;
int dotColor;


    PointSet(float _ox, float _oy, int _sc, int _bday)
    {
    ldPoints = new ArrayList<LidarPoint>();
    originX = _ox;
    originY = _oy;
    dotColor = _sc;
    birthday = _bday;
    }

    public void addPoint(LidarPoint inPoint)
    {
            
        ldPoints.add(inPoint);
        
    }
    
    public void connect(float drawScale, int lineColor, float lineWeight)
    {
      PShape trackPoly = createShape();
        trackPoly.beginShape();
        trackPoly.stroke(lineColor);
        trackPoly.strokeWeight(lineWeight);
        trackPoly.noFill();
        for(LidarPoint p : ldPoints)
        {
            trackPoly.vertex((float)p.world.getX()*drawScale,(float)p.world.getY()*drawScale);
        }
        trackPoly.endShape(CLOSE);
        shape(trackPoly,0,0);
    }

}
public ArrayList<TrackBlob> sortToBlobs(ArrayList<LidarPoint> rawPts, float jTolerance, Polygon testArea)
{
ArrayList<LidarPoint> bgFilteredPts = new ArrayList<LidarPoint>();

for(LidarPoint testPt : rawPts)
  {
    if(testArea.contains(testPt.world))
    {
      bgFilteredPts.add(testPt);
    }

  }

  ArrayList<TrackBlob> blobList = new ArrayList<TrackBlob>();
  boolean currentlyAdding = false;
  boolean prevState = false;
  for (int i = 0; i<(bgFilteredPts.size()-1); i++)
  {
    double testDist = bgFilteredPts.get(i).world.distance(bgFilteredPts.get(i+1).world);
    
    if((float)testDist<=jTolerance)
      {
      if(currentlyAdding==false)   /////this is where to add the max points filter
      {
        blobList.add(new TrackBlob());
        blobList.get(blobList.size()-1).addPoint(bgFilteredPts.get(i));
        currentlyAdding=true;
      }
      blobList.get(blobList.size()-1).addPoint(bgFilteredPts.get(i+1));    
    }
    else
    {
      currentlyAdding=false;
    }

  }


if(blobList.size()>1)
{
int lastBlob = blobList.size()-1;
int lastPoint = blobList.get(lastBlob).blobPoints.size()-1;  

double edgeDistance = blobList.get(lastBlob).blobPoints.get(lastPoint).world.distance(blobList.get(0).blobPoints.get(0).world);

  if((float)edgeDistance<=jTolerance)
  {
    for(LidarPoint ep : blobList.get(0).blobPoints)
    {
      blobList.get(lastBlob).addPoint(ep);
    }
    blobList.remove(0);

  }
}

for(int i=0;i<blobList.size();i++)
{
   if(blobList.get(i).totalPoints<=2)
   {
     blobList.remove(i);
   }
}



return blobList;


}
 
public ArrayList<TrackBlob> checkPersistance(ArrayList<TrackBlob> newBlobs, ArrayList<TrackBlob> oldBlobs, float minDistance)
{
//https://github.com/jorditost/BlobPersistence/blob/master/WhichFace/WhichFace.pde

  //measure distance from new blobs to all previous ones
  for(int nb=0;nb<newBlobs.size();nb++)
  {
  //make a list
  MeasureManager closestBlob = new MeasureManager();

    for(int ob = 0;ob<oldBlobs.size();ob++)
    {
      double measure = newBlobs.get(nb).center.distance(oldBlobs.get(ob).center);
      if((float)measure<closestBlob.distance)
      {
        closestBlob.index = ob;
        closestBlob.distance = (float)measure;
      }
    }
    //println(closestBlob.distance);
    ///see if the closest old blob is close enough to count
    if(closestBlob.distance<=minDistance)
    {
      newBlobs.get(nb).update(oldBlobs.get(closestBlob.index)); 
    }
    else
    {
      //give it a number
      
      newBlobs.get(nb).assignID();

     
    }


  }

return newBlobs;
}


class MeasureManager
{
int index;
float distance;
  MeasureManager()
  {
    distance=99999;
  }
}







 
public void printPoints(ArrayList<LidarPoint> printList)
{
  println();
  for (LidarPoint pt : printList) 
                     {           
                       print(pt.angle+"\t");     
                      }
                      print("**********");
                     //print(bufferList.size());
                     print("**********");
  
  
}


class KeyPoint
{
  float pixelX;
  float pixelY;
  int xPos;
  int yPos;
  int sNumber;
  Point2D center;
  KeyPoint(float _xp, float _yp, float sf, int _sn)
  {
    pixelX = _xp;
    pixelY = _yp;
    xPos=round(_xp/sf);
    yPos=round(_yp/sf);

    center = new Point2D.Float(_xp/sf,_yp/sf);
    sNumber = _sn;
  }

  public void display(float drawScale)
  {
    noStroke();  
    fill(255,165,0);
    ellipse((float)center.getX()*drawScale,(float)center.getY()*drawScale,20,20);
    textAlign(CENTER,CENTER);
    textSize(20);
    text(("x "+xPos+"  |  y "+yPos),(float)center.getX()*drawScale,((float)center.getY()*drawScale)+25);
    text(""+sNumber,(float)center.getX()*drawScale,((float)center.getY()*drawScale)-30);

  }



}

public void removePoint(ArrayList<KeyPoint> kPoint)
{
  if(kPoint.size()>0)
  {
    kPoint.remove(kPoint.size()-1);
    sensorCount = kPoint.size();
  }


}
class TrackBlob
{
Point2D center;
Path2D allPoints;
Rectangle2D boundingBox;

float radius =0;
int totalPoints;

float joinRadius;
float distFromSource;
int maxPoints;

ArrayList<Point2D> locationHistory;
ArrayList<LidarPoint> blobPoints; //= new ArrayList<LidarPoint>();

String name;
int blobNumber;
/////
long birthDay;
float velocity;
double lastUpdate;
float distanceTraveled;
float life;

Nomen nameGenerator = new Nomen();

TrackBlob()
{
blobPoints = new ArrayList<LidarPoint>();
allPoints = new Path2D.Double();

locationHistory = new ArrayList<Point2D>();
locationHistory.add(new Point2D.Double());
totalPoints =0;
name = nameGenerator.animal().get();
birthDay = millis();

}

public void addPoint(LidarPoint blPt)
{
    blobPoints.add(blPt);
    allPoints.append(new Ellipse2D.Double(blPt.world.getX(),blPt.world.getY(),1,1),true);
    totalPoints++;

    boundingBox = allPoints.getBounds2D();
    center = new Point2D.Double(boundingBox.getCenterX(),boundingBox.getCenterY());
    locationHistory.set(0,center);
    

}

public void display(float drawScale, boolean drawPoints, boolean drawBox, boolean drawHistory, int fColor)
{
life = (millis()-birthDay)/1000.0f;
if(locationHistory.size()>1)
{
    //velocity=(float)(locationHistory.get(1).distance(locationHistory.get(0)));///(millis()-lastUpdate));
    //println(velocity);
    distanceTraveled = calcDistance(locationHistory)/1000;
    
    velocity = distanceTraveled/life;
}



lastUpdate=millis();


rectMode(CORNER);
stroke(fColor);
strokeWeight(1);
fill(0,255,0,100);
rect((float)boundingBox.getX()*drawScale,(float)boundingBox.getY()*drawScale,(float)boundingBox.getWidth()*drawScale,(float)boundingBox.getHeight()*drawScale);
//noStroke();
noFill();
ellipse((float)center.getX()*drawScale,(float)center.getY()*drawScale,10,10);
fill(fColor);
    textSize(22);
    textAlign(CENTER,CENTER);
    text("X: "+(round((float)center.getX())+" | Y: "+round((float)center.getY())),(float)center.getX()*drawScale,((float)center.getY()*drawScale)-20);
    textSize(18);
    text(blobNumber+", "+name+"",(float)center.getX()*drawScale,((float)center.getY()*drawScale)+35);
    //text(distanceTraveled+" "+life+" "+velocity,(float)center.getX()*drawScale,((float)center.getY()*drawScale)+60);

if(drawHistory)
{
    stroke(fColor);
    strokeWeight(1);
    for(int hist = locationHistory.size()-1;hist>0;hist--)
    {
        line((float)locationHistory.get(hist).getX()*drawScale,(float)locationHistory.get(hist).getY()*drawScale,(float)locationHistory.get(hist-1).getX()*drawScale,(float)locationHistory.get(hist-1).getY()*drawScale);
        
    }

}




}


public void update(TrackBlob closestPrev)
{
name = closestPrev.name;
locationHistory.addAll(closestPrev.locationHistory);
birthDay = closestPrev.birthDay;
blobNumber = closestPrev.blobNumber;
}

public float calcDistance(ArrayList<Point2D> allPoints)
{
    float totalDis = 0;
    for(int i=0;i<allPoints.size()-1;i++)
    {
    totalDis+=(float)allPoints.get(i).distance(allPoints.get(i+1));
    }

return totalDis;
}


public void assignID()
{
 int newNumber = blobID++;
 blobNumber = newNumber;


}



















}
class TrackPoly
{
ArrayList<PolyPoint> pList = new ArrayList<PolyPoint>();
Polygon trackArea;
    TrackPoly()
    {
        trackArea = new Polygon();
    }

    public void addPoint(int pointX, int pointY, float sf)
    {
        int x = round(pointX/sf);
        int y = round(pointY/sf);    
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);
    }
    public void addSavedPoint(int x, int y)
    {
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);

    }
    public void display(float drawScale)
    {
        strokeWeight(1);
        fill(0,255,0);
        PShape trackPoly = createShape();
        trackPoly.beginShape();
        trackPoly.stroke(0,255,0);
        trackPoly.strokeWeight(2);
        trackPoly.noFill();
        for(PolyPoint p : pList)
        {
            ellipse(p.worldX*drawScale,p.worldY*drawScale,10,10);
            trackPoly.vertex(p.worldX*drawScale,p.worldY*drawScale);
        }
        trackPoly.endShape(CLOSE);
        shape(trackPoly,0,0);

    }
    public void sendPoints()
    {
        OscMessage trackArea = new OscMessage("/trackArea");
        for(PolyPoint p : pList)
        {
          trackArea.add(p.worldX);
          trackArea.add(p.worldY);  
        }

    lidarFeed1.send(trackArea,broadcastList);

    }



}
class PolyPoint
{
int worldX;
int worldY;
PolyPoint(int _x, int _y)
{
    worldX=_x;
    worldY=_y;
}


}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "lidarTrackingServer_v05" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
