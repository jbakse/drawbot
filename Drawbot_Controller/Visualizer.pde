PVector currentLoc;

class Visualizer {
	 Visualizer() {
	 	currentLoc = new PVector(0.0, 0.0);
	 }

	 void draw(){
		//draw vector data
		pushMatrix();
		{
		translate(10, 10);
		noFill();
		PVector pos = new PVector(0, 0);
		for (int i = 0; i < segments.size() * timeSliderValue; i++) {
			Segment seg = (Segment)segments.get(i);
			if (seg.type == "move") {
			stroke(200, 100, 100);
			}
			else if (seg.type == "draw") {
			stroke(100, 200, 100);
			}
			line(pos.x, pos.y, seg.x, seg.y);
			pos.x = seg.x;
			pos.y = seg.y;
		}
		}
		popMatrix();
	 }
}