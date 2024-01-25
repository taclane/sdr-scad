// ------------------------------------------------------
// SDR Brace for USB Hubs v1.0
// Copyright 2024. Author: Nick Minerowicz (taclane)
// This original design is licensed under CC BY-SA 4.0 
// Attribution-ShareAlike 
//
// Remix with attribution; and feel free to send improvements 
// or comments to the github repository:
//   https://github.com/taclane/sdr-scad

// Happy Collecting! 📡

// ------------------------------------------------------
// Customizer
// ------------------------------------------------------
/* [Config] */

// SDR Type
sdr_type = "SDR-Blog v3/v4"; //[SDR-Blog v3/v4, Nooelec NESDR v4/v5]

// USB Hub
hub_type = "Atolla (17mm)"; //["Atolla (17mm)", "StarTech (12mm X 2)", "Custom"]

// Horizontal or Vertical
orientation = "-V"; // ["-V":"Vertical", "-H":"Horizontal"]

// Number of SDRs
sdr_num = 4; // [1:10]

// How much to shrink the bit to compensate for FDM printing? (mm)
// fdm_comp = 0.0; // 0.01

// Cut notches for zipties/rubber bands?
notch = false; //[true, false]

// Rings only (no end plate)
rings_only = false; //[true, false]

// Custom Port-to-port measurement (mm)
hub_spacing = 17.0; // [0:0.01:50]

// Height of brace (mm)
print_height = 8;

// ------------------------------------------------------
// Data Tables
// ------------------------------------------------------
/* [Hidden] */

sdr_dimensions = [
	// id, s_length, s_width, s_maxwidth, corner, bulge, s_depth
	[ "SDR-Blog v3/v4-V", [ 27.15, 12.2, 13, 3, 3, 0.8 ] ],
    [ "SDR-Blog v3/v4-H", [ 12.2, 27.15, 13, 3, 0, 0.8 ] ],
	[ "Nooelec NESDR v4/v5-V", [ 17.0, 14.2, 14.2, 1, 0, 0 ] ],
    [ "Nooelec NESDR v4/v5-H", [ 14.2, 17.0, 14.2, 1, 0, 0 ] ],
];

hub_dimensions = [
    ["Atolla (17mm)", 17],
    ["StarTech (12mm X 2)", 24],
    ["Custom", hub_spacing]
];

key = search([str(sdr_type, orientation)], sdr_dimensions)[0];
sdr_data = sdr_dimensions[key][1];

hubkey = search([hub_type], hub_dimensions)[0];
port_spacing = hub_dimensions[hubkey][1];

cap_width = port_spacing * sdr_num;


// width of sdr device + border
cap_depth = sdr_data[0] + 3;
echo(sdr_data);

// hight of print
cap_height = print_height;

// ------------------------------------------------------
// START
// ------------------------------------------------------

module sdr_hull(width, depth)
{
	// build the end cap
	xcyl = 4;
	xcoords = [ 0 + xcyl / 2, width - xcyl / 2 ];
	ycoords = [ depth / 2 - xcyl / 2, -depth / 2 + xcyl / 2 ];

	hull()
	{
		for (x = xcoords, y = ycoords)
		{
			translate([ x, y, 0 ])
			cylinder(d = xcyl, h = cap_height, $fn = 32);
		}
	}
}

module sdr_cut(sdr_data)
{
	// srdblog
	//  27mm x (13mm (center), 12mm (end))
	//  center hole offset 7mm

	s_length = sdr_data[0];   // 27.5;
	s_width = sdr_data[1];    // 12.2; //12
	s_maxwidth = sdr_data[2]; // 13.2;  //13

	// unit has 3mm diameter screws on corners
	s_rounded = sdr_data[3];

	// bulge
	s_bulge = sdr_data[4];

	// screw depth cut
	s_screw = sdr_data[5];

	union()
	{
		// SDR Body
		hull()
		{
			// Rounded rectangle
			xcoords = [ s_width / 2 - s_rounded / 2, -s_width / 2 + s_rounded / 2 ];
			ycoords = [ s_length / 2 - s_rounded / 2, -s_length / 2 + s_rounded / 2 ];

			for (x = xcoords, y = ycoords)
			{
				translate([ x, y, 0 ])
				cylinder(d = s_rounded, h = cap_height * 2, $fn = 32);
			}

			// Slight curve in center of device?
			translate([ 0, s_bulge, 0 ])
			cylinder(d = s_maxwidth, h = cap_height * 2, $fn = 32);

			translate([ 0, -s_bulge, 0 ])
			cylinder(d = s_maxwidth, h = cap_height * 2, $fn = 32);
		};

		// Screw Cutouts
		hull()
		{
			xcoords = [ s_width / 2 - s_rounded / 2, -s_width / 2 + s_rounded / 2 ];
			ycoords = [ s_length / 2 - s_rounded / 2, s_length / 2 - s_rounded / 2 - 1 ];

			for (x = xcoords, y = ycoords)
			{
				translate([ x, y, -s_screw ])
				cylinder(d = s_rounded, h = cap_height * 2, $fn = 32);
			}
		}

		hull()
		{
			xcoords = [ s_width / 2 - s_rounded / 2, -s_width / 2 + s_rounded / 2 ];
			ycoords = [ -s_length / 2 + s_rounded / 2, -s_length / 2 + s_rounded / 2 + 1 ];

			for (x = xcoords, y = ycoords)
			{
				translate([ x, y, -s_screw ])
				cylinder(d = s_rounded, h = cap_height * 2, $fn = 32);
			}
		}

		// USB/SMA cutout
		cylinder(d = s_maxwidth, h = cap_height * 2, center = true, $fn = 64);
	}
}

module zip_notch(depth)
{
	// 7mm rounded cut
	notch = 7;
	difference()
	{
		union()
		{
			cube(notch, center = true);

			translate([ 0, -depth, 0 ])
			cube(notch, center = true);
		}

		for (y = [ -notch / 2, -depth + notch / 2 ])
		{
			translate([ 0, y, notch / 2 ])
			rotate([ 0, 90, 0 ])
			cylinder(h = 2 * notch, d = notch, center = true, $fn = 32);
		}
	}
}

difference()
{
	sdr_hull(cap_width, cap_depth);

	cutmod = rings_only ? -1 : 1;

	for (i = [1:sdr_num])
	{
		echo(i);
		translate([ port_spacing * i - port_spacing / 2 , 0, cutmod * 2 ])
		sdr_cut(sdr_data);
	}

	if (notch)
	{
		for (i = [0:sdr_num - 1])
		{
			if (i > 0)
			{
				translate([ port_spacing * i, cap_depth / 2, 0 ])
				zip_notch(cap_depth);
			}
		}
	}
}
