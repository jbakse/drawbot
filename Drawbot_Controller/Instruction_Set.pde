class Instruction_Set {
	ArrayList instructions;

	Instruction_Set() {
		instructions = new ArrayList();
	}

	void appendPen(int _pos){
		instructions.add(new Instruction("pen", new int[]{_pos}));
	}

	void appendPenUp(){
		instructions.add(new Instruction("pen", new int[]{settings.penUpAngle}));
	}

	void appendPenDown(){
		instructions.add(new Instruction("pen", new int[]{settings.penDownAngle}));
	}

	void appendMove(int _x, int _y){
		instructions.add(new Instruction("move", new int[]{_x, _y}));
	}

	void appendSpeed(int _speed){
		instructions.add(new Instruction("speed", new int[]{_speed}));
	}

	String toString() {
		String output = "";
		for (int i = 0; i < instructions.size(); i++){
			output += instructions.get(i).toString() + "\n";
		}
		return output;
	}

}

class Instruction {
	String name;
	int code;
	int params[];
	
	Instruction(String _name, int _params[]) {
		name = _name;
		if (_name.equals("pen")){
			code = 1;
		}
		else if (_name.equals("move")){
			code = 2;
		}
		else if(_name.equals("reset")){
			code = 3;
		}
		else if(_name.equals("speed")){
			code = 8;
		}
		params = _params;
	}

	String toString() {
		String output = name + " (" + code + "): ";
		for (int i = 0; i < params.length; i++){
			output += params[i] + ", ";
		}
		return output;
	}
}