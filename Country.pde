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

  public Country() { // when would this be used? search for init of class w no args
  }

  void resetHoverHighlight() {
    hover = false;
    highlight = false;
  }

  void checkHover() {
    if ( (countryAxis1.x-200 < mouseX) && (mouseX < PLOT_X2) && (abs(currLoc.y - mouseY) < 2) ) {
      hover = true;
      univHover = true; // globally available var for hover
      // set related Agency and Country objects to highlight = true;
      for (Transaction ctyTran : countryTransactions) {
        ctyTran.highlight = true;
        ctyTran.agency.highlight = true;
      }
    } else {
      hover = false;
    }
  }

  void setHover() {
    hover = true;
    univHover = true; // globally available var for hover
    // set related Agency and Country objects to highlight = true;
    for (Transaction ctyTran : countryTransactions) {
      ctyTran.highlight = true;
      ctyTran.agency.highlight = true;
    }
  }

  void updateStyle() {
    textFont(axesLabelF);

    if (univHover) { // if true, then set this object to either highlighted or faded style
      if (hover || highlight) { // true, highlighted style
        ctyMarkerClr=unBlueClr;
        ctyTextClr=unBlueClr;
      } else { // false, fade style
        ctyMarkerClr=color(0, 18);
        ctyTextClr=color(0, 18);
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
    // setting text location vars
    float textX = currLoc.x + 18;
    float textY = currLoc.y;

    if (hover) {
      fill(unBlueClr, 76);
      rect(countryAxis1.x, currLoc.y, PLOT_X2 - countryAxis1.x, 50);
      fill(0);
      textFont(agHoverLabelF);
      text("$"+nfc(amount, 0), textX, textY+textAscent()*(3));
    }

    // render country name
    if (hover) {
      // textLeading(10);
      textFont(cntryHoverLabelF);
    } else {
      textFont(axesLabelF );
    }
    fill(ctyTextClr);
    textLeading(35);
    text(countryName, textX, textY-textAscent(), PLOT_X2-currLoc.x, 400);
  }

  void setCountryTransactionList() {
    countryTransactions = transactionCollectionByCountry(countryName);
  }
}
