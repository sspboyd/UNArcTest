// UN Funding by Agency and Country Arc Diagram Test

////Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;
boolean recording = false; // used for MovieMaker output

final int numberOfMemberStates = 211;
final int numberOfUNAgencies = 20;

Table agencyCountryTbl, expenditureByCountryTbl, agencyExpenditureTotalTbl;
int transactionMax, transactionMin;
int countryExpendMax, countryExpendMin;

//// Declare Font Variables
PFont mainTitleF, axesLabelF, titleF;


//Highlight colour (UN Blue)
color unBlueClr = color(91, 146, 229);
color transactionCurveClr = color(255);
color chartBkgClr = unBlueClr;
color axisClr = color(255,200);
color barChartClr = axisClr;

//// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;

PVector agencyAxis1, fundingAxis1, countryAxis1, agencyAxis2, fundingAxis2, countryAxis2;

boolean fundingScaleLinLog; // true=linear false=log
float fundingAxisLogBase;

/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  background(255);
  // PDF output
  // size(1080, 1080, PDF, generateSaveImgFileName(".pdf"));
  // Regular output
  // size(7020,4965); // 150 dpi for A0 size paper
  size(1920, 920); // 150 dpi for A0 size paper
  smooth(8);
  setPositioningVariables();
  rSn = 47; // 4,7,11,18,29...;
  randomSeed(rSn);

  agencyAxis1 = new PVector();
  agencyAxis2 = new PVector();

  fundingAxis1 = new PVector();
  fundingAxis2 = new PVector();
  fundingScaleLinLog = false; // true=linear false=log
  fundingAxisLogBase = 10;
  countryAxis1 = new PVector();
  countryAxis2 = new PVector();

  // load data
  agencyCountryTbl = loadTable("Agency_Expenditure_by_Country_2015.csv", "header");
  expenditureByCountryTbl = loadTable("Total_Expenditure_by_Country.csv", "header");
  agencyExpenditureTotalTbl = loadTable("Agency_Expenditure_Total_2015.csv", "header");

  // prep data
  // min / max for transactions (used on funding axis)
  transactionMin = Integer.MAX_VALUE;
  transactionMax = 0;
  for (int i=0; i < agencyCountryTbl.getRowCount(); i++) {
    TableRow agencyCountryRow = agencyCountryTbl.getRow(i);
    int  currAmtVal= agencyCountryRow.getInt("Amount");
    if ( currAmtVal > transactionMax) transactionMax = currAmtVal;
    if ( currAmtVal < transactionMin) transactionMin = currAmtVal; // this could be a negative value!
  }
  println("transactionMax = "+ transactionMax);

  // max/min spend by country
  countryExpendMax = 0;
  countryExpendMin = Integer.MAX_VALUE;

  for (int i = 0; i < expenditureByCountryTbl.getRowCount(); i++) {
    TableRow countryRow = expenditureByCountryTbl.getRow(i);
    int  currAmtVal= countryRow.getInt("Amount");
    if ( currAmtVal > countryExpendMax) countryExpendMax = currAmtVal;
    if ( currAmtVal < countryExpendMin) countryExpendMin = currAmtVal; // this could be a negative value!
  }

  // Font Stuff
  // titleF = loadFont("HelveticaNeue-Thin-72.vlw");
  mainTitleF = createFont("HelveticaNeue-Thin", 48, true);  //requires a font file in the data folder?
  axesLabelF = createFont("Helvetica", 11);  //requires a font file in the data folder?

  println("agencyCountryTbl row count = " + agencyCountryTbl.getRowCount());
  println("expenditureByCountryTbl row count = " + expenditureByCountryTbl.getRowCount());
  println("agencyExpenditureTotalTbl row count = " + agencyExpenditureTotalTbl.getRowCount());
  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}

/*////////////////////////////////////////
 DRAW
 ////////////////////////////////////////*/

