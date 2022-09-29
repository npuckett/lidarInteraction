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

void display(float drawScale, boolean drawPoints, boolean drawBox, boolean drawHistory, color fColor)
{
life = (millis()-birthDay)/1000.0;
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
    textSize(40);
    text(blobNumber+" / "+name,(float)center.getX()*drawScale,((float)center.getY()*drawScale)+0);
    textSize(30);
    text("active time: "+roundTo(life,1)+" / Metres: "+roundTo(distanceTraveled,2),(float)center.getX()*drawScale,((float)center.getY()*drawScale)+35);
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


void update(TrackBlob closestPrev)
{
name = closestPrev.name;
locationHistory.addAll(closestPrev.locationHistory);
birthDay = closestPrev.birthDay;
blobNumber = closestPrev.blobNumber;
}

float calcDistance(ArrayList<Point2D> allPoints)
{
    float totalDis = 0;
    for(int i=0;i<allPoints.size()-1;i++)
    {
    float checkDis = (float)allPoints.get(i).distance(allPoints.get(i+1));    
    if(checkDis<30){checkDis=0;}
    totalDis+=checkDis;
    }

return totalDis;
}


void assignID()
{
 int newNumber = blobID++;
 blobNumber = newNumber;


}



















}
