// UN Funding by Agency and Country Arc Diagram Test

////Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;
boolean recording = false; // used for MovieMaker output

final int numberOfMemberStates = 211;
final int numberOfUNAgencies = 20;

Table agencyCountryTbl, expenditureByCountryTbl, agencyExpenditureTotalTbl;
int fundingAxisMax, fundingAxisMin;

//// Declare Font Variables
PFont mainTitleF, axesLabelF;

//// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;

/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  background(255);
  // PDF output
  // size(1080, 1080, PDF, generateSaveImgFileName(".pdf"));
  // Regular output
  size(1900, 960);

  setPositioningVariables();
  rSn = 47; // 4,7,11,18,29...;
  randomSeed(rSn);

  // load data
  agencyCountryTbl = loadTable("Agency_Expenditure_by_Country_2015.csv", "header");
  expenditureByCountryTbl = loadTable("Total_Expenditure_by_Country.csv", "header");
  agencyExpenditureTotalTbl = loadTable("Agency_Expenditure_Total_2015.csv", "header");

  // prep data
  // min / max for funding axis
  fundingAxisMin = 0;
  fundingAxisMax = 0;
  for (int i=0; i < agencyCountryTbl.getRowCount(); i++) {
    TableRow agencyCountryRow = agencyCountryTbl.getRow(i);
    int  currAmtVal= agencyCountryRow.getInt("Amount");
    if ( currAmtVal > fundingAxisMax) fundingAxisMax = currAmtVal;
  }
  println("fundingAxisMax = "+ fundingAxisMax);
  mainTitleF = createFont("Helvetica", 24);  //requires a font file in the data folder?
  axesLabelF = createFont("Helvetica", 12);  //requires a font file in the data folder?

  println("agencyCountryTbl row count = " + agencyCountryTbl.getRowCount());
  println("expenditureByCountryTbl row count = " + expenditureByCountryTbl.getRowCount());
  println("agencyExpenditureTotalTbl row count = " + agencyExpenditureTotalTbl.getRowCount());
  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}

