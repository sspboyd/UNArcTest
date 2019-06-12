public class Country {
  String countryName;
  int year;
  float amount;
  PVector currLoc, targLoc; // getter/setter?
  ArrayList<Transaction> countryTransactions = new ArrayList<Transaction>();
  color ctyMarkerClr, ctyTextClr;
  boolean hover;

  public Country (int _yr, String _countryName, float _amt) {
    countryName = _countryName;
    year = _yr;
    amount = _amt;

    currLoc = new PVector();
    targLoc = new PVector();

    ctyMarkerClr = unBlueClr;
    ctyTextClr = unBlueClr;

    hover = false;
  }

  void checkHover() {
    if (currLoc.dist(new PVector(mouseX, mouseY)) < 5) {
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
    int ctyRank = expenditureByCountryTbl.findRowIndex(countryName, "Country");
    currLoc.x = countryAxis1.x;
    currLoc.y = map(ctyRank, 0, expenditureByCountryTbl.getRowCount()-1, countryAxis1.y, countryAxis2.y);

    // update the colour of marker and text style
    ctyMarkerClr=unBlueClr;
    ctyTextClr=unBlueClr;
  }

  void render() {
    // render country name
    float textX = currLoc.x + 18;
    float textY = currLoc.y;
    fill(countryLabelClr);
    text(countryName, textX, textY);
  }

  void setCountryTransactionList() {
    countryTransactions = transactionCollectionByCountry(countryName);
  }
}
