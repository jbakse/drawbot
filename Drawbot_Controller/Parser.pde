RShape svgShape;
ArrayList segments;

class Parser {
	Parser() {
		segments = new ArrayList();
	}
	Instruction_Set parseBOT(String file) {
		// return new Instruction_Set();

		Instruction_Set instructions = new Instruction_Set();

		try {
			BufferedReader reader;
			reader = createReader(file);  
			String fileLine;
			while ( (fileLine = reader.readLine()) != null) {
				if (!fileLine.equals("")){
					instructions.appendBot(fileLine);
				}
			}
		}
		catch(IOException e){
			println("could not read the .bot file");
		}
	

		return instructions;


		// botController.instructions = new ArrayList();
		// try {
		// 	BufferedReader reader;
		// 	reader = createReader(file);  
		// 	String fileLine;
		// 	while ( (fileLine = reader.readLine()) != null) {
		// 		if (!fileLine.equals("")){
		// 			botController.instructions.add(fileLine);
		// 		}
		// 	}
		// }
		// catch(IOException e){
		// 	println("could not read the .bot file");
		// }

		// instructionListBox.clear();
		// for (int i=0;i<botController.instructions.size();i++) {
		// 	ListBoxItem lbi = instructionListBox.addItem((String)botController.instructions.get(i), i);
		// 	// lbi.setColorBackground(0xffff0000);
		// }
	}

	Instruction_Set parseSVG(String file) {
		println("Parse File: "+ file);
		
		if (!checkPath(file)) {
			println("File doesn't exist! "+file);
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
				for (int j = 0; j<pointPaths[i].length; j++) {
					if (j == 0){
						instructions.appendPenUp();
					}
					if (j == 1){
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

		// botController.loadSegments(segments);
	}

	boolean checkPath(String path){
		File f = new File(path);
		return f.exists(); 
	}
}



