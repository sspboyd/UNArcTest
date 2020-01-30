import java.util.Map; // for DataCard Hashmaps
import processing.pdf.*;
boolean pdfRecord = false;

// UN Funding by Agency and Country Arc Diagram Test

////Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;
boolean recording = false; // used for MovieMaker output

final int numberOfMemberStates = 211;
final int numberOfUNAgencies = 20;

Table agencyCountryTbl, expenditureByCountryTbl, agencyExpenditureTotalTbl;
Table unAbbrevTbl2;


int transactionMax, transactionMin;
int countryExpendMax, countryExpendMin;

//// Declare Font Variables
PFont mainTitleF, axesLabelF, titleF, agHoverLabelF, cntryHoverLabelF;


//Highlight colour (UN Blue)
color unBlueClr = color(91, 146, 229);
color transactionCurveClr = color(0);
color chartBkgClr = 255;
color axisClr = transactionCurveClr;
color barChartClr = transactionCurveClr;
// color countryLabelClr = unBlueClr;

boolean univHover = false;

//// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;

PVector agencyAxis1, fundingAxis1, countryAxis1, agencyAxis2, fundingAxis2, countryAxis2;

boolean fundingScaleLinLog; // true=linear false=log
float fundingAxisLogBase;

ArrayList<Country> countries;
ArrayList<Transaction> transactions;
ArrayList<Agency> agencies;


//// Declare Globals for Data Cards
// AgCard agCard1;
HashMap<String, AgencyCard> agencyCards;


// public void settings() {
//   if (pdfRecord) {
//     size(6000, 4800, "processing.pdf.PGraphicsPDF", generateSaveImgFileName(".pdf")); // sized for 8x10 @ 600dpi
//   }else{
//     size(1920, 1030, "processing.opengl.PGraphics2D");
//     smooth(8);
//   }
// }

/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 SETUP
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

void setup() {
  background(255);
  // PDF output
  // size(6000, 4800, PDF, generateSaveImgFileName(".pdf")); // only works with the Processing PDE
  // Regular output
  // size(7020,4965); // 150 dpi for A0 size paper
  // size(2048, 1536); // iPad Air 2;
  // size(1920, 1030, P2D); // office display size
  size(1440, 850, P2D); // curent macbook pro size at half scaling?
  // size(1600, 900);
  // size(1300, 850);
  // size(720, 650);
  smooth(8);
  setPositioningVariables();
  rSn = 47; // 4,7,11,18,29...;
  randomSeed(rSn);

  // load data
  agencyCountryTbl = loadTable("Agency_Expenditure_by_Country_2015.csv", "header");
  expenditureByCountryTbl = loadTable("Total_Expenditure_by_Country.csv", "header");
  agencyExpenditureTotalTbl = loadTable("Agency_Expenditure_Total_2015.csv", "header");
  unAbbrevTbl2 = loadTable("UN-Agencies-Metadata.csv", "header");

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

  // Prep Data Card Hashmaps
  agencyCards = new HashMap<String, AgencyCard>();

  // Populate ArrayLists
  //Transactions ArrayLists
  for (int i=0; i < agencyCountryTbl.getRowCount(); i++) {
    TableRow agencyCountryRow = agencyCountryTbl.getRow(i);
    int     currYear= agencyCountryRow.getInt("Year");
    String  currCountryName= agencyCountryRow.getString("Country");
    float   currAmount= agencyCountryRow.getFloat("Amount");
    String  currAgency= agencyCountryRow.getString("Agency");
    Transaction newTransaction = new Transaction(currYear, currCountryName, currAmount, currAgency);
    transactions.add(newTransaction);
  }

  // Countries ArrayList
  for (int i=0; i < expenditureByCountryTbl.getRowCount(); i++) {
    TableRow countryRow = expenditureByCountryTbl.getRow(i);
    int     currYear= countryRow.getInt("Year");
    String  currCountryName= countryRow.getString("Country");
    float   currAmount= countryRow.getFloat("Amount");
    Country newCountry = new Country(currYear, currCountryName, currAmount);
    countries.add(newCountry);
  }

  // Agencies ArrayList
  for (int i=0; i < agencyExpenditureTotalTbl.getRowCount(); i++) {
    TableRow agencyRow = agencyExpenditureTotalTbl.getRow(i);
    int     currYear = 2015; // hard coding year val....
    String  currAgencyUNAbbrev= agencyRow.getString("Agency");
    // String currExpenditure = agencyRow.getString("Expenditure");
    println("currAgencyUNAbbrev : " + currAgencyUNAbbrev);
    TableRow result = unAbbrevTbl2.findRow(currAgencyUNAbbrev, "Abbreviation");
    println("result: " + result);
    String currAgencyName = "";
    if (result != null) {
      currAgencyName = result.getString("Official name");
    }
    float   currAmount= agencyRow.getFloat("Expenditure");
    Agency newAgency = new Agency(currYear, currAgencyUNAbbrev, currAgencyName, currAmount);
    agencies.add(newAgency);
  }

  // Set references between Country, Agency and Transaction objects
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


  // Initialize Axes
  agencyAxis1 = new PVector();
  agencyAxis2 = new PVector();
  fundingAxis1 = new PVector();
  fundingAxis2 = new PVector();
  fundingScaleLinLog = false; // true=linear false=log
  fundingAxisLogBase = 10;
  countryAxis1 = new PVector();
  countryAxis2 = new PVector();
  // updateAxes();


  // Creating AgencyCards and HashMap to name
  for (Agency currAg : agencies) {
    AgencyCard newAgCard = new AgencyCard(currAg);
    agencyCards.put(currAg.agencyName, newAgCard);
  }


  // Font Stuff
  // titleF = loadFont("HelveticaNeue-Thin-72.vlw");
  mainTitleF = createFont("HelveticaNeue-Thin", 48, true);  //requires a font file in the data folder?
  axesLabelF = createFont("Helvetica", 11);  //requires a font file in the data folder?
  agHoverLabelF = createFont("Helvetica", 18);  //requires a font file in the data folder?
  cntryHoverLabelF = createFont("HelveticaNeue-Thin", 36, true);  //requires a font file in the data folder?

  // Run tests
  // test_CountryObj("Lebanon");
  // test_AgencyObj("UNICEF");
  // test_AgencyNullObj();

  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}

