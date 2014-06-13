class Settings
{
	// public float drawScale = 9.7656;
	// 3,906 steps across board / 400 pixels in preview
	public int penUpAngle = 70;
	public int penDownAngle = 74;
	public int desiredSpeed = 100;
	public int accelMinSpeed = 20;
	public int accelPasses = 3;

	public float xStepsPerPoint = 1 * (10/7.218) * 2;
	public float yStepsPerPoint = 1 * (10/6.875) * 2;
	public float xStepsPerPixel = 30;
	public float yStepsPerPixel = 30;

	public float canvasWidthPoints = 60 * 72;
	public float canvasHeightPoints = 25 * 72;


	Settings()
	{

	}
};

