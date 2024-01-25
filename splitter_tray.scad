// ------------------------------------------------------
// CATV 4-port Splitter mount v1.0
// Copyright 2024. Author: Nick Minerowicz (taclane)
// This original design is licensed under CC BY-SA 4.0 
// Attribution-ShareAlike 
//
// Remix with attribution; and feel free to send improvements 
// or comments to the github repository:
//   https://github.com/taclane/sdr-scad

// Happy Collecting! 📡


$fn = 80;

*translate([ -150 / 2, 52.3 / 2, 0 ])
rotate([ 90, 0, 0 ])
import("/Users/nick/Downloads/AtollaHub-USB.STL", center = true);

box_height = 20;
box_radius = 9;
box_length = 118;
box_width = 52;

*cylinder(h = 25, d = 6.9, center = true, $fn = 6);

difference()
{
	// build shell
	union()
	{
		// box body XX
		box_x = [ box_length / 2 - box_radius, -box_length / 2 + box_radius ];
		box_y = [ box_width / 2 - box_radius, -box_width / 2 + box_radius ];

		hull() for (x = box_x, y = box_y)
		{
			translate([ x, y, box_height / 2 ])
			cylinder(h = box_height, r = box_radius, center = true);
		}

		// ears XX
		ear_radius = 4;
		ear_length = 150;
		ear_width = 10;

		ear_x = [ ear_length / 2 - ear_radius, -ear_length / 2 + ear_radius ];
		ear_y = [ -ear_radius, -ear_width + ear_radius ];

		hull() for (x = ear_x, y = ear_y)
		{
			translate([ x, y, box_height / 2 ])
			cylinder(h = box_height, r = ear_radius, center = true);
		}

		// cube_x = [ 67, -67 ];
		// cube_y = [ 1, -11 ];

		// for (x = cube_x, y = cube_y)
		// {
		// 	translate([ x, y, box_height / 2 + 1.5 ])
		// 	cube([ 8, 2, 20 + 3 ], center = true);
		// }
	}

	// box cut XX
	wall_thick = 3.5;
	floor_thick = 3.5; // was 4

	cut_radius = box_radius - wall_thick;
	cut_length = box_length - wall_thick * 2;
	cut_width = box_width - wall_thick * 2;

	cut_x = [ cut_length / 2 - cut_radius, -cut_length / 2 + cut_radius ];
	cut_y = [ cut_width / 2 - cut_radius, -cut_width / 2 + cut_radius ];

	hull() for (x = cut_x, y = cut_y)
	{
		translate([ x, y, box_height / 2 + floor_thick ])
		cylinder(h = box_height, r = cut_radius, center = true);
	}

	// label cut XX
	label_radius = 4;
	label_length = 82;
	label_width = 26;

	label_x = [ label_length / 2 - label_radius, -label_length / 2 + label_radius ];
	label_y = [ label_width / 2 - label_radius, -label_width / 2 + label_radius ];

	hull() for (x = label_x, y = label_y)
	{
		translate([ x, y, 0 ])
		cylinder(h = box_height, r = label_radius, center = true);
	}

	// screw holes XX
	hole_x_offset = 67;
	hole_y_offset = 5;
	hole_diameter = 5;
	hole_x = [ hole_x_offset, -hole_x_offset ];
	hole_y = [-hole_y_offset];

	for (x = hole_x, y = hole_y)
	{
		// hole
		translate([ x, y, box_height / 2 ])
		cylinder(h = box_height * 2, d = hole_diameter, center = true);
		// m4 hex nut
		translate([ x, y, 0 ])
		cylinder(h = box_height, d = 6.9, center = true, $fn = 6);
	}

	// f slots XX
	slot_width = 16;
	slot_step = 0.5;
	slot_spacing = 9.6;
	slot_offset = box_width / 2;

	slots = [
		[ 0, slot_offset ], [ (-1 / 2) * (slot_spacing + slot_width), -slot_offset ], [ (-3 / 2) * (slot_spacing + slot_width), -slot_offset ],
		[ (1 / 2) * (slot_spacing + slot_width), -slot_offset ], [ (3 / 2) * (slot_spacing + slot_width), -slot_offset ]
	];

	for (slot = slots)
	{
		translate([ slot[0], slot[1], slot_width / 2 + floor_thick + slot_step ])
		{
			translate([ 0, 0, slot_width / 2 ])
			cube(slot_width, center = true);
			rotate([ 90, 0, 0 ])
			cylinder(h = slot_width, d = slot_width, center = true);
		}
	}
}

bumper_x = [16+9.6,-16-9.6];
bumper_y = [-box_width/2+8.5/2, box_width/2-8.5/2]; 

#for (x=bumper_x , y= bumper_y)
{
    translate([ x, y, box_height / 2 ])
    cube([5,3.5+5,box_height], center = true);
}

// 4x 25 mm spacing top
// 1x               bottom
// 16mm port hole
// main cavity 35x93x16.5 mm
// ears 9x28x2mm
// terminal post 8x9x10mm
// sticker cut 26x82mm