/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 DRAW
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

void draw() {
  if (pdfRecord) {
    beginRecord(PDF, generateSaveImgFileName(".pdf"));
  }

  background(chartBkgClr);
  updateAxes();

  // renderBarChart();

  // Reset hover and highlight values to off
  univHover = false;
  for (Agency ag : agencies) {
    ag.resetHoverHighlight();
  }

  for (Country cty : countries) {
    cty.resetHoverHighlight();
  }

  for (Transaction t : transactions) {
    t.resetHoverHighlight();
  }


  // check to see if the mouse is hovering over Agencies
  if ((mouseX > (agencyAxis1.x - 50)) && (mouseX < (agencyAxis2.x + 50)) && (mouseY > (agencyAxis1.y-175))) {
    Agency nearestAg = nearestAgency(agencies);
    nearestAg.setHover();
  }

  if ( (countryAxis1.x-200 < mouseX) && (mouseX < PLOT_X2) && (mouseY > countryAxis1.y-textAscent()*3) && mouseY < countryAxis2.y + textAscent()*3 ) {
    Country nearestCty = nearestCountry(countries);
    nearestCty.setHover();
  }

  for (Transaction t : transactions) {
    t.checkHover();
  }

  // Render the objects
  for (Agency ag : agencies) {
    ag.updateStyle();
    ag.update();
    ag.render();
  }

  for (Country cty : countries) {
    cty.updateStyle();
    cty.update();
    cty.render();
  }

  for (Transaction t : transactions) {
    t.updateStyle();
    t.update();
    t.render();
  }

  for (AgencyCard currAc : agencyCards.values()) {
    currAc.render();
  }

  // Render chart title
  textFont(mainTitleF);
  // textFont(titleF, 144);
  fill(unBlueClr);
  textAlign(LEFT);
  text("$23 Billion USD\nUN Agency Expenditures \nin 2015", PLOT_X1, PLOT_Y1+textAscent()*PHI);

  renderAxes();
  renderFundingAxisScaleMarkers();
  // renderBarChart(); 

  if (recording) saveFrame("MM_output/" + getSketchName() + "-#####.png");

  if (pdfRecord) {
    endRecord();
    pdfRecord = false;
  }
}

// DRAW Loop Ends ///////////////////////////////////////////////////////////////////////////////////


