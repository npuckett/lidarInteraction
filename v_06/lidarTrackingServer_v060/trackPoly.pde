class TrackPoly
{
ArrayList<PolyPoint> pList = new ArrayList<PolyPoint>();
Polygon trackArea;
    TrackPoly()
    {
        trackArea = new Polygon();
    }

    void addPoint(int pointX, int pointY, float sf)
    {
        int x = round(pointX/sf);
        int y = round(pointY/sf);    
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);
    }
    void addSavedPoint(int x, int y)
    {
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);

    }
    void display(float drawScale, color polyColor)
    {
        strokeWeight(1);
        fill(polyColor);
       
        PShape trackPoly = createShape();
        trackPoly.beginShape();
        trackPoly.stroke(polyColor);
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
    void sendPoints()
    {
        OscMessage trackArea = new OscMessage("/trackArea");
        trackArea.add(pList.size());
        for(PolyPoint p : pList)
        {
          trackArea.add(p.worldX);
          trackArea.add(p.worldY);  
        }

    lidarFeed1.send(trackArea,broadcastList);

    }



}
class SensorZone
{
ArrayList<PolyPoint> pList = new ArrayList<PolyPoint>();
Polygon trackArea;
int population = 0;
ArrayList<TrackBlob> insideBlobs = new ArrayList<TrackBlob>();
boolean hitAny;
float centerX;
float centerY;
int sNumber;
IntList currentMembers = new IntList();

    SensorZone(int sNum)
    {
        trackArea = new Polygon();
        sNumber = sNum;
    }

    void addPoint(int pointX, int pointY, float sf)
    {
        int x = round(pointX/sf);
        int y = round(pointY/sf);    
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);
        getCenter();
    }
    void addSavedPoint(int x, int y)
    {
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);
        getCenter();

    }
    void display(float drawScale, color polyColor, color hitColor, PointStream ps)
    {
        
        currentMembers.clear();    
        hitAny = false;
        int tempCount = 0;
        ArrayList<TrackBlob> checkBlobs = ps.currentBlobs; 
        for(TrackBlob cb : checkBlobs)
        {
            if(trackArea.intersects(cb.boundingBox))
            {
                //println("hit :"+cb.name);
                tempCount++;
                hitAny=true;
                currentMembers.append(cb.blobNumber);
            }
            population=tempCount;
        }
        
        
        
        strokeWeight(1);
        fill(polyColor);
       
        PShape trackPoly = createShape();
        trackPoly.beginShape();
        trackPoly.stroke(polyColor);
        trackPoly.strokeWeight(2);
        if(hitAny){trackPoly.fill(hitColor);}
        else{trackPoly.noFill();}
        
        
        for(PolyPoint p : pList)
        {
            ellipse(p.worldX*drawScale,p.worldY*drawScale,10,10);
            trackPoly.vertex(p.worldX*drawScale,p.worldY*drawScale);
        }
        trackPoly.endShape(CLOSE);       
        
        shape(trackPoly,0,0);

        fill(0);
        textSize(30);
        textAlign(CENTER,CENTER);
        text("zone "+sNumber+" : "+population,centerX*displayscaleFactor,centerY*displayscaleFactor);

        OscMessage sensorArea = new OscMessage("/sensorZones/"+sNumber);
        sensorArea.add(population);//0

        for(int bNums : currentMembers)
        {
            sensorArea.add(bNums);
        }
        lidarFeed1.send(sensorArea,broadcastList);

    }

    void getCenter()
    {
        float tempX = 0;
        float tempY = 0;
        for(PolyPoint p : pList)
        {
            tempX+=p.worldX;
            tempY+=p.worldY;
        }
        centerX = tempX/pList.size();
        centerY = tempY/pList.size();


    }
    void sendPoints()
    {
        OscMessage trackArea = new OscMessage("/trackArea");
        trackArea.add(pList.size());
        for(PolyPoint p : pList)
        {
          trackArea.add(p.worldX);
          trackArea.add(p.worldY);  
        }

    lidarFeed1.send(trackArea,broadcastList);

    }



}


class TrackWindow
{
ArrayList<PolyPoint> pList = new ArrayList<PolyPoint>();
Polygon trackArea;
int resolutionX;
int resolutionY;

ArrayList<TrackBlob> insideBlobs = new ArrayList<TrackBlob>();

    TrackWindow(int inResX, int inResY)
    {
        trackArea = new Polygon();
        resolutionX = inResX;
        resolutionY = inResY;
    }

    void addPoint(int pointX, int pointY, float sf)
    {
        int x = round(pointX/sf);
        int y = round(pointY/sf);    
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);
    }
    void addSavedPoint(int x, int y)
    {
        pList.add(new PolyPoint(x,y));
        trackArea.addPoint(x,y);

    }
    void display(float drawScale, color polyColor, PointStream ps)
    {
        ArrayList<TrackBlob> checkBlobs = ps.currentBlobs;
        insideBlobs.clear(); 
        for(TrackBlob cb : checkBlobs)
        {
            if(trackArea.contains(cb.center))
            {
               
            insideBlobs.add(cb);
            }
        }
        
        
        strokeWeight(1);
        fill(polyColor);
       
        PShape trackPoly = createShape();
        trackPoly.beginShape();
        trackPoly.stroke(polyColor);
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
    void sendPoints()
    {
        OscMessage trackWindowM = new OscMessage("/trackWindow");
        trackWindowM.add(insideBlobs.size());
        for(TrackBlob tb : insideBlobs)
        {
         int relX = round(map(((float)tb.center.getX()-pList.get(0).worldX),0,(pList.get(1).worldX-pList.get(0).worldX),0,resolutionX));   
         int relY = round(map(((float)tb.center.getY()-pList.get(0).worldY),0,(pList.get(3).worldY-pList.get(0).worldY),0,resolutionY));
        trackWindowM.add(relX);
        trackWindowM.add(relY);
        println(relX+"\t"+relY);
        }

    lidarFeed1.send(trackWindowM,broadcastList);

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
