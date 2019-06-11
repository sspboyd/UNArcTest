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
color transactionCurveClr = color(0);
color chartBkgClr = 255;
color axisClr = transactionCurveClr;
color barChartClr = transactionCurveClr;
color countryLabelClr = unBlueClr;

//// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;

PVector agencyAxis1, fundingAxis1, countryAxis1, agencyAxis2, fundingAxis2, countryAxis2;

boolean fundingScaleLinLog; // true=linear false=log
float fundingAxisLogBase;

ArrayList<Country> countries;
ArrayList<Transaction> transactions;
ArrayList<Agency> agencies;


/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 SETUP
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

void setup() {
  background(255);
  // PDF output
  // size(1080, 1080, PDF, generateSaveImgFileName(".pdf"));
  // Regular output
  // size(7020,4965); // 150 dpi for A0 size paper
  size(1280, 720); // 150 dpi for A0 size paper
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

  // Prep ArrayList
  countries = new ArrayList<Country>();
  transactions = new ArrayList<Transaction>();
  agencies = new ArrayList<Agency>();

  // Populate ArrayLists
  for (int i=0; i < agencyCountryTbl.getRowCount(); i++) {
    TableRow agencyCountryRow = agencyCountryTbl.getRow(i);
    int     currYear= agencyCountryRow.getInt("Year");
    String  currCountryName= agencyCountryRow.getString("Country");
    float   currAmount= agencyCountryRow.getFloat("Amount");
    String  currAgency= agencyCountryRow.getString("Agency");
    Transaction newTransaction = new Transaction(currYear, currCountryName, currAmount, currAgency);
    transactions.add(newTransaction);
  }

  for (int i=0; i < expenditureByCountryTbl.getRowCount(); i++) {
    TableRow countryRow = expenditureByCountryTbl.getRow(i);
    int     currYear= countryRow.getInt("Year");
    String  currCountryName= countryRow.getString("Country");
    float   currAmount= countryRow.getFloat("Amount");
    Country newCountry = new Country(currYear, currCountryName, currAmount);
    countries.add(newCountry);
  }

  for (int i=0; i < agencyExpenditureTotalTbl.getRowCount(); i++) {
    TableRow agencyRow = agencyExpenditureTotalTbl.getRow(i);
    int     currYear = 2015; // hard coding year val....
    String  currAgencyUNAbbrev= agencyRow.getString("Agency");
    float   currAmount= agencyRow.getFloat("Expenditure");
    Agency newAgency = new Agency(currYear, currAgencyUNAbbrev, currAmount);
    agencies.add(newAgency);
  }

  // Set references between objects
  println("setting transaction references");
  for (Transaction currTrans : transactions) {
    currTrans.setTransactionCountry();
    currTrans.setTransactionAgency();
  }

  println("setting agency references");
  for (Agency currAgency : agencies) {
    currAgency.setAgencyTransactionList();
  }

  println("setting country references");
  for (Country currCnty : countries) {
    currCnty.setCountryTransactionList();
  }
  // Font Stuff
  // titleF = loadFont("HelveticaNeue-Thin-72.vlw");
  mainTitleF = createFont("HelveticaNeue-Thin", 48, true);  //requires a font file in the data folder?
  axesLabelF = createFont("Helvetica", 11);  //requires a font file in the data folder?

  test_CountryObj("Lebanon");
  test_AgencyObj("UNICEF");

  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}

/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 DRAW
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

