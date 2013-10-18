class Instruction_Set {
	ArrayList<Instruction> instructions;

	Instruction_Set() {
		instructions = new ArrayList<Instruction>();
	}
	
	void appendBot(String _bot) {
		String[] parts = _bot.split(",");
		int[] params = new int[parts.length-1];
		for (int i = 1; i < parts.length; i++){
			params[i-1] = Integer.parseInt(parts[i].trim());
		}
		instructions.add(new Instruction(Integer.parseInt(parts[0].trim()), params)); 
	}

	void appendPen(int _pos) {
		instructions.add(new Instruction("pen", new int[]{_pos}));
	}

	void appendPenUp() {
		instructions.add(new Instruction("pen", new int[]{settings.penUpAngle}));
	}

	void appendPenDown() {
		instructions.add(new Instruction("pen", new int[]{settings.penDownAngle}));
	}

	void appendHome() {
		instructions.add(new Instruction("home"));
	}

	void appendRelease() {
		instructions.add(new Instruction("release"));
	}


	void appendMove(int _x, int _y, int _speed) {
		instructions.add(new Instruction("move", new int[]{_x, _y, _speed}));
	}

	void appendSpeed(int _speed) {
		instructions.add(new Instruction("speed", new int[]{_speed}));
	}

	String toString() {
		String output = "";
		for (int i = 0; i < instructions.size(); i++) {
			output += instructions.get(i).toString() + "\n";
		}
		return output;
	}

}

class Instruction {
	String name;
	int code;
	int params[];
	
	Instruction(String _name) {
		this(_name, new int[]{});
	}
	Instruction(String _name, int _params[]) {
		name = _name;
		if (_name.equals("pen")){
			code = 1;
		}
		else if (_name.equals("move")){
			code = 2;
		}
		else if(_name.equals("home")){
			code = 3;
		}
		else if(_name.equals("release")){
			code = 4;
		}
		else if(_name.equals("speed")){
			code = 8;
		}
		params = _params;
	}

	Instruction(int _code, int _params[]) {
		code = _code;
		params = _params;
	}

	String toString() {
		String output = "" + code + ",";
		for (int i = 0; i < params.length; i++){
			output += params[i];
			if (i < params.length - 1) output += ", ";
		}
		output += "; //"+name;
		return output;
	}

	String toCommand() {
		String output =  code + ",";
		for (int i = 0; i < params.length; i++){
			output += params[i];
			if (i < params.length - 1) output += ",";
		}
		output += ";";
		output += "\n";
		return output;
	}
}