Agency nearestAgency(ArrayList<Agency> _agencies) {
  // check if mouse location is within 'hover' range of the agency axis
  Agency closestAgency = new Agency(); // create a new placeholder agency object.
  float currMinDist = Float.MAX_VALUE; // set initally to max possible value for floats
  for (Agency currAg : _agencies) {
    float currAgDist = dist(mouseX, mouseY, currAg.currLoc.x, currAg.currLoc.y);
    if (currAgDist < currMinDist) { 
      currMinDist = currAgDist;
      closestAgency = currAg;
    }
  }
  return closestAgency;
}

Country nearestCountry(ArrayList<Country> _countries) {
  // check if mouse location is within 'hover' range of the agency axis
  Country closestCty = new Country(); // create a new placeholder agency object.
  float currMinDist = Float.MAX_VALUE; // set initally to max possible value for floats
  for (Country currCty : _countries) {
    float currCtyDist = dist(mouseX, mouseY, currCty.currLoc.x, currCty.currLoc.y);
    if (currCtyDist < currMinDist) { 
      currMinDist = currCtyDist;
      closestCty = currCty;
    }
  }
  return closestCty;
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
  // text("UN Agencies", agencyAxis1.x, agencyAxis1.y + textAscent() + 5);
  pushMatrix();
  translate(fundingAxis1.x+(textAscent()*2), fundingAxis1.y + ((fundingAxis2.y - fundingAxis1.y) * PHI));
  rotate(-HALF_PI);
  text("Funding", 0, 0);
  popMatrix();
}


/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 KEYBOARD UI
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
void keyPressed() {
  if (key == 'S') screenCap(".jpg");
  if (key == 'P') pdfRecord = true;
  if (key == 'L') fundingScaleLinLog = true;
  if (key == 'l') fundingScaleLinLog = false;
  if (key == 'e') {
    exit();
  }
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
  for (int i = (int)numTicks; i > 5; i--) {

    float currTickVal = pow(10, i);
    if (fundingScaleLinLog) {
      // Linear scale please!
      tickY = map(currTickVal, (int)maxTickVal, transactionMin, fundingAxis1.y, fundingAxis2.y);
    } else {
      // Log scale pfv
      tickY = powMap((int)currTickVal, fundingAxisLogBase, (int)maxTickVal, transactionMin, fundingAxis1.y, fundingAxis2.y);
    }

    // tickX = map(i, numTicks, 0, PLOT_X1, fundingAxis1.x-0);
    tickX = fundingAxis1.x-200;
    // place tick 
    stroke(unBlueClr, 123);
    // line(tickX, tickY, tickX-10, tickY);
    line(tickX, tickY, fundingAxis1.x, tickY);
    // place text
    fill(transactionCurveClr);
    textAlign(LEFT);
    text("$"+nfc((int)currTickVal, 0), tickX, tickY+textAscent()+5);
  }
  // mark the bottom of the funding axis with a $0 tick
  text("$0", fundingAxis1.x - textWidth("$0 "), fundingAxis2.y+textAscent()+5);
  line(fundingAxis1.x-10, fundingAxis2.y, fundingAxis1.x, fundingAxis2.y);
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


void renderBarChart() {
  int rowCounter=0;
  for (TableRow row : expenditureByCountryTbl.rows()) {
    float tx = countryAxis1.x + 18;
    float ty = map(rowCounter+=1, 0, expenditureByCountryTbl.getRowCount(), PLOT_Y1, PLOT_Y2);
    float barChartW = map(row.getFloat("Amount"), 0, countryExpendMax, 0, PLOT_X2-countryAxis1.x);
    fill(unBlueClr, 76);
    noStroke();
    rect(tx, ty, barChartW, 2);
  }
}


/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ARRAYLIST UTILITIES
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

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

ArrayList<Country> countryListByAgency(String agencyAbbrev, String countryName) {
  ArrayList<Country> countryList = new ArrayList<Country>();
  for (Transaction t : transactions) {
    if (t.unAgencyAbbrev.equals(agencyAbbrev) && (t.countryName.equals(countryName))) {
      countryList.add(t.country);
    }
  }
  return countryList;
}



/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 Tests
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

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

void test_AgencyNullObj() {
  Agency nullAg = new Agency();
  println(nullAg);
  println(nullAg.agencyName);
}