void draw() {
  background(chartBkgClr);
  updateAxes();
  float agencyX, agencyY, fundingX, fundingY, countryX, countryY;

  // add country names
  int rowCounter=0;
  for (TableRow row : expenditureByCountryTbl.rows()) {
    float tx = countryAxis1.x + 18;
    float ty = map(rowCounter+=1, 0, expenditureByCountryTbl.getRowCount(), PLOT_Y1, PLOT_Y2);
    fill(countryLabelClr);
    text(row.getString("Country"), tx, ty);

    float barChartW = map(row.getFloat("Amount"), 0, countryExpendMax, 0, PLOT_X2-countryAxis1.x);

    fill(barChartClr, 123);
    noStroke();
    rect(tx, ty, barChartW, 2);
  }

  // add agency names
  rowCounter=0;
  for (TableRow row : agencyExpenditureTotalTbl.rows()) {
    float tx = map(rowCounter+=1, 0, agencyExpenditureTotalTbl.getRowCount(), agencyAxis1.x, agencyAxis2.x);
    float ty = agencyAxis1.y+20;
    pushMatrix();
    translate(tx, ty);
    rotate(HALF_PI/2);
    fill(unBlueClr, 199);
    text(row.getString("Agency"), 0, 0);
    popMatrix();
  }

  // Render chart title
  textFont(mainTitleF);
  // textFont(titleF, 144);

  fill(unBlueClr, 147);
  text("UN Agency Expenditures \nby Country \nin 2015", PLOT_X1, PLOT_Y1+textAscent());

  // render the arcs
  // for (Transaction currTrans : transactions) {
  //   if(currTrans.amount > 0){
  //     currTrans.render();
  //   }
  // } 

  strokeWeight(.25); 
  for (int i=0; i < agencyCountryTbl.getRowCount(); i++) {
    TableRow agencyCountryRow = agencyCountryTbl.getRow(i);
    int  currAmtVal= agencyCountryRow.getInt("Amount");
    if (currAmtVal>0) {
      int currAgencyOrd = agencyExpenditureTotalTbl.findRowIndex(agencyCountryRow.getString("Agency"), "Agency");
      agencyX = map(currAgencyOrd, 0, agencyExpenditureTotalTbl.getRowCount()-1, agencyAxis1.x, agencyAxis2.x);
      agencyY = agencyAxis1.y;

      int currCountryOrd = expenditureByCountryTbl.findRowIndex(agencyCountryRow.getString("Country"), "Country");
      countryX = countryAxis1.x;
      countryY = map(currCountryOrd, 0, expenditureByCountryTbl.getRowCount(), countryAxis1.y, countryAxis2.y);

      fundingX = fundingAxis1.x;

      if (fundingScaleLinLog) {
        fundingY = map(currAmtVal, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y); // change transactionMax to funding order of magnitude max.
      } else {
        fundingY = powMap(currAmtVal, fundingAxisLogBase, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y);
      }
      float fundingAlpha = powMap(currAmtVal, Math.E, transactionMax, transactionMin, 255, 47);

      noFill();
      stroke(transactionCurveClr, fundingAlpha);
      strokeWeight(.33);
      beginShape();
      curveVertex(agencyX, agencyY+750); // first control point
      curveVertex(agencyX, agencyY); // also the first data point
      curveVertex(fundingX, fundingY);
      curveVertex(countryX, countryY);
      curveVertex(countryX+1000, countryY-500); // ending control point
      endShape();
      fill(199, 199, 0);
      noStroke();
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
float powMap(int incr, double base, int start1, int stop1, float start2, float stop2) {
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
    }
    // place tick 
    stroke(transactionCurveClr);
    line(tickX, tickY, tickX-10, tickY);
    // place text
    fill(transactionCurveClr);
    text((int)currTickVal, tickX-200, tickY);
  }
}


float getHigherOrderOfMag(float _n) {
  float n = _n;
  float roundUpLogTen = ceil(log(n)/log(10));
  float higher = pow(10, roundUpLogTen);
  // println(n + " becomes " + higher);
  return higher;
}

float getLowerOrderOfMag(float _n) {
  float n = _n;
  float roundLogTen = floor(log(n)/log(10));
  float lower = pow(10, roundLogTen);
  // println(n + " becomes " + lower);
  return lower;
}


//// some utility functions for managing objects in arraylists
Country findCountryByName(String _cName) {
  String cName = _cName;

  for (Country country : countries) {
    if (country.countryName.equals(cName)) {
      return country;
    }
  }
  return null;
}

Agency findAgencyByUnAbbrev(String _unAbbrev) { 
  String unAbbrev = _unAbbrev;
  //   println("in findAgencyByUnAbbrev()\nagencies.size(): "+agencies.size());
  for (Agency agency : agencies) {
    if (agency.unAgencyAbbrev.equals(unAbbrev)) {
      return agency;
    }
  }
  return null;
}

ArrayList<Transaction> transactionCollectionByCountry(String countryName) {    
  ArrayList<Transaction> transactionCollection = new ArrayList<Transaction>();
  for (Transaction currTransaction : transactions) {
    if (currTransaction.countryName.equals(countryName)) {
      transactionCollection.add(currTransaction);
    }
  }
  return transactionCollection;
}

ArrayList<Transaction> transactionCollectionByAgency(String agencyAbbrev) {    
  ArrayList<Transaction> tColl = new ArrayList<Transaction>();
  for (Transaction t : transactions) {
    if (t.unAgencyAbbrev.equals(agencyAbbrev)) {
      tColl.add(t);
    }
  }
  return tColl;
}


void test_CountryObj(String _cName) {
  String cName = _cName;
  Country currCountry = findCountryByName(cName);

  String output = "------- ---- ---";
  output += "\n"+currCountry;
  output += "\nCountry name: " + currCountry.countryName;
  output += "\nyear: " + currCountry.year;
  output += "\namount: " + currCountry.amount;

  // print out country name, year, amount and
  // every transaction showing agency and amount
  output += "\n";
  output += "\nAll transactions for " + currCountry.countryName;

  for (Transaction currTrans : currCountry.countryTransactions) {
    output += "\n"+currTrans.unAgencyAbbrev + ": " + currTrans.amount;
  }
  println(output);
}

void test_AgencyObj(String _ag) {
  String ag = _ag;
  Agency currAg = findAgencyByUnAbbrev(ag);

  String output = "------- ---- ---";
  output += "\n"+currAg;
  output += "\nAgency name: " + currAg.unAgencyAbbrev;
  output += "\nyear: " + currAg.year;
  output += "\namount: " + currAg.expenditure;

  for (Transaction t : currAg.agencyTransactions) {
    output += "\n"+t.countryName + ": " + t.amount;
  }
  println(output);
}
