class Settings
{
	public float drawScale = 9.7656;
	// 3,906 steps across board / 400 pixels in preview
	public int penUpAngle = 150;
	public int penDownAngle = 140;
	public int desiredSpeed = 100;
	public int accelMinSpeed = 20;
	public int accelPasses = 3;
	public float xStepsPerPoint = 2.77 * 2;// 200/72;
	public float yStepsPerPoint = 2.77 * 2 * 1.05;
	public float xStepsPerPixel = 3;
	public float yStepsPerPixel = 3;
	Settings()
	{

	}
}