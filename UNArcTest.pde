// UN Funding by Agency and Country Arc Diagram Test
// estimated 35 agencies
// 193 member states


import processing.pdf.*;

////Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;
boolean recording = false; // used for MovieMaker output
boolean PDFOUT = false;

// final int numberOfMemberStates = 211;
// final int numberOfUNAgencies = 20;
final int numberOfMemberStates = 10;
final int numberOfUNAgencies = 10;


//// Declare Font Variables
PFont mainTitleF;


//// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;

/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  background(255);
  //// PDF output
  // size(800, 450, PDF, generateSaveImgFileName(".pdf"));
  //// Regular output
  size(1080, 1080); // quarter page size

  margin = width * pow(PHI, 6);
  println("margin: " + margin);
  PLOT_X1 = margin;
  PLOT_X2 = width-margin;
  PLOT_Y1 = margin;
  PLOT_Y2 = height-margin;
  PLOT_W = PLOT_X2 - PLOT_X1;
  PLOT_H = PLOT_Y2 - PLOT_Y1;

  rSn = 47; // 4,7,11,18,29...;
  randomSeed(rSn);





  mainTitleF = createFont("Helvetica", 18);  //requires a font file in the data folder?

  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}

void draw() {
  // background(255);
  fill(255,47);
  stroke(255,50);
  strokeWeight(1);
  rect(0,0,width,height);




  fill(0);

  stroke(0);
  float agencyX, agencyY, fundingX, fundingY, countryX, countryY;
  agencyY = PLOT_Y2;
  countryY = PLOT_Y2;
  fundingX = PLOT_X1+(PLOT_W*(1.0*numberOfUNAgencies/numberOfMemberStates));

  line(PLOT_X1, agencyY, PLOT_X1+300, agencyY);
  line(PLOT_X2, countryY, PLOT_X2-300, countryY);
  line(fundingX, PLOT_Y2-300, fundingX, PLOT_Y1);  




  for (int i = 0; i < numberOfMemberStates*numberOfUNAgencies; i++) {
  // for (int i = 0; i < 1610; i++) {
    strokeWeight(.15); 
    // agencyX = map(random(1), 0, 1, PLOT_X1, PLOT_X1+300);
    // countryX = map(random(1), 0, 1, PLOT_X2, PLOT_X2-300);
    // fundingY = map(random(1), 0, 1, PLOT_Y2-300, PLOT_Y1);

    agencyX = random(1.0*PLOT_X1, 1.0*PLOT_X1+300);
    countryX = random(1.0*PLOT_X2, 1.0*PLOT_X2-300);
    fundingY = random(1.0*PLOT_Y2-300, 1.0*PLOT_Y1);


    // ellipse(agencyX, agencyY, 3, 3);
    // ellipse(countryX, countryY, 3, 3);
    // ellipse(fundingX, fundingY, 3, 3);
    noFill();
    stroke(0);
    // strokeWeight(1);
    beginShape();
    curveVertex(agencyX, agencyY+100); // first control point
    curveVertex(agencyX, agencyY); // also the first data point
    curveVertex(fundingX, fundingY);
    curveVertex(countryX, countryY);
    curveVertex(countryX-321, countryY+321); // ending control point
    endShape();
  }







  // textFont(mainTitleF);
  // fill(47, 47);
  // text("sspboyd", PLOT_X1, PLOT_Y2);

  if (PDFOUT) exit();
  if (recording) saveFrame("MM_output/" + getSketchName() + "-#####.png");
}

void keyPressed() {
  if (key == 'S') screenCap(".tif");
}

void mousePressed() {
}

String generateSaveImgFileName(String fileType) {
  String fileName;
  // save functionality in here
  String outputDir = "output/";
  String sketchName = getSketchName() + "-";
  String randomSeedNum = "rSn" + rSn + "-";
  String dateTimeStamp = "" + year() + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);

  //// With using a rSn (random seed number)
  fileName = outputDir + sketchName + randomSeedNum + dateTimeStamp + fileType;
  //// Without rSn
  // fileName = outputDir + sketchName + dateTimeStamp + fileType;

  return fileName;
}

void screenCap(String fileType) {
  String saveName = generateSaveImgFileName(fileType);
  save(saveName);
  println("Screen shot saved to: " + saveName);
}

String getSketchName() {
  String[] path = split(sketchPath(), "/");
  return path[path.length-1];
}
