// PVector currentLoc;

class Visualizer
{
    Visualizer()
    {
        // currentLoc = new PVector(10.0, 10.0);
    }

   

    void draw(Instruction_Set instructionSet, int currentInstruction)
    {
        // float colorSpin = 0;
        pushMatrix();
        {
            translate(10.0, 10.0);


            //draw canvas frame
            noFill();
            stroke(150);
            rect(0, 0, (settings.canvasWidthPoints * settings.xStepsPerPoint) / settings.xStepsPerPixel, (settings.canvasHeightPoints * settings.yStepsPerPoint) / settings.yStepsPerPixel);

            //draw instructions
            noFill();
            PVector pos = new PVector(0, 0);
            boolean isPenUp = true;

            for (int i = 0; i < instructionSet.instructions.size(); i++)
            {
                Instruction instruction = (Instruction)instructionSet.instructions.get(i);

                if (instruction.name == "move")
                {
                    noStroke();
                    fill(255, 255, 255, 50);
                    ellipseMode(RADIUS);
                    //ellipse(pos.x / settings.xStepsPerPixel, pos.y / settings.yStepsPerPixel, 2, 2);

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
                        else
                        {
                            stroke(instruction.params[2] * 2.5, 0, 0);
                        }
                    }

                    // colorMode(HSB, 255);
                    // colorSpin += .1;
                    // stroke(colorSpin % 255, 255, 255);

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
