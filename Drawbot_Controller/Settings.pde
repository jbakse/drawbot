class Settings
{
	// public float drawScale = 9.7656;
	// 3,906 steps across board / 400 pixels in preview
	public int penUpAngle = 130;
	public int penDownAngle = 116;
	public int desiredSpeed = 100;
	public int accelMinSpeed = 20;
	public int accelPasses = 3;
	public float xStepsPerPoint = 1 * (10/7.218);
	public float yStepsPerPoint = 1 * (10/6.875);
	public float xStepsPerPixel = 20 / 5;
	public float yStepsPerPixel = 20 / 5;

	public float canvasWidthPoints = 60 * 72;
	public float canvasHeightPoints = 25 * 72;


	Settings()
	{

	}
}