

/**
 * keyPressed: This function handles various key press events.
 * s: Save the current calibration.
 * t: Toggle create tracking zone mode.
 * m: Toggle create ignore zone mode.
 * M: Remove the last created ignore zone.
 * z: Toggle create sensor zone mode.
 * Z: Remove the last created sensor zone.
 * r: Toggle displaying rays.
 * b: Toggle displaying raw points.
 * c: Toggle connect dots mode.
 * B: Toggle displaying blobs.
 * x: Clear all keypoints, tracking zones, ignore zones, and sensor zones.
 * k: Toggle create key point mode.
 * K: Remove the last created key point.
 * h: Toggle menu display.
 * w: Toggle create window mode.
 * W: Clear the send window.
 */
void keyPressed() {
  switch (key) {
    case 'f':
      clearAll();
      fitToCanvas();
      break;
    case 's':
      saveCalibration();
      break;
    case 't':
      handleCreateZone();
      break;
    case 'm':
      handleCreateIgnore();
      break;
    case 'M':
      handleRemoveIgnore();
      break;
    case 'z':
      handleCreateSensorZone();
      break;
    case 'Z':
      handleRemoveSensorZone();
      break;
    case 'r':
      showRays = !showRays;
      break;
    case 'b':
      showRawPoints = !showRawPoints;
      break;
    case 'c':
      connectDots = !connectDots;
      break;
    case 'B':
      showBlobs = !showBlobs;
      break;
    case 'x':
      clearAll();
      break;
    case 'k':
      createKP = !createKP;
      break;
    case 'K':
      removePoint(kps);
      break;
    case 'h':
      menuToggle = !menuToggle;
      break;
    case 'w':
      handleCreateWindow();
      break;
    case 'W':
      handleClearWindow();
      break;
  }
}
void fitToCanvas() {
  PointSet currentPoints = lidarPoints1.getDrawPoints();
  float minX = Float.MAX_VALUE;
  float minY = Float.MAX_VALUE;
  float maxX = Float.MIN_VALUE;
  float maxY = Float.MIN_VALUE;

  for (LidarPoint lp : currentPoints.ldPoints) {
    float x = (float) lp.world.getX();
    float y = (float) lp.world.getY();
    minX = min(minX, x);
    minY = min(minY, y);
    maxX = max(maxX, x);
    maxY = max(maxY, y);
  }

  float rangeX = maxX - minX;
  float rangeY = maxY - minY;

  if (rangeX > 0 && rangeY > 0) {
    float scaleX = width / rangeX;
    float scaleY = height / rangeY;
    float newScaleFactor = min(scaleX, scaleY) * 0.9f; // Add a margin by multiplying by 0.9

    float centerX = (minX + maxX) / 2;
    float centerY = (minY + maxY) / 2;

    cp5.getController("l1x").setValue(((width / 2) - centerX * newScaleFactor)+width/2);
    cp5.getController("l1y").setValue(((height / 2) - centerY * newScaleFactor)+height/2);
    cp5.getController("displayscaleFactor").setValue(newScaleFactor);
  }
}
void handleCreateZone() {
  if (!createZone) {
    tZone = new TrackPoly();
  }
  createZone = !createZone;
  saveCalibration();
}

void handleCreateIgnore() {
  if (!createIgnore && izFirstPoint) {
    iZones.add(new TrackPoly());
  }
  createIgnore = !createIgnore;
  izFirstPoint = !izFirstPoint;
  saveCalibration();
}

void handleRemoveIgnore() {
  if (iZones.size() > 0) {
    iZones.remove(iZones.size() - 1);
    saveCalibration();
  }
}

void handleCreateSensorZone() {
  if (!createSensorZone && sensorZoneFirstPoint) {
    sensorZones.add(new SensorZone(szNumber));
    szNumber++;
  }
  createSensorZone = !createSensorZone;
  sensorZoneFirstPoint = !sensorZoneFirstPoint;
  saveCalibration();
}

void handleRemoveSensorZone() {
  if (sensorZones.size() > 0) {
    sensorZones.remove(sensorZones.size() - 1);
    szNumber--;
    saveCalibration();
  }
}
void clearAll() {
  kps.clear();
  tZone.pList.clear();
  tZone.trackArea = new Polygon();
  sensorCount = 0;
  iZones.clear();
  sensorZones.clear();
  szNumber = 0;
  saveCalibration();
}

void handleCreateWindow() {
  createWindow = !createWindow;
  if (!createWindow) {
    wPointCount = 0;
  }
}

void handleClearWindow() {
  sendWindow = new TrackWindow(0, 0);
  saveCalibration();
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