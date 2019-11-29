public class DataCard {
  String title; 
  int year;
  float amount;
  PVector currLoc, targLoc; // getter/setter?
  int w, h; // width height
  // need country name(s), transaction total(s), Agency List
  //   ArrayList<Transaction> countryTransactions = new ArrayList<Transaction>(); // probably don't need this
  color borderClr, textClr, bgClr;


  public DataCard (int _yr, String _title, float _amt, int w, int h) {
    borderClr = unBlueClr;
    textClr = color(0);
    bgClr = color(255, 76);
  }
}
