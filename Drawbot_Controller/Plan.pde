class Plan
{
    ArrayList<Step> steps;
    Plan(){
    	steps = new ArrayList<Step>();
    }

    Plan(Plan _plan){
        steps = new ArrayList<Step>(_plan.steps);
    }
};

class Step
{
    float x;
    float y;
    float speed;
    boolean penDown;
    

    Step(float _x, float _y, float _speed, boolean _penDown)
    {
        x = _x;
        y = _y;
        speed = _speed;
        penDown = _penDown;
    }  
};
