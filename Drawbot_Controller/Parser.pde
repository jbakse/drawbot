RShape svgShape;
ArrayList segments;

class Parser {
	Parser() {
		segments = new ArrayList();
	}
	parseBOT() {
			
		botController.instructions = new ArrayList();
		try {
		BufferedReader reader;
		reader = createReader(selection.getAbsolutePath());  
		String fileLine;
		while ( (fileLine = reader.readLine()) != null) {
			if (!fileLine.equals("")){
			botController.instructions.add(fileLine);
			}
		}
		}
		catch(IOException e){
		println("could not read the .bot file");
		}

		instructionListBox.clear();
		for (int i=0;i<botController.instructions.size();i++) {
		ListBoxItem lbi = instructionListBox.addItem((String)botController.instructions.get(i), i);
			// lbi.setColorBackground(0xffff0000);
		}
		}

		void parseSVG(String file) {
		println("Parse File: "+ file);
		//Read Data
		svgShape = RG.loadShape(file);
		if (svgShape == null) {
		println("Failed to read SVG data");
		return;
		}

		//Polygonize
		RG.setPolygonizer(RG.ADAPTATIVE);
		RPoint[][] pointPaths;
		pointPaths = svgShape.getPointsInPaths();
		if (pointPaths == null || pointPaths.length == 0) {
		println("Failed to polygonize vector data");
		return;
		}

		//Build Segments
		segments = new ArrayList();

		for (int i = 0; i<pointPaths.length; i++) {
		if (pointPaths[i] != null && pointPaths.length > 0) {
			segments.add(new Segment("move", pointPaths[i][0].x, pointPaths[i][0].y));
			for (int j = 1; j<pointPaths[i].length; j++) {
			segments.add(new Segment("draw", pointPaths[i][j].x, pointPaths[i][j].y));
			}
		}
		}

		botController.loadSegments(segments);
	}
}