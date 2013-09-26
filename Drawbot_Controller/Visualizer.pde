// PVector currentLoc;

class Visualizer
{
    Visualizer()
    {
        // currentLoc = new PVector(10.0, 10.0);
    }

    void draw(Instruction_Set instructionSet, int currentInstruction)
    {
        pushMatrix();
        {
            translate(10.0, 10.0);
            noFill();
            PVector pos = new PVector(0, 0);
            //color c = color(100, 200, 200);
            boolean isPenUp = true;

            for (int i = 0; i < instructionSet.instructions.size(); i++)
            {
                Instruction instruction = (Instruction)instructionSet.instructions.get(i);

                if (instruction.name == "move")
                {
                    noStroke();
                    fill(255, 255, 255, 50);
                    ellipseMode(RADIUS);
                    ellipse(pos.x / settings.xStepsPerPixel, pos.y / settings.yStepsPerPixel, 1, 1);


                    // stroke(c);
                    if (i >= currentInstruction)
                    {
                        stroke(100, 100, 100, 100);
                    }
                    else
                    {
                        if (isPenUp)
                        {
                            stroke(0, 0, 255, 100);
                        }
                        stroke(instruction.params[2] * 2.5, 0, 0);
                    }

                    line(pos.x / settings.xStepsPerPixel, pos.y / settings.yStepsPerPixel,
                         (pos.x + instruction.params[0]) / settings.xStepsPerPixel, (pos.y + instruction.params[1]) / settings.yStepsPerPixel);


                    pos.x += instruction.params[0];
                    pos.y += instruction.params[1];
                }
                else if (instruction.name == "pen")
                {
                    //draw in green
                    if (instruction.params[0] == settings.penDownAngle) isPenUp = false;
                    //move in red
                    if (instruction.params[0] == settings.penUpAngle)  isPenUp = true;
                }

            }
        }
        popMatrix();
    }
}