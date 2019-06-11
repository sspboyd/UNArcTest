public class Transaction {
  int year;
  String countryName;
  Country country;
  float amount;
  String unAgencyAbbrev;
  Agency agency;
  color transLineClr, transMarkerClr;
  float transAlphaVal;

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

    transLineClr = color(0);
    transMarkerClr =color(0);
    transAlphaVal = 255;
  }

  void update() {
    // agencyLoc = agency.currLoc; // don't think I need these, just reference the object directly
    // countryLoc = country.currLoc;

    amountLoc.x = fundingAxis1.x;

    if (fundingScaleLinLog) {
      amountLoc.y = map(amount, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y); // change transactionMax to funding order of magnitude max.
    } else {
      amountLoc.y = powMap((int)amount, fundingAxisLogBase, transactionMax, transactionMin, fundingAxis1.y, fundingAxis2.y);
    }
    transAlphaVal = powMap((int)amount, Math.E, transactionMax, transactionMin, 255, 47);
  }

  void render() {
    noFill();
    stroke(transLineClr, transAlphaVal);
    strokeWeight(.33);
    beginShape();
    curveVertex(agency.currLoc.x, agency.currLoc.y+750); // first control point
    curveVertex(agency.currLoc.x, agency.currLoc.y); // also the first data point
    curveVertex(amountLoc.x, amountLoc.y);
    curveVertex(country.currLoc.x, country.currLoc.y);
    curveVertex(country.currLoc.x+1000, country.currLoc.y-500); // ending control point
    endShape();
  }

  void setTransactionCountry() {
    country = findCountryByName(countryName);
  }

  void setTransactionAgency() {
    agency = findAgencyByUnAbbrev(unAgencyAbbrev);
  }
}
