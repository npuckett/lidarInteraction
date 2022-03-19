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
    void display(float drawScale)
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
    void sendPoints()
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