void draw() {
  background(chartBkgClr);
  updateAxes();
  float agencyX, agencyY, fundingX, fundingY, countryX, countryY;

  // add country names
  int rowCounter=0;
  for (TableRow row : expenditureByCountryTbl.rows()) {
    float tx = countryAxis1.x + 18;
    float ty = map(rowCounter+=1, 0, expenditureByCountryTbl.getRowCount(), PLOT_Y1, PLOT_Y2);
    fill(unBlueClr, 100);
    text(row.getString("Country"), tx, ty);

    float barChartW = map(row.getFloat("Amount"), 0, countryExpendMax, 0, PLOT_X2-countryAxis1.x);

    fill(barChartClr);
    noStroke();
    rect(tx, ty, barChartW, 5);
  }

  // Render chart title
  textFont(mainTitleF);
  // textFont(titleF, 144);

  fill(unBlueClr, 147);
  text("UN Agency Expenditures \nby Country \nin 2015", PLOT_X1, PLOT_Y1+textAscent());

  // render the arcs
  strokeWeight(.25); 
  for (int i=0; i < agencyCountryTbl.getRowCount(); i++) {
    TableRow agencyCountryRow = agencyCountryTbl.getRow(i);
    int  currAmtVal= agencyCountryRow.getInt("Amount");
    if(currAmtVal>0){
    int currAgencyOrd = agencyExpenditureTotalTbl.findRowIndex(agencyCountryRow.getString("Agency"), "Agency");
    agencyX = map(currAgencyOrd, 0, agencyExpenditureTotalTbl.getRowCount()-1, agencyAxis1.x, agencyAxis2.x);
    agencyY = agencyAxis1.y;

    int currCountryOrd = expenditureByCountryTbl.findRowIndex(agencyCountryRow.getString("Country"), "Country");
    // countryX = map(currCountryOrd, 0, expenditureByCountryTbl.getRowCount(), countryAxis2.x, countryAxis1.x);
    // countryY = countryAxis1.y;
    countryX = countryAxis1.x;
    countryY = map(currCountryOrd, 0, expenditureByCountryTbl.getRowCount(), countryAxis1.y, countryAxis2.y);

    fundingX = fundingAxis1.x;

    if (fundingScaleLinLog) {
      fundingY = map(currAmtVal, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y);
    }else{
      fundingY = powMap(currAmtVal, fundingAxisLogBase, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y);
    }
    float fundingAlpha = powMap(currAmtVal, Math.E, transactionMax, transactionMin, 255, 47);

    noFill();
    // fill(199,199,0,11);
    stroke(transactionCurveClr, fundingAlpha);
    strokeWeight(.33);
    beginShape();
    curveVertex(agencyX, agencyY+750); // first control point
    curveVertex(agencyX, agencyY); // also the first data point
    curveVertex(fundingX, fundingY);
    curveVertex(countryX, countryY);
    curveVertex(countryX+1000, countryY-500); // ending control point
    endShape();
    // stroke(1);
    fill(199, 199, 0);
    noStroke();
    // ellipse(fundingX-1, fundingY-1, 2, 2);
    }
  }


  renderAxes();
renderFundingAxisScaleMarkers();
  if (recording) saveFrame("MM_output/" + getSketchName() + "-#####.png");
}

void updateAxes() {

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
  countryAxis2.x = countryAxis1.x;
  countryAxis2.y = PLOT_Y2;
}
void renderAxes() {
  // render the axes
  stroke(axisClr);
  strokeWeight(1);
  line(agencyAxis1.x, agencyAxis1.y, agencyAxis2.x, agencyAxis2.y);
  line(countryAxis1.x, countryAxis1.y, countryAxis2.x, countryAxis2.y);
  line(fundingAxis1.x, fundingAxis1.y, fundingAxis2.x, fundingAxis2.y);

  // label axes
  fill(unBlueClr);
  noStroke();
  textFont(axesLabelF);
  // text("Countries", countryAxis1.x, countryAxis1.y + textAscent() + 5);
  text("UN Agencies", agencyAxis1.x, agencyAxis1.y + textAscent() + 5);
  pushMatrix();
  translate(fundingAxis1.x+(textAscent()*2), fundingAxis1.y + ((fundingAxis2.y - fundingAxis1.y) * PHI));
  rotate(-HALF_PI);
  text("Funding", 0, 0);
  popMatrix();
  
}

void keyPressed() {
  if (key == 'S') screenCap(".jpg");
  if (key == 'L') fundingScaleLinLog = true;
  if (key == 'l') fundingScaleLinLog = false;

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




void renderFundingAxisScaleMarkers() {
  float maxTickVal = getHigherOrderOfMag(transactionMax);
  // 0, 10, 100, 1,000, 10,000, 100,000, 1,000,000, 10,000,000, 100,000,000, 1,000,000,000

  // set the font and colour for the ticks and text
  stroke(100, 100, 255);
  float fundingScaleTickVal = maxTickVal;

  float tickX, tickY;
  tickX = fundingAxis1.x;
  tickY = 0;

  float numTicks = floor(log(maxTickVal)/log(10));
  // println("numTicks: " + numTicks);
  // println("maxTickVal: " + maxTickVal);
  for (int i = (int)numTicks; i > 1; i--) {
  
float currTickVal = pow(10, i);
    if (fundingScaleLinLog) {
      // Linear scale please!
      tickY = map(currTickVal, (int)maxTickVal, transactionMin, fundingAxis1.y, fundingAxis2.y);

    } else {
      // Log scale pfv
      tickY = powMap((int)currTickVal, fundingAxisLogBase, (int)maxTickVal, transactionMin, fundingAxis1.y, fundingAxis2.y);
      // tickY = powMap((int)currTickVal, Math.E, (int)maxTickVal, transactionMin, fundingAxis1.y, fundingAxis2.y);
    }
    // place tick 
    line(tickX, tickY, tickX-10, tickY);
    // place text
    // textFont();
    text((int)currTickVal, tickX-200, tickY);

    // fundingScaleTickVal = fundingScaleTickVal-1;
    // println("fundingScaleTickVal = " + fundingScaleTickVal);
    // fundingScaleTickVal = getLowerOrderOfMag(fundingScaleTickVal);
  }
}


float getHigherOrderOfMag(float _n){
  float n = _n;
  float roundUpLogTen = ceil(log(n)/log(10));
  float higher = pow(10, roundUpLogTen);
  // println(n + " becomes " + higher);
  return higher;
}

float getLowerOrderOfMag(float _n){
  float n = _n;
  float roundLogTen = floor(log(n)/log(10));
  float lower = pow(10, roundLogTen);
  // println(n + " becomes " + lower);
  return lower;
}