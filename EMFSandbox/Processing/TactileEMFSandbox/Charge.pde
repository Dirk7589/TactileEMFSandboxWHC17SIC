/*
Contains classes for ArrayList of charges and Charge object
*/
class Charges{
  private ArrayList<Charge> charges;
  private int lastSliderPosition = 0;
  public Charges(){
    charges = new ArrayList<Charge>();
  }
  
  public ArrayList<Charge> getCharges(){
    return charges;
  }
  
  public void addCharge(int x, int y, PApplet window){
    addCharge(x, y, 0, window);
  }
  
  public void addCharge(int x, int y, int chargeMagnitude, PApplet window){
    for(int i = 0 ; i < charges.size(); i ++){
      Charge oldCharge = charges.get(i);
      if(ScreenParameters.SCREEN_HEIGHT-ScreenParameters.SLIDER_HEIGHT < lastSliderPosition){
        return;
      }
      PVector oldCoords = new PVector(oldCharge.getCoordX(),oldCharge.getCoordY());
      PVector newCoords = new PVector(x, y);
      //Determine distance between the two centres
      double distance = newCoords.dist(oldCoords);
      //Minimum distance that is allowed between the two points is the sum of the two radii 
      //plus some nudge factor to avoid overlap with the charge's label
      double minDistance =  2*(oldCharge.getDrawRadius())+oldCharge.getScreenLabel().length()+30;
      
      //If the distance between the two points is less than the minimum, do not add charge
      if(distance < minDistance){
        return;
      }
      
    }
    int diameter = 10*2;
    if(x < 0+diameter || y < 0+diameter){
      return;
    }
    if(x > ScreenParameters.CHARGE_X_LIMIT+diameter || y > ScreenParameters.CHARGE_Y_LIMIT+diameter){
      return;
    }
    Charge charge = new Charge(x, y, chargeMagnitude, charges.size(), window); //Create the charge
    charges.add(charge);
  }
  
  public int getLastSliderPosition(){
    return lastSliderPosition;
  }
  public void setLastSliderPosition(int lastSliderPosition){
   this.lastSliderPosition = lastSliderPosition; 
  }
}

class Charge{
  private int coordX = 0;
  private int coordY = 0;
  private int charge = 0;
  private int drawRadius = 15;
  private GCustomSlider slider;
  private GLabel sliderLabel;
  private GLabel label;
  private int chargeID = 0;
  private String screenLabel = "";
  
  public Charge(int x, int y, int charge, int chargeID, PApplet window){
    this.coordX = x;
    this.coordY = y;
    this.charge = charge;
    this.chargeID = chargeID;
    
    int xPos = ScreenParameters.MENU_X + (40);
    int yPos = 25+((chargeID+1)*50);
    fixedCharges.setLastSliderPosition(yPos);
    
    slider = new GCustomSlider(window, xPos, yPos, ScreenParameters.SLIDER_WIDTH, ScreenParameters.SLIDER_HEIGHT, "blue18px");
    slider.setNbrTicks(numberOfTicks);
    slider.setLimits((maxSliderValue+minSliderValue)/2,minSliderValue, maxSliderValue);
    slider.setShowDecor(false, true, true, true);
    slider.setValue((float)charge);
    slider.addEventHandler(window, "sliderHandler");
    
    sliderLabel = new GLabel(window, ScreenParameters.MENU_X+20, 
      yPos, 
      ScreenParameters.MENU_X- ScreenParameters.SLIDER_WIDTH, 
      ScreenParameters.SLIDER_HEIGHT, 
      "q"+Integer.toString(chargeID)+":");
    sliderLabel.setFont(new Font("Tahoma", Font.PLAIN, 12));
  
    int nudgeX = this.getDrawRadius()+4;           //nudge factor for text in the x-direction
    int nudgeY = this.getDrawRadius()+12;          //nudge factor for text in the y-direction
    String screenLabel = "q"+Integer.toString(chargeID)+": "+Integer.toString(this.getCharge()) + "nC";
    
    label = new GLabel(window,this.getCoordX()+nudgeX,this.getCoordY()+nudgeY, 60, 15, screenLabel);
    label.setOpaque(true);
    label.setFont(new Font("Tahoma", Font.PLAIN, 12));
    label.setTextAlign(GAlign.CENTER,GAlign.CENTER);
  }
  
  public void clearGraphics(){
    //System.out.println("Disposing q"+chargeID);
    slider.dispose();
    slider = null;
    
    sliderLabel.dispose();
    sliderLabel = null;
    
    label.dispose();
    label = null;
  }
  
  public GCustomSlider getSlider(){
   return slider; 
  }
  
  public int getCoordX(){ 
    return coordX;  
  } 
  public int getCoordY(){
    return coordY;
  }
  public int getCharge(){
    return charge; 
  }   
  public int getDrawRadius(){ 
    return drawRadius;
  }
  public int getChargeID(){
    return chargeID;
  }
  public GLabel getLabel(){
    return label; 
  }
  
  public void setID(int id){
    this.chargeID = id;
  }
  public void setCharge(int charge){
    this.charge = charge;
  }
  
  public String getIcon(){
    if(charge > 0){
      return "positiveCharge.svg";
    } else if (charge == 0){
      return "neutralCharge.svg";
    }
    else{
      return "negativeCharge.svg";
    }
  }
  
  public String getScreenLabel(){
   return screenLabel; 
  }
  
  public void drawCharge(){
      //Load the charge from file and draw it's icon
      shape(loadShape(this.getIcon()), this.getCoordX()-this.getDrawRadius()/2, this.getCoordY()-this.getDrawRadius()/2, this.getDrawRadius(), this.getDrawRadius()); //Draws shape to the display window.
      
      //Update its label
      String screenLabel = "q"+Integer.toString(chargeID)+": "+Integer.toString(this.getCharge()) + "nC";
      label.moveTo(this.getCoordX()-60/2, this.getCoordY()+10);
      label.setText(screenLabel);
  }
}

public void sliderHandler(GCustomSlider source, GEvent event){
  
  if(event == GEvent.VALUE_STEADY){
    //System.out.println("handled");
    if(source == menu.getMovingChargeSlider()){
      qMovingCharge = source.getValueI();
      return;
    }
    for(int i = 0; i < fixedCharges.getCharges().size(); i++){
       Charge charge = fixedCharges.getCharges().get(i);
       if(charge.getSlider() == source){
         charge.setCharge(source.getValueI());
         return;
       }
    }
  }
}