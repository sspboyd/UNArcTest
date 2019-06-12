public class Agency {
  // public class Agency extends UN {
  String unAgencyAbbrev;
  String agencyName;
  int year;
  float expenditure;
  ArrayList<Transaction> agencyTransactions;
  PVector currLoc, targLoc; // getter/setter?
  color agMarkerClr, agTextClr;
  boolean hover;



  public Agency (int _year, String _unAgencyAbbrev, float _expenditure) {
    year = _year;
    unAgencyAbbrev = _unAgencyAbbrev;
    expenditure = _expenditure;
    currLoc = new PVector();
    targLoc = new PVector();
    agMarkerClr = color(0);
    agTextClr = color(0);
    hover = false;
  }

  void checkHover() {
    if (currLoc.dist(new PVector(mouseX, mouseY)) < 10) {
      hover = true;
      univHover = true;
    } else {
      hover = false;
    }
  }

  void updateStyle() {
    if (univHover) { // if true, then set this object to either highlighted or faded style
      if (hover) { // true, highlighted style
      } else { // false, fade style
      }
    } else { // false, default style
    }
  }

  void update() {
    // update the position
    // get the ordinal rank of this agency from the table
    int agencyRank = agencyExpenditureTotalTbl.findRowIndex(unAgencyAbbrev, "Agency");
    currLoc.x = map(agencyRank, 0, agencyExpenditureTotalTbl.getRowCount()-1, agencyAxis1.x, agencyAxis2.x);
    currLoc.y = agencyAxis1.y;

    if (currLoc.dist(new PVector(mouseX, mouseY)) < 10) {
      // hover = true;
      agTextClr = unBlueClr;
      agMarkerClr = unBlueClr;
    } else {
      agTextClr = color(0);
      agMarkerClr = color(0);
    }
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
