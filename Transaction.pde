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
  }
}
