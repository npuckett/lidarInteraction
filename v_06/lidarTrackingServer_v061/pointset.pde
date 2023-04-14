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
color dotColor;


    PointSet(float _ox, float _oy, color _sc, int _bday)
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
    
    public void connect(float drawScale, color lineColor, float lineWeight)
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
