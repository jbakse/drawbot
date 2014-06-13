RShape svgShape;
ArrayList segments;

class Parser {
    Parser() {
        segments = new ArrayList();
    }
    synchronized Instruction_Set parseBOT(String file) {
        // return new Instruction_Set();

        Instruction_Set instructions = new Instruction_Set();

        try {
            BufferedReader reader;
            reader = createReader(file);
            String fileLine;
            while ((fileLine = reader.readLine()) != null) {
                if (!fileLine.equals("")) {
                    instructions.appendBot(fileLine);
                }
            }
        } catch (IOException e) {
            println("could not read the .bot file");
        }


        return instructions;

    }

    synchronized Instruction_Set parseSVG2(String file) {
        println("parseSVG2: " + file);

        if (!checkPath(file)) {
            println("File doesn't exist! " + file);
            return null;
        }

        // Read Data
        svgShape = RG.loadShape(file);
        if (svgShape == null) {
            println("Failed to read SVG data");
            return null;
        }

        // Polygonize
        RG.setPolygonizer(RG.ADAPTATIVE);
        RPoint[][] pointPaths;
        pointPaths = svgShape.getPointsInPaths();
        if (pointPaths == null || pointPaths.length == 0) {
            println("Failed to polygonize vector data");
            return null;
        }



        // Build Inital Plan
        // Build plan by copying vector points, all at full speed.
        Plan plan = new Plan();
        for (int i = 0; i < pointPaths.length; i++) {
            if (pointPaths[i] != null && pointPaths[i].length > 0) {
                plan.steps.add(new Step(pointPaths[i][0].x, pointPaths[i][0].y, settings.desiredSpeed, false));
                for (int j = 1; j < pointPaths[i].length - 1; j++) { // - 1 because polygonizer is giveing a duplicate at the end
                    plan.steps.add(new Step(pointPaths[i][j].x, pointPaths[i][j].y, settings.desiredSpeed, true));
                }
            }
        }


        plan = segmentize(plan);
        plan = accelerize(plan);


        //generate instructions

        Instruction_Set instructions = new Instruction_Set();
        float posX = 0;
        float posY = 0;
        boolean penDown = false;
        for (int i = 0; i < plan.steps.size(); i++) {
            Step step = plan.steps.get(i);
            if (penDown && !step.penDown) {
                instructions.appendPenUp();
                penDown = false;
            }
            if (!penDown && step.penDown) {
                instructions.appendPenDown();
                penDown = true;
            }
            int x = (int)((step.x * settings.xStepsPerPoint) - posX);
            int y = (int)((step.y * settings.yStepsPerPoint) - posY);
            //  println(x + " " + y + " " + (int)step.speed);
            instructions.appendMove(x, y, (int)step.speed);
            posX += x;
            posY += y;
        }


        {
            PrintWriter output = createWriter("output.bot");
            output.println(instructions.toString());

            output.flush();
            output.close();
        }

        return instructions;

    }


    boolean checkPath(String path) {
        File f = new File(path);
        return f.exists();
    }


};


// find steps in plan that are longer than SEGMENT_SIZE, break these steps into multiple steps of the same length near SEGMENT_SIZE

Plan segmentize(Plan _plan) {
    Plan segmentedPlan = new Plan();
    float SEGMENT_SIZE = 10;

    segmentedPlan.steps.add(_plan.steps.get(0));

    for (int i = 1; i < _plan.steps.size(); i++) {
        float startX = _plan.steps.get(i - 1).x;
        float startY = _plan.steps.get(i - 1).y;
        float endX = _plan.steps.get(i).x;
        float endY = _plan.steps.get(i).y;
        float speed = _plan.steps.get(i).speed;
        boolean penDown = _plan.steps.get(i).penDown;
        float deltaX = endX - startX;
        float deltaY = endY - startY;


        float distance = sqrt(deltaX * deltaX + deltaY * deltaY);

        if (distance < SEGMENT_SIZE) {
            segmentedPlan.steps.add(_plan.steps.get(i));
        } else {
            float segments = (int)(distance / SEGMENT_SIZE);
            float segmentX = deltaX / segments;
            float segmentY = deltaY / segments;
            for (int seg = 1; seg <= segments; seg++) {
                segmentedPlan.steps.add(new Step(startX + segmentX * seg, startY + segmentY * seg, speed, penDown));
            }
        }
    }

    return segmentedPlan;
}

