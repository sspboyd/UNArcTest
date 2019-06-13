public class Country {
  String countryName;
  int year;
  float amount;
  PVector currLoc, targLoc; // getter/setter?
  ArrayList<Transaction> countryTransactions = new ArrayList<Transaction>();
  color ctyMarkerClr, ctyTextClr;
  boolean hover, highlight;


  public Country (int _yr, String _countryName, float _amt) {
    countryName = _countryName;
    year = _yr;
    amount = _amt;

    currLoc = new PVector();
    targLoc = new PVector();

    ctyMarkerClr = unBlueClr;
    ctyTextClr = unBlueClr;

    hover = false;
    highlight = false;
  }

  void resetHoverHighlight() {
    hover = false;
    highlight = false;
  }

  void checkHover() {
    if (currLoc.dist(new PVector(mouseX, mouseY)) < 4) {
      hover = true;
      univHover = true;
      // set related Agency and Country objects to highlight = true;
      for (Transaction ctyTran : countryTransactions) {
        ctyTran.highlight = true;
        ctyTran.agency.highlight = true;
      }
    } else {
      hover = false;
    }
  }

  void updateStyle() {
    if (univHover) { // if true, then set this object to either highlighted or faded style
      if (hover || highlight) { // true, highlighted style
        ctyMarkerClr=unBlueClr;
        ctyTextClr=unBlueClr;
      } else { // false, fade style
        ctyMarkerClr=color(0, 76);
        ctyTextClr=color(0, 76);
      }
    } else { // false, default style
      ctyMarkerClr=color(0);
      ctyTextClr=color(0);
    }
  }

  void update() {
    // update the position
    // get the ordinal rank of this agency from the table
    int ctyRank = expenditureByCountryTbl.findRowIndex(countryName, "Country");
    currLoc.x = countryAxis1.x;
    currLoc.y = map(ctyRank, 0, expenditureByCountryTbl.getRowCount()-1, countryAxis1.y, countryAxis2.y);
  }

  void render() {
    // render country name
    float textX = currLoc.x + 18;
    float textY = currLoc.y;
    fill(ctyTextClr);
    text(countryName, textX, textY);
  }

  void setCountryTransactionList() {
    countryTransactions = transactionCollectionByCountry(countryName);
  }
}
