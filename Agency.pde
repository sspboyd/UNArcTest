public class Agency {
  // public class Agency extends UN {
  String unAgencyAbbrev;
  String agencyName;
  int year;
  float expenditure;
  ArrayList<Transaction> agencyTransactions;
  PVector currLoc, targLoc; // getter/setter?


  public Agency (int _year, String _unAgencyAbbrev, float _expenditure) {
    year = _year;
    unAgencyAbbrev = _unAgencyAbbrev;
    expenditure = _expenditure;
    currLoc = new PVector();
    targLoc = new PVector();

    agencyTransactions = transactionCollectionByAgency(unAgencyAbbrev);
  }


  void update() {
  }


  void render() {
  }
}
