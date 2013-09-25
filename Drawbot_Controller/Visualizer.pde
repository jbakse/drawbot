// PVector currentLoc;

class Visualizer {
	 Visualizer() {
	 	// currentLoc = new PVector(10.0, 10.0);
	 }

	 void draw(Instruction_Set instructionSet, int currentInstruction){
		pushMatrix();
		{
			translate(10.0, 10.0);
			noFill();
			PVector pos = new PVector(0, 0);
			color c = color(100, 200, 200);
			
			for (int i = 0; i < instructionSet.instructions.size(); i++) {
				Instruction instruction = (Instruction)instructionSet.instructions.get(i);

				if (instruction.name == "move") {
					stroke(c);
					stroke(instruction.params[2] * 2.5, 0, 0);
					
					line(pos.x / settings.xStepsPerPixel, pos.y / settings.yStepsPerPixel, 
						 (pos.x + instruction.params[0]) / settings.xStepsPerPixel, (pos.y + instruction.params[1]) / settings.yStepsPerPixel);
					stroke(255);

					ellipseMode(RADIUS);
					ellipse(pos.x / settings.xStepsPerPixel, pos.y / settings.yStepsPerPixel, .5, .5);
					pos.x += instruction.params[0];
					pos.y += instruction.params[1];
				} else if (instruction.name == "pen") {
					//draw in green
					if (instruction.params[0] == settings.penDownAngle) c = color(100, 200, 100);
					//move in red
					if (instruction.params[0] == settings.penUpAngle) c = color(255, 0, 0, 100);	
				}


				//gray lines for instructions not done yet
				if (i >= currentInstruction) {
					c = color(100, 100, 100);
				}		
			}
		}
		popMatrix();
	 }
}