/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void draw() {
  background(255);

  float agencyX, agencyY, fundingX, fundingY, countryX, countryY;
  PVector agencyAxis1, fundingAxis1, countryAxis1, agencyAxis2, fundingAxis2, countryAxis2;
  agencyAxis1 = new PVector();
  agencyAxis2 = new PVector();

  fundingAxis1 = new PVector();
  fundingAxis2 = new PVector();

  countryAxis1 = new PVector();
  countryAxis2 = new PVector();

  fundingAxis1.x = PLOT_X1 + (PLOT_W*(1-PHI));
  fundingAxis1.y = PLOT_Y1;
  fundingAxis2.x = fundingAxis1.x;
  fundingAxis2.y = PLOT_Y1 + (PLOT_H*(PHI));

  agencyAxis1.x = PLOT_X1;
  agencyAxis1.y = PLOT_Y2;
  agencyAxis2.x = PLOT_X1 + (PLOT_W*(1-PHI))-50;
  agencyAxis2.y = PLOT_Y2;

  // countryAxis1.x = PLOT_X1 + (PLOT_W * (1-PHI))+50;
  // countryAxis1.y = PLOT_Y2;
  // countryAxis2.x = PLOT_X2;
  // countryAxis2.y = countryAxis1.y;

  countryAxis1.x = PLOT_X2- PLOT_W * (pow(PHI, 3));
  countryAxis1.y = PLOT_Y1;
  countryAxis2.x = PLOT_X2;
  countryAxis2.y = PLOT_Y2;


  // render the axes
  stroke(0, 50);
  line(agencyAxis1.x, agencyAxis1.y, agencyAxis2.x, agencyAxis2.y);
  line(countryAxis1.x, countryAxis1.y, countryAxis2.x, countryAxis2.y);
  line(fundingAxis1.x, fundingAxis1.y, fundingAxis2.x, fundingAxis2.y);

  // label axes
  fill(0);
  textFont(axesLabelF);
  // text("Countries", countryAxis1.x, countryAxis1.y + textAscent() + 5);
  text("UN Agencies", agencyAxis1.x, agencyAxis1.y + textAscent() + 5);
  text("Funding", fundingAxis1.x  - textWidth("Funding") - 5, fundingAxis1.y + textAscent());

  // add country names
  int rowCounter=0;
  for (TableRow row : expenditureByCountryTbl.rows()) {
    float tx = countryAxis1.x + 18;
    float ty = map(rowCounter+=1, 0, expenditureByCountryTbl.getRowCount(), PLOT_Y1, PLOT_Y2);
    text(row.getString("Country"), tx, ty);
  }

// Render chart title
  textFont(mainTitleF);
  text("UN Agency Expenditures \nby Country for 2015", PLOT_X1, PLOT_Y1+textAscent());


  // render the arcs
  strokeWeight(.15); 
  for (int i=0; i < agencyCountryTbl.getRowCount(); i++) {
    TableRow agencyCountryRow = agencyCountryTbl.getRow(i);
    int  currAmtVal= agencyCountryRow.getInt("Amount");

    int currAgencyOrd = agencyExpenditureTotalTbl.findRowIndex(agencyCountryRow.getString("Agency"), "Agency");
    agencyX = map(currAgencyOrd, 0, agencyExpenditureTotalTbl.getRowCount(), agencyAxis1.x, agencyAxis2.x);
    agencyY = agencyAxis1.y;

    int currCountryOrd = expenditureByCountryTbl.findRowIndex(agencyCountryRow.getString("Country"), "Country");
    // countryX = map(currCountryOrd, 0, expenditureByCountryTbl.getRowCount(), countryAxis2.x, countryAxis1.x);
    // countryY = countryAxis1.y;
    countryX = countryAxis1.x;
    countryY = map(currCountryOrd, 0, expenditureByCountryTbl.getRowCount(), countryAxis1.y, countryAxis2.y);

    fundingX = fundingAxis1.x;

    // fundingY = map(currAmtVal, fundingAxisMax, fundingAxisMin, fundingAxis1.y, fundingAxis2.y);
    fundingY = powMap(currAmtVal, Math.E, fundingAxisMax, fundingAxisMin, fundingAxis1.y, fundingAxis2.y);


    noFill();
    stroke(0, 150);
    // strokeWeight(1);
    beginShape();
    curveVertex(agencyX, agencyY+1000); // first control point
    curveVertex(agencyX, agencyY); // also the first data point
    curveVertex(fundingX, fundingY);
    curveVertex(countryX, countryY);
    curveVertex(countryX+1000, countryY-500); // ending control point
    endShape();
  }



  if (recording) saveFrame("MM_output/" + getSketchName() + "-#####.png");
}

void keyPressed() {
  if (key == 'S') screenCap(".jpg");
}

String generateSaveImgFileName(String fileType) {
  String fileName;
  // save functionality in here
  String outputDir = "out/";
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


// Exponential scale
// float powMap(incr, base, start1, stop1, start2, stop2) {
float powMap(int incr, double base, int start1, int stop1, float start2, float stop2) {
  // base should be an inverse (eg 1/2), start1/stop1 are the value range, start2/stop2 are the output range
  float normX = map(incr, start1, stop1, 0, 1);
  float newX = pow(normX, (float)base);
  return map(newX, 0, 1, start2, stop2);
}


void setPositioningVariables() {
  margin = width * pow(PHI, 6);
  println("margin: " + margin);
  PLOT_X1 = margin;
  PLOT_X2 = width-margin;
  PLOT_Y1 = margin;
  PLOT_Y2 = height-margin;
  PLOT_W = PLOT_X2 - PLOT_X1;
  PLOT_H = PLOT_Y2 - PLOT_Y1;
}
