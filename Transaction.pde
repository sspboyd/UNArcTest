public class Transaction {
  int year;
  String countryName;
  Country country;
  float amount;
  String unAgencyAbbrev;
  Agency agency;

  PVector agencyLoc, amountLoc, countryLoc; // make getters/setters for these
  PVector agencyLocTarg, amountLocTarg, countryLocTarg; // make getters/setters for these


  public Transaction (int _year, String _cName, float _amt, String _unAgencyAbbrev) {
    year = _year;
    countryName = _cName;
    amount = _amt;
    unAgencyAbbrev = _unAgencyAbbrev;

    agencyLoc = new PVector();
    amountLoc = new PVector();
    countryLoc = new PVector();
    agencyLocTarg = new PVector();
    amountLocTarg = new PVector();
    countryLocTarg = new PVector();
  }

  void update() {
    agencyLoc = agency.currLoc;
    countryLoc = country.currLoc;
    // amountLoc = amount.currLoc; //
  }

  void render() {
    // agency.agencyLoc.x;
    // agency.agencyLoc.y;
    
    // funding
    
    // country.countryLoc.x;
    // country.countryLoc.y;

    //   int currAgencyOrd = agencyExpenditureTotalTbl.findRowIndex(agencyCountryRow.getString("Agency"), "Agency");
    //   agencyX = map(currAgencyOrd, 0, agencyExpenditureTotalTbl.getRowCount()-1, agencyAxis1.x, agencyAxis2.x);
    //   agencyY = agencyAxis1.y;

    //   int currCountryOrd = expenditureByCountryTbl.findRowIndex(agencyCountryRow.getString("Country"), "Country");
    //   countryX = countryAxis1.x;
    //   countryY = map(currCountryOrd, 0, expenditureByCountryTbl.getRowCount(), countryAxis1.y, countryAxis2.y);

    //   fundingX = fundingAxis1.x;

    //   if (fundingScaleLinLog) {
    //     fundingY = map(currAmtVal, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y); // change transactionMax to funding order of magnitude max.
    //   } else {
    //     fundingY = powMap(currAmtVal, fundingAxisLogBase, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y);
    //   }
    //   float fundingAlpha = powMap(currAmtVal, Math.E, transactionMax, transactionMin, 255, 47);

    //   noFill();
    //   stroke(transactionCurveClr, fundingAlpha);
    //   strokeWeight(.33);
    //   beginShape();
    //   curveVertex(agencyX, agencyY+750); // first control point
    //   curveVertex(agencyX, agencyY); // also the first data point
    //   curveVertex(fundingX, fundingY);
    //   curveVertex(countryX, countryY);
    //   curveVertex(countryX+1000, countryY-500); // ending control point
    //   endShape();
    //   fill(199, 199, 0);
    //   noStroke();
  }

  void setTransactionCountry(){
    country = findCountryByName(countryName);
  }
  
  void setTransactionAgency(){
    agency = findAgencyByUnAbbrev(unAgencyAbbrev);
  }
}
