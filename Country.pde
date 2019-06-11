public class Country {
  String countryName;
  int year;
  float amount;
  PVector currLoc, targLoc; // getter/setter?
  ArrayList<Transaction> countryTransactions = new ArrayList<Transaction>();
  color ctyMarkerClr, ctyTextClr;

  public Country (int _yr, String _countryName, float _amt) {
    countryName = _countryName;
    year = _yr;
    amount = _amt;

    currLoc = new PVector();
    targLoc = new PVector();

    ctyMarkerClr = unBlueClr;
    ctyTextClr = unBlueClr;
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
