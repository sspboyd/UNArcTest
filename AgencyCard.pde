/// questions: create 1 AgencyCard object and update it? Or, create one card object for each agency and just pull it from an array each time to update.??


public class AgencyCard {
  String agencyName; 
  int year;
  float amount;
  Agency agency;
  PVector currLoc, targLoc; // getter/setter?
  float w, h; // width height
  color borderClr, textClr, bgClr;


  public AgencyCard (Agency _agency) {
    agency = _agency;
    borderClr = unBlueClr;
    textClr = color(0);
    bgClr = color(255, 199);

    currLoc = new PVector();
    targLoc = new PVector();
  }

  void render() {
    if (agency.hover) {
      currLoc.x = PLOT_X1;
      currLoc.y = fundingAxis2.y-20;
      w = fundingAxis1.x - currLoc.x-47;
      h = PLOT_Y2 - fundingAxis2.y;


      fill(bgClr);
      noStroke();
      // stroke(borderClr);
      // strokeWeight(3);
      rect(currLoc.x, currLoc.y, w, h);
      fill(textClr);
      textFont(agHoverLabelF);
      textLeading(36);
      text(agency.agencyName, currLoc.x + 11, currLoc.y+47, w-11, h-11);
      text("$"+ nfc(agency.expenditure, 0), currLoc.x + 11, currLoc.y+199, w-11, h-11);
    }
  }
}
