public class Transaction {
  int year;
  String countryName;
  Country country;
  float amount;
  String unAgencyAbbrev;
  Agency agency;
  boolean hover; // mouse is hovering over 
  boolean highlight; // change display to be the highlight mode. 

  // Style Info
  // Normal, Faded, Highlight
  color transLineClr, transMarkerClr;
  float transStrokeWeight;
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

    // Set to normal vals
    transLineClr = color(0);
    transMarkerClr =color(0);
    transAlphaVal = powMap((int)amount, Math.E, transactionMax, transactionMin, 255, 47);
    transStrokeWeight = .33;

    hover = false;
    highlight = false;
  }

  void resetHoverHighlight() { // feels a little hacky but lets get it working first and see. 
    hover = false;
    highlight = false;
  }

  void checkHover() {
    if ( ( abs(amountLoc.x - mouseX) < 150) && (abs(amountLoc.y - mouseY) < 3)) { // change this hover area to be wider but short like 50px and 2px
      hover = true;
      highlight = true;
      univHover = true;
      // set related Agency and Country objects to highlight = true;
      country.highlight = true;
      agency.highlight = true;
    } else {
      hover = false;
    }
  }

  void updateStyle() {
    if (univHover) { // if true, then set this object to either highlighted or faded style
      if (hover || highlight) { // true, highlighted style
        transLineClr = unBlueClr;
        transMarkerClr = unBlueClr;
        transAlphaVal = 255;
        transStrokeWeight = 1;
      } else { // false, fade style
        transLineClr = color(0);
        transMarkerClr =color(0);
        transAlphaVal = 29;
        transStrokeWeight = .29;
      }
    } else { // false, default style
      transLineClr = color(0);
      transMarkerClr =color(0);
      transAlphaVal = powMap((int)amount, Math.E, transactionMax, transactionMin, 255, 47);
      transStrokeWeight = .33;
    }
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
  }

  void render() {
    noFill();
    stroke(transLineClr, transAlphaVal);
    strokeWeight(transStrokeWeight);
    curveTightness(.5);
    beginShape();
    curveVertex(agency.currLoc.x, agency.currLoc.y+750); // first control point
    curveVertex(agency.currLoc.x, agency.currLoc.y); // also the first data point
    curveVertex(amountLoc.x, amountLoc.y);
    curveVertex(country.currLoc.x, country.currLoc.y);
    curveVertex(country.currLoc.x+1000, country.currLoc.y-500); // ending control point
    endShape();

    if (hover) {
      fill(unBlueClr);
      // rect(amountLoc.x, amountLoc.y, 10, 10); // testing idea to show vertical $ range of mouseover
    }
  }

  void setTransactionCountry() {
    country = findCountryByName(countryName);
  }

  void setTransactionAgency() {
    agency = findAgencyByUnAbbrev(unAgencyAbbrev);
  }
}
