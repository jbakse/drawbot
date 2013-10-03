ControlP5 cp5;

Rectangle previewRect;
Rectangle listRect;
Rectangle controlRect;
Rectangle consoleRect;

ListBox instructionListBox;
Textarea consoleTextArea;
Println console;

float timeSliderValue;

class User_Interface
{
	User_Interface()
	{
		previewRect = new Rectangle(10, 10, 400, 200);
		listRect = new Rectangle(420, 25, 370, 380);
		controlRect = new Rectangle(10, 220, 400, 370);
		consoleRect = new Rectangle(420, 415, 370, 175);

		cp5.setColorBackground(color(25));
		cp5.setColorActive(color(255, 120, 0));
		cp5.setColorForeground(color(200, 70, 0));


		Slider speed = cp5.addSlider(settings, "desiredSpeed", "desiredSpeed", 10.0, 400.0, settings.desiredSpeed, (int)controlRect.x, (int)controlRect.y + 100, 100, 17);

		Slider penUp = cp5.addSlider(settings, "penUpAngle", "penUpAngle", 50.0, 150.0, settings.penUpAngle, (int)controlRect.x, (int)controlRect.y + 120, 100, 17);
		penUp.addCallback(new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
					botDriver.sendInstruction(new Instruction("pen", new int[] {settings.penUpAngle}));
				}
			}
		});



		Slider penDown = cp5.addSlider(settings, "penDownAngle", "penDownAngle", 50.0, 150.0, settings.penDownAngle, (int)controlRect.x, (int)controlRect.y + 140, 100, 17);
		penDown.addCallback(new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {

				if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
					botDriver.sendInstruction(new Instruction("pen", new int[] {settings.penDownAngle}));
				}
			}
		});

		Button moveUp = cp5.addButton("moveUp").setPosition((int)controlRect.x, (int)controlRect.y + 180);
		moveUp.addCallback(new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
					botDriver.sendInstruction(new Instruction("move", new int[] {0, -100, 100}));
				}
			}
		});

		Button moveDown = cp5.addButton("moveDown").setPosition((int)controlRect.x, (int)controlRect.y + 200);
		moveDown.addCallback(new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
					botDriver.sendInstruction(new Instruction("move", new int[] {0, 100, 100}));
				}
			}
		});

		Button moveLeft = cp5.addButton("moveLeft").setPosition((int)controlRect.x, (int)controlRect.y + 220);
		moveLeft.addCallback(new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
					botDriver.sendInstruction(new Instruction("move", new int[] { -100, 0, 100}));
				}
			}
		});

		Button moveRight = cp5.addButton("moveRight").setPosition((int)controlRect.x, (int)controlRect.y + 240);
		moveRight.addCallback(new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
					botDriver.sendInstruction(new Instruction("move", new int[] {100, 0, 100}));
				}
			}
		});

        Button home = cp5.addButton("home").setPosition((int)controlRect.x, (int)controlRect.y + 270);
        home.addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
                    botDriver.sendInstruction(new Instruction("home"));
                }
            }
        });



		cp5.addSlider("timeSliderValue")
		.setPosition(controlRect.x, controlRect.y)
		.setWidth((int)controlRect.w)
		.setRange(0, 1)
		.setSliderMode(Slider.FLEXIBLE)
		;

		cp5.getController("timeSliderValue").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
		cp5.getController("timeSliderValue").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

		cp5.addButton("openSVG")
		.setPosition(controlRect.x, controlRect.y + 40)
		.setSize(100, 20)
		;

		cp5.addButton("openBOT")
		.setPosition(controlRect.x + 110, controlRect.y + 40)
		.setSize(100, 20)
		;

		cp5.addButton("startBot")
		.setPosition(controlRect.x + 220, controlRect.y + 40)
		.setSize(100, 20)
		;

		instructionListBox = cp5.addListBox("instructionListBox")
		                     .setPosition(listRect.x, listRect.y)
		                     .setSize((int)listRect.w, (int)listRect.h)
		                     .setItemHeight(20)
		                     .setBarHeight(15)
		                     .setScrollbarWidth(20)
		                     ;
		instructionListBox.captionLabel().set("Bot Instructions");
		instructionListBox.captionLabel().style().marginTop = 3;
		instructionListBox.valueLabel().style().marginTop = 3;


		consoleTextArea = cp5.addTextarea("txt")
		                  .setPosition(consoleRect.x, consoleRect.y)
		                  .setSize((int)consoleRect.w, (int)consoleRect.h)
		                  .setLineHeight(14)
		                  .setColor(color(200))
		                  .setColorBackground(color(0, 100))
		                  .setColorForeground(color(255, 100));

		// console = cp5.addConsole(consoleTextArea);



		timeSliderValue = 1.0;

	}

	void draw()
	{

	}
}