Plan accelerize(Plan _plan) {
    Plan accelerizedPlan = new Plan(_plan);

    // calculate a normalized vector between each step, representing the direction of travel
    ArrayList<PVector> stepVectors;
    stepVectors = new ArrayList<PVector>();
    stepVectors.add(new PVector(0, 0));

    
    for (int i = 1; i < accelerizedPlan.steps.size(); i++) {
        float startX = accelerizedPlan.steps.get(i - 1).x;
        float startY = accelerizedPlan.steps.get(i - 1).y;
        float endX = accelerizedPlan.steps.get(i).x;
        float endY = accelerizedPlan.steps.get(i).y;
        float deltaX = endX - startX;
        float deltaY = endY - startY;
        float distance = sqrt(deltaX * deltaX + deltaY * deltaY);
        stepVectors.add(new PVector(deltaX / distance, deltaY / distance));
    }


    //find places we need to slow down, set their speeds
    float thresholdX = .25;
    float thresholdY = .25;
    accelerizedPlan.steps.get(0).speed = settings.accelMinSpeed;
    println(accelerizedPlan.steps.size() + " sizes " + stepVectors.size());
    for (int i = 1; i < accelerizedPlan.steps.size(); i++) {
        if (abs(stepVectors.get(i).x - stepVectors.get(i - 1).x) > thresholdX
                ||
                abs(stepVectors.get(i).y - stepVectors.get(i - 1).y) > thresholdY
           ) {
            accelerizedPlan.steps.get(i).speed = settings.accelMinSpeed;
        }
    }


    // smooth it
    for (int pass = 0; pass < settings.accelPasses; pass++) {

        for (int i = 1; i < accelerizedPlan.steps.size(); i++) {
            float lastSpeed = accelerizedPlan.steps.get(i - 1).speed;
            float thisSpeed = accelerizedPlan.steps.get(i).speed;
            float avg = (thisSpeed + lastSpeed) / 2;

            if (avg < lastSpeed) {
                accelerizedPlan.steps.get(i - 1).speed = avg;
            }
            if (avg < thisSpeed) {
                accelerizedPlan.steps.get(i).speed = avg;
            }
        }

    }


    return accelerizedPlan;


}


/*
       //gcode plan
       {
           float cmScale = .3527;

           PrintWriter output = createWriter("output.gcode");
           output.println("G92 X0 Y0 Z0 E0");
           float extrude = 0;

           float oldX = 0;
           float oldY = 0;
           boolean penDown = false;

           for (int l = 0; l < 10; l++)
           {

               output.println("G1 F200");
               output.println("G1 Z2.0");
               output.println("G1 F500");



               for (int i = 0; i < plan.steps.size(); i++)
               {
                   Step step = plan.steps.get(i);
                   if (penDown && !step.penDown)
                   {
                       output.println("G1 F200");
                       output.println("G1 Z" + (1.0 + l * .3));
                       output.println("G1 F500");
                       penDown = false;
                   }
                   if (!penDown && step.penDown)
                   {
                       output.println("G1 F200");
                       output.println("G1 Z" + (0.0 + l * .3));
                       output.println("G1 F500");
                       penDown = true;
                   }

                   float newX = step.x * cmScale;
                   float newY = step.y * cmScale;
                   float distanceCM = sqrt((newX - oldX) * (newX - oldX) + (newY - oldY) * (newY - oldY));
                   oldX = newX;
                   oldY = newY;
                   float extrudeScale = .08;

                   if (penDown)
                   {
                       extrude += distanceCM * extrudeScale;
                       output.println("G1 X" + newX + " Y" + newY + " E" + extrude); //100.0 -
                   }
                   else
                   {
                       output.println("G1 X" + newX + " Y" + newY); //100.0 -
                   }
               }




           }
           output.println("G1 F200");
           output.println("G1 Z2.0");
           output.println("M84"); //release motors

           output.flush();
           output.close();


           //accelerize plan
       }
       */
