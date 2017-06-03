class ScreenParameters{
  public static final int SCREEN_WIDTH = 1000;
  public static final int SCREEN_HEIGHT = 500;
  public static final int FRAME_RATE = 120;
  public static final int CHARGE_X_LIMIT = (int)(SCREEN_WIDTH*0.725);
  public static final int CHARGE_Y_LIMIT = (int)(SCREEN_HEIGHT*0.8);
  public static final int MENU_X = CHARGE_X_LIMIT;
  public static final int MENU_Y = CHARGE_Y_LIMIT;
  public static final int SLIDER_HEIGHT = 100;
  public static final int BACKGROUND_COLOR = 255;
  public static final int SLIDER_WIDTH = ScreenParameters.SCREEN_WIDTH-ScreenParameters.CHARGE_X_LIMIT-60;
  public static final String WELCOME_TEXT = "Click anywhere on screen to place a charge or select the presets provided below.\n\nUse the sliders to control the strength and polarity of the charge";
}

class Menu{
  private GButton clearButton;
  private GCustomSlider movingChargeSlider;
  private PApplet window;
  private GDropList presetList;
  private GToggleGroup presetGroup;
  private String[] presetItems = {"Custom Sandbox", "Single Charge", "Electric Dipole", "Two Unequal Charges", "Quadrupole"};
  private GOption[] presetOptions;
  private GPlot plot;
  private GLabel welcomeMessage;
  private GToggleGroup fieldToggle;
  private GCheckbox fieldLines; 
  private GCheckbox equipotentialLines;
  
  public Menu(PApplet window){
    this.window = window;
    int buttonX = ScreenParameters.MENU_X+20+(ScreenParameters.SCREEN_WIDTH-ScreenParameters.MENU_X)/2-60;
    G4P.messagesEnabled(false);
    clearButton = new GButton(window, buttonX, 20, 100, 30, "Clear Sandbox");
    clearButton.addEventHandler(window, "clearSandbox");
    clearButton.setFont(new Font("Tahoma", Font.PLAIN, 12));
    int sliderYPos = 25;
    movingChargeSlider = new GCustomSlider(window, ScreenParameters.MENU_X+40, sliderYPos, ScreenParameters.SLIDER_WIDTH, ScreenParameters.SLIDER_HEIGHT, "blue18px");
    movingChargeSlider.addEventHandler(window, "sliderHandler");
    movingChargeSlider.setNbrTicks(numberOfTicks);
    movingChargeSlider.setLimits((maxSliderValue+minSliderValue)/2,minSliderValue, maxSliderValue);
    movingChargeSlider.setShowDecor(false, true, true, true);
    qMovingCharge = movingChargeSlider.getValueI();
    
    GLabel label = new GLabel(window, ScreenParameters.MENU_X+10, 
      sliderYPos, 
      ScreenParameters.MENU_X- ScreenParameters.SLIDER_WIDTH, 
      ScreenParameters.SLIDER_HEIGHT, 
      "q\ntest:");

    label.setFont(new Font("Tahoma", Font.PLAIN, 12));
    
    welcomeMessage = new GLabel(window, ScreenParameters.MENU_X/2-200, 
    ScreenParameters.MENU_Y/2-250, 
    ScreenParameters.MENU_X*0.7, 200, 
    ScreenParameters.WELCOME_TEXT);
    welcomeMessage.setTextAlign(GAlign.MIDDLE,GAlign.MIDDLE);
    welcomeMessage.setFont(new Font("Tahoma", Font.PLAIN, 16));
    
    presetGroup = new GToggleGroup();
    presetOptions = new GOption[presetItems.length];
    for(int i =0; i < presetItems.length; i++){
      int xPos = 10;
      int yPos = ScreenParameters.CHARGE_Y_LIMIT+5+i*18;
      presetOptions[i] = new GOption(window, xPos, yPos, 180, 18);
      presetOptions[i].setText(presetItems[i]);
      presetOptions[i].addEventHandler(window,"drpPresetSelect");
      presetOptions[i].setFont(new Font("Tahoma", Font.PLAIN, 13));
      presetGroup.addControl(presetOptions[i]);
    }
    presetOptions[0].setSelected(true);
    buildGraph();
    
    fieldToggle = new GToggleGroup();
    
    fieldLines = new GCheckbox(window, 220, ScreenParameters.CHARGE_Y_LIMIT+5, 120, 20, "Field lines");
    fieldLines.addEventHandler(window, "checkBoxHandler");
    fieldToggle.addControl(fieldLines);
    
    equipotentialLines = new GCheckbox(window, 220, ScreenParameters.CHARGE_Y_LIMIT+35, 120, 20, "Equipotential lines");
    equipotentialLines.addEventHandler(window, "checkBoxHandler");
    fieldToggle.addControl(equipotentialLines);
  }
  
