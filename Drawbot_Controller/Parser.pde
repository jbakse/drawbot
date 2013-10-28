RShape svgShape;
ArrayList segments;

class Parser
{
	Parser()
	{
		segments = new ArrayList();
	}
	Instruction_Set parseBOT(String file)
	{
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
		}
		catch (IOException e) {
			println("could not read the .bot file");
		}


		return instructions;

	}

	Instruction_Set parseSVG2(String file)
	{
		println("parseSVG2: " + file);

		if (!checkPath(file)) {
			println("File doesn't exist! " + file);
			return null;
		}

		//Read Data
		svgShape = RG.loadShape(file);
		if (svgShape == null) {
			println("Failed to read SVG data");
			return null;
		}

		//Polygonize
		RG.setPolygonizer(RG.ADAPTATIVE);
		RPoint[][] pointPaths;
		pointPaths = svgShape.getPointsInPaths();
		if (pointPaths == null || pointPaths.length == 0) {
			println("Failed to polygonize vector data");
			return null;
		}



		//Build Plan
		println("Build Plan");

		Plan plan = new Plan();
		for (int i = 0; i < pointPaths.length; i++) {
			if (pointPaths[i] != null && pointPaths.length > 0) {
				println("x " +pointPaths[i][0].x + ", " + pointPaths[i][0].y);
				plan.steps.add(new Step(pointPaths[i][0].x, pointPaths[i][0].y,  settings.desiredSpeed, false));
				for (int j = 1; j < pointPaths[i].length -1; j++) { // - 1 because polygonizer is giveing a duplicate at the end
					println("  " +pointPaths[i][j].x + ", " + pointPaths[i][j].y);
					plan.steps.add(new Step(pointPaths[i][j].x, pointPaths[i][j].y, settings.desiredSpeed, true));
				}
			}
		}



		//accelerize plan
		//plan = accelerize(plan);


		//gcode plan
		float cmScale = .3527;


		PrintWriter output = createWriter("output.gcode");
		output.println("G1 F1000");
		output.println("G1 Z2.0");

		boolean penDown = false;
		for (int i = 0; i < plan.steps.size(); i++) {
			Step step = plan.steps.get(i);
			if (penDown && !step.penDown) {
				output.println("G1 F100");
				output.println("G1 Z2.0");
				output.println("G1 F1000");
				penDown = false;
			}
			if (!penDown && step.penDown) {
				output.println("G1 F100");
				output.println("G1 Z0.0");
				output.println("G1 F1000");
				penDown = true;
			}
			output.println("G1 X" + step.x * cmScale + " Y" + step.y * cmScale);

		}
		output.flush();
  		output.close();


		//generate instructions
		Instruction_Set instructions = new Instruction_Set();
		float posX = 0;
		float posY = 0;
		penDown = false;
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
			println(x + " " + y + " " + (int)step.speed);
			instructions.appendMove(x, y, (int)step.speed);
			posX += x;
			posY += y;
		}



		return instructions;

	}









	Instruction_Set parseSVG(String file)
	{
		println("Parse File: " + file);

		if (!checkPath(file)) {
			println("File doesn't exist! " + file);
			return null;
		}

		//Read Data
		svgShape = RG.loadShape(file);
		if (svgShape == null) {
			println("Failed to read SVG data");
			return null;
		}

		//Polygonize
		RG.setPolygonizer(RG.ADAPTATIVE);
		RPoint[][] pointPaths;
		pointPaths = svgShape.getPointsInPaths();
		if (pointPaths == null || pointPaths.length == 0) {
			println("Failed to polygonize vector data");
			return null;
		}

		//Build Instructions
		float posX = 0;
		float posY = 0;

		boolean penDown = false;

		Instruction_Set instructions = new Instruction_Set();
		instructions.appendSpeed(settings.desiredSpeed);

		for (int i = 0; i < pointPaths.length; i++) {
			if (pointPaths[i] != null && pointPaths.length > 0) {
				for (int j = 0; j < pointPaths[i].length; j++) {
					if (j == 0) {
						instructions.appendPenUp();
					}
					if (j == 1) {
						instructions.appendPenDown();
					}
					int x = (int)((pointPaths[i][j].x * settings.xStepsPerPoint) - posX);
					int y = (int)((pointPaths[i][j].y * settings.yStepsPerPoint) - posY);
					instructions.appendMove(x, y, settings.desiredSpeed);
					posX += x;
					posY += y;
				}
			}
		}

		return instructions;
	}
	// botController.loadSegments(segments);


	boolean checkPath(String path)
	{
		File f = new File(path);
		return f.exists();
	}


};



Plan accelerize(Plan _plan)
{
	//segment plan
	Plan segmentedPlan = new Plan();
	float SEGMENT_SIZE = 3;

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
			continue;
		}

		float segments = (int)(distance / SEGMENT_SIZE);
		float segmentX = deltaX / segments;
		float segmentY = deltaY / segments;
		for (int seg = 1; seg <= segments; seg++) {
			segmentedPlan.steps.add(new Step(startX + segmentX * seg, startY + segmentY * seg, speed, penDown));
		}
	}


	//calc vectors
	ArrayList<PVector> stepVectors;
	stepVectors = new ArrayList<PVector>();
	stepVectors.add(new PVector(0, 0));

	println(segmentedPlan.steps.size() + " sizes " + stepVectors.size());
	for (int i = 1; i < segmentedPlan.steps.size(); i++) {
		float startX = segmentedPlan.steps.get(i - 1).x;
		float startY = segmentedPlan.steps.get(i - 1).y;
		float endX = segmentedPlan.steps.get(i).x;
		float endY = segmentedPlan.steps.get(i).y;
		float deltaX = endX - startX;
		float deltaY = endY - startY;
		float distance = sqrt(deltaX * deltaX + deltaY * deltaY);
		stepVectors.add(new PVector(deltaX / distance, deltaY / distance));
	}


	//find places we need to slow down, set their speeds
	float thresholdX = .25;
	float thresholdY = .25;
	segmentedPlan.steps.get(0).speed = settings.accelMinSpeed;
	println(segmentedPlan.steps.size() + " sizes " + stepVectors.size());
	for (int i = 1; i < segmentedPlan.steps.size(); i++) {
		if (abs(stepVectors.get(i).x - stepVectors.get(i - 1).x) > thresholdX
		        ||
		        abs(stepVectors.get(i).y - stepVectors.get(i - 1).y) > thresholdY
		   ) {
			segmentedPlan.steps.get(i).speed = settings.accelMinSpeed;
		}
	}


	// smooth it
	for (int pass = 0; pass < settings.accelPasses; pass++) {

		for (int i = 1; i < segmentedPlan.steps.size(); i++) {
			float lastSpeed = segmentedPlan.steps.get(i-1).speed;
			float thisSpeed = segmentedPlan.steps.get(i).speed;
			float avg = (thisSpeed + lastSpeed) / 2;

			if (avg < lastSpeed) {
				segmentedPlan.steps.get(i-1).speed = avg;
			}
			if (avg < thisSpeed) {
				segmentedPlan.steps.get(i).speed = avg;
			}
		}

	}


	return segmentedPlan;


}
