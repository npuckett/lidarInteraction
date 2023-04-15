void createGUI()
{
cp5 = new ControlP5(this);
cp5.setFont(font);
Group calibration = cp5.addGroup("calibration")
               .setPosition(0,slPos)
                .activateEvent(false)
                .setBarHeight(130)
                .setBackgroundColor(color(0,0,0,80))
                .setWidth(width)
                .setBackgroundHeight(300)
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
cp5.addSlider("minBlobPoints")
            .setPosition(10, slPos += slSpacing)
            .setSize(sx, slSpacing - 1)
            .setRange(2, 20)
            .setValue(cVals.getInt("minBlobPoints"))
            .setDecimalPrecision(1)
            .setGroup(calibration)
            ;
cp5.addSlider("maxBlobPoints")
            .setPosition(10, slPos += slSpacing)
            .setSize(sx, slSpacing - 1)
            .setRange(2, 200)
            .setValue(cVals.getInt("maxBlobPoints"))
            .setDecimalPrecision(1)
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
cp5.addSlider("outWinX")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,4000)
     .setValue(1920)
     .setDecimalPrecision(1)
     .setGroup(calibration)
     ;
cp5.addSlider("outWinY")
     .setPosition(10,slPos+=slSpacing)
     .setSize(sx,slSpacing-1)
     .setRange(0,4000)
     .setValue(1080)
     .setDecimalPrecision(1)
     .setGroup(calibration)
     ;

cp5.setFont(smallfont);
// Add buttons to the group
int buttonWidth = 200;
int buttonHeight = 20;

slPos += slSpacing; // Add spacing after the last slider

cp5.addButton("FitToScreen")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("FIT")
  ;//.setCaptionLabel("scale points to fit screen");

cp5.addButton("SaveCalibration")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Save Calibration")
  ;//.setCaptionLabel("Save current calibration settings");

cp5.addButton("ToggleCreateTrackingZone")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Tracking Zone")
  ;//.setCaptionLabel("Toggle creating tracking zones");

cp5.addButton("ToggleCreateIgnoreZone")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Ignore Zone")
  ;//.setCaptionLabel("Toggle creating ignore zones");

cp5.addButton("RemoveIgnoreZone")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Remove Ignore Zone")
  ;//.setCaptionLabel("Remove the selected ignore zone");

cp5.addButton("ToggleCreateSensorZone")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Sensor Zone")
  ;//.setCaptionLabel("Toggle creating sensor zones");

cp5.addButton("RemoveSensorZone")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Remove Sensor Zone")
  ;//.setCaptionLabel("Remove the selected sensor zone");

cp5.addButton("ToggleDisplayRays")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Display Rays")
  ;//.setCaptionLabel("Toggle the display of rays");

cp5.addButton("ToggleDisplayRawPoints")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Raw Points")
  ;//.setCaptionLabel("Toggle the display of raw points");

cp5.addButton("ToggleConnectDots")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Connect Dots")
  ;//.setCaptionLabel("Toggle connecting dots in clusters");

cp5.addButton("ToggleDisplayBlobs")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Display Blobs")
  ;//.setCaptionLabel("Toggle the display of blobs");

cp5.addButton("ClearAll")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Clear All")
  ;//.setCaptionLabel("Clear all zones, keypoints, and windows");

cp5.addButton("ToggleCreateKeypoint")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Keypoint")
  ;//.setCaptionLabel("Toggle creating keypoints");

cp5.addButton("RemoveKeypoint")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Remove Keypoint")
  ;//.setCaptionLabel("Remove the selected keypoint");

cp5.addButton("ToggleMenu")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Menu")
  ;//.setCaptionLabel("Toggle the display of the menu");

cp5.addButton("ToggleCreateWindow")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Toggle Create Window")
  ;//.setCaptionLabel("Toggle creating windows");

cp5.addButton("ClearWindow")
  .setPosition(10, slPos += slSpacing)
  .setSize(buttonWidth, buttonHeight)
  .setGroup(calibration)
  .setLabel("Clear Window")
  ;//.setCaptionLabel("Clear the selected window");



}
void controlEvent(ControlEvent event) {
  String buttonName = event.getController().getName();

  if (buttonName.equals("FitToScreen")) {
    fitToCanvas();;
  } else if (buttonName.equals("SaveCalibration")) {
    saveCalibration();
  } else if (buttonName.equals("ToggleCreateTrackingZone")) {
    handleCreateZone();
  } else if (buttonName.equals("ToggleCreateIgnoreZone")) {
    handleCreateIgnore();
  } else if (buttonName.equals("RemoveIgnoreZone")) {
    handleRemoveIgnore();
  } else if (buttonName.equals("ToggleCreateSensorZone")) {
    handleCreateSensorZone();
  } else if (buttonName.equals("RemoveSensorZone")) {
    handleRemoveSensorZone();
  } else if (buttonName.equals("ToggleDisplayRays")) {
    showRays = !showRays;
  } else if (buttonName.equals("ToggleDisplayRawPoints")) {
    showRawPoints = !showRawPoints;
  } else if (buttonName.equals("ToggleConnectDots")) {
    connectDots = !connectDots;
  } else if (buttonName.equals("ToggleDisplayBlobs")) {
    showBlobs = !showBlobs;
  } else if (buttonName.equals("ClearAll")) {
    clearAll();
  } else if (buttonName.equals("ToggleCreateKeypoint")) {
    createKP = !createKP;
  } else if (buttonName.equals("RemoveKeypoint")) {
    removePoint(kps);
  } else if (buttonName.equals("ToggleMenu")) {
    menuToggle = !menuToggle;
  } else if (buttonName.equals("ToggleCreateWindow")) {
    handleCreateWindow();
  } else if (buttonName.equals("ClearWindow")) {
    handleClearWindow();
  }
}
