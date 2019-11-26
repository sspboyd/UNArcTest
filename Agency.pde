public class Agency {
  // public class Agency extends UN {
  String unAgencyAbbrev;
  String agencyName;
  int year;
  float expenditure;
  ArrayList<Transaction> agencyTransactions; // List of all the agency transactions
  ArrayList<Country> agencyCountries; // countries the agency is active in
  PVector currLoc, targLoc; // getter/setter?
  color agMarkerClr, agTextClr;
  float agAlpha;
  boolean hover, highlight;


  public Agency (int _year, String _unAgencyAbbrev, float _expenditure) {
    year = _year;
    unAgencyAbbrev = _unAgencyAbbrev;
    expenditure = _expenditure;
    currLoc = new PVector();
    targLoc = new PVector();
    agMarkerClr = color(0);
    agTextClr = color(0);
    hover = false;
    highlight = false;
    agAlpha = 255;
  }

  void resetHoverHighlight() {
    hover = false;
    highlight = false;
  }

  void checkHover() {
    if ((abs(mouseX-currLoc.x)<16) && (mouseY > currLoc.y) && (mouseY < height)) {
      // if (currLoc.dist(new PVector(mouseX, mouseY)) < 18) {
      hover = true;
      univHover = true;
      // set related Agency and Country objects to highlight = true;
      for (Transaction agTran : agencyTransactions) {
        agTran.highlight = true;
        agTran.country.highlight = true;
      }
    } else {
      hover = false;
    }
  }

  void updateStyle() {
    if (hover) {
      textFont(agHoverLabelF);
    } else {
      textFont(axesLabelF);
    }
    if (univHover) { // if true, then set this object to either highlighted or faded style
      if (hover || highlight) { // true, highlighted style
        agTextClr = unBlueClr;
        agMarkerClr = unBlueClr;
      } else { // false, fade style
        agAlpha = 76;
        agTextClr = color(0, agAlpha);
        agMarkerClr = color(0, agAlpha);
      }
    } else { // false, default style
      agTextClr = color(0);
      agMarkerClr = color(0);
    }
  }

  void update() {
    // update the position
    // get the ordinal rank of this agency from the table
    int agencyRank = agencyExpenditureTotalTbl.findRowIndex(unAgencyAbbrev, "Agency");
    currLoc.x = map(agencyRank, 0, agencyExpenditureTotalTbl.getRowCount()-1, agencyAxis1.x, agencyAxis2.x);
    currLoc.y = agencyAxis1.y;
  }

  void render() {
    float textX = currLoc.x;
    float textY = currLoc.y+20;
    pushMatrix();
    translate(textX, textY);
    rotate(HALF_PI/2);
    fill(agTextClr);
    text(unAgencyAbbrev, 0, 0);
    popMatrix();
  }

  void setAgencyTransactionList() {
    agencyTransactions = transactionCollectionByAgency(unAgencyAbbrev);
  }
}
