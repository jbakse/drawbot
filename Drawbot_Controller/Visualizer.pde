PVector currentLoc;

class Visualizer {
	 Visualizer() {
	 	currentLoc = new PVector(10.0, 10.0);
	 }

	 void draw(Instruction_Set instructionSet, int currentInstruction){
		pushMatrix();
		{
			translate(currentLoc.x, currentLoc.y);
			noFill();
			PVector pos = new PVector(0, 0);
			color c = color(100, 200, 200);
			println(""+currentInstruction);
			for (int i = 0; i < instructionSet.instructions.size(); i++) {
				Instruction instruction = (Instruction)instructionSet.instructions.get(i);
				if (i > currentInstruction) {
					c = color(100, 100, 100);
				}
				if (instruction.name == "move") {
					stroke(c);
					line(pos.x / settings.xStepsPerPixel, pos.y / settings.yStepsPerPixel, 
						 (pos.x + instruction.params[0]) / settings.xStepsPerPixel, (pos.y + instruction.params[1]) / settings.yStepsPerPixel);
					pos.x += instruction.params[0];
					pos.y += instruction.params[1];
				} else if (instruction.name == "pen") {
					if (instruction.params[0] == settings.penDownAngle) c = color(100, 200, 100);
					if (instruction.params[0] == settings.penUpAngle) c = color(255, 0, 0, 100);	
				}				
			}
		}
		popMatrix();
	 }
}