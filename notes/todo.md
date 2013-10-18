TODO
=====

.mechanical
	.put 3DPrinted parts online
	.clean up illustrator design file and cut files

	.design file (illustrator plan)
		.clean up

	.laser cut files
		.horizontal bar plate
			.add end supports
			.add additional supports
		.main plate
			.add pen holder
			.add cable arm
			.add pulley guard
			.add bottom pulley/idler parts
			.reduce to two horizontal bar clips
			.bearing holes on vertical car.
			.horizontal car power panel mount hole

	.wiring
		x.limit switches
		.wire management

.software
	.auto format info
	.gui
		.allow config of board width/height
		.show drawing board extents in preview
		.allow scaling of preview
		.lay out gui better
		.show draw progress bar
		.accel min slider
		.accel pass slider
		.regen tool path on settings change or on button press
		.pen up / pen down buttons
		.release motors when done
		.pause / resume print
		.reset button

	.slicer
		.imporve acceleration solver
		.make it draw at 1 inch : 1 inch scale
		.allow scaling of drawing in GUI
		.arange shapes (traveling salesman?)

	.firmware
		x.implement home xy
		x.implement release motors
		.steps block, so diag 45 is not faster than up then over. this impacts acceleration, and means that when drawing a mostly vertical diag, there are little stutters when it moves left right
		.use interleave steps, higher res

.documentation
	.basic instructions and background info
	.bom