  private void buildGraph(){
    
    plot = new GPlot(window);
    //Set position and size info
    plot.setPos(ScreenParameters.CHARGE_X_LIMIT-320, ScreenParameters.CHARGE_Y_LIMIT+5);
    plot.setMar(20, 20, 20, 20);
    plot.setOuterDim(300,90);
    plot.setFontSize(8);
    plot.setXLim(-1, 1);
    plot.setYLim(0, 4);
    plot.getYAxis().setDrawTickLabels(false);
    plot.getYAxis().setAxisLabelText("Force (N)");
    plot.startHistograms(GPlot.VERTICAL);
    plot.getHistogram().setDrawLabels(true);
    plot.getHistogram().setRotateLabels(false);
    plot.setFontName("Tahoma");
    plot.getHistogram().setBgColors(new color[] {
      color(0, 0, 255, 50), color(0, 0, 255, 100), 
      color(0, 0, 255, 150), color(0, 0, 255, 200)
    }
    );
  }
  
  public GLabel getWelcomeMessage(){
    return welcomeMessage;
  }
  
  public GPlot getPlot(){
    return plot;
  }
  
  public GOption[] getPresetOptions(){
    return presetOptions;
  }
  
  public GDropList getPresetList(){
   return presetList; 
  }
  public String[] getPresetItems(){
   return presetItems; 
  }
  public GCustomSlider getMovingChargeSlider(){
   return movingChargeSlider; 
  }
  
  public GButton getClearButton(){
    return clearButton;
  }
  
  public GCheckbox getFieldLines(){
    return fieldLines;
  }
  
  public GCheckbox getEquipotentialLines(){
    return equipotentialLines;
  }
}

public void checkBoxHandler(GCheckbox source, GEvent event){
   if(menu.getFieldLines() == source){ 
     if(source.isSelected()){ 
       drawFieldLines = true;
     } else {
       drawFieldLines = false;
     }
   } else if(menu.getEquipotentialLines() == source){
      if(source.isSelected()){
        drawEquipotentialLines = true;
      } else {
        drawEquipotentialLines = false;
      }
   }
}

public void drpPresetSelect(GOption source, GEvent event){
  int selection = 0;
  switch(source.getText()){
    case "Single Charge":
    selection = 1;
    break;
    case "Electric Dipole":
    selection = 2;
    break;
    case "Two Unequal Charges":
    selection = 3;
    break;
    case "Quadrupole":
    selection = 4;
    break;
    default:
    selection = -1;
    break;
  }
  setPresets(selection);
  
}

public void setPresets(int selection){
  clearScreen();
  switch(selection){
    case 1:
      singleChargePreset();
      break;
    case 2:
      electricDipolePreset();
      break;
    case 3:
      twoUnequalChargesPreset();
      break;
    case 4:
      quadrupolePreset();
      break;
    default:
      System.out.println("Not implemented");
      break;
    
  }
}

public void quadrupolePreset(){
  int charge1 = 25;
  int charge2 = -25;
  int charge3 = 25;
  int charge4 = -25;
  
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.25), (int)(ScreenParameters.CHARGE_Y_LIMIT*0.25), charge1, this);
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.75), (int)(ScreenParameters.CHARGE_Y_LIMIT*0.25), charge2, this);
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.75), (int)(ScreenParameters.CHARGE_Y_LIMIT*0.75), charge3, this);
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.25), (int)(ScreenParameters.CHARGE_Y_LIMIT*0.75), charge4, this);
  
}

public void twoUnequalChargesPreset(){
  int charge1 = 25;
  int charge2 = -5;
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.25), ScreenParameters.CHARGE_Y_LIMIT/2, charge1, this);
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.75), ScreenParameters.CHARGE_Y_LIMIT/2, charge2, this);
}

public void electricDipolePreset(){
  int initialCharge = 25;
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.25), ScreenParameters.CHARGE_Y_LIMIT/2, initialCharge, this);
  fixedCharges.addCharge((int)(ScreenParameters.CHARGE_X_LIMIT*0.75), ScreenParameters.CHARGE_Y_LIMIT/2, -initialCharge, this);
}

public void singleChargePreset(){
  int initialCharge = 25;
  fixedCharges.addCharge(ScreenParameters.CHARGE_X_LIMIT/2, ScreenParameters.CHARGE_Y_LIMIT/2, initialCharge, this);
}

public void clearSandbox(GButton source, GEvent event){
  
  if(source == menu.getClearButton()){
    menu.getPresetOptions()[0].setSelected(true);
    clearScreen();
  }
}

public void clearScreen(){
  menu.getMovingChargeSlider().setValue(0); // Clear the test charge to 0
  ArrayList<Charge> charges = fixedCharges.getCharges();
    for(int i=0; i < charges.size(); i++){
      charges.get(i).clearGraphics();
    }
    fixedCharges.getCharges().clear();
}

//Draws all charges in the ArrayList to screen
void updateChargeDisplay(){
  if(!fixedCharges.getCharges().isEmpty()){ //Check if there are charges present to avoid NullPointerException   
    for(int i =0; i < fixedCharges.getCharges().size(); i++) //Iterate through all the charges
    {
      Charge charge = fixedCharges.getCharges().get(i);
      //Each charge will add a circle to the workspace.
      charge.drawCharge();
    }
  }
}