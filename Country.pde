public class Country {
  String countryName;
  int year;
  float amount;
  PVector currLoc, targLoc; // getter/setter?
  ArrayList<Transaction> countryTransactions = new ArrayList<Transaction>();

  public Country (int _yr, String _countryName, float _amt) {
    countryName = _countryName;
    year = _yr;
    amount = _amt;

    currLoc = new PVector();
    targLoc = new PVector();
    
  }

  void update() {
  }

  void render() {
  }

  void setCountryTransactionList(){
    countryTransactions = transactionCollectionByCountry(countryName);
  }
}
