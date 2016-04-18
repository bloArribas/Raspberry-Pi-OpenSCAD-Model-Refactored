use <pin_headers.scad>;

WIDTH = 56;
LENGTH = 85;
HEIGHT = 1.5;
SPACER = 2.05;
GROUP_SPACER = 2.9;

RIGHT = [90,0,0];
LEFT = [-90,0,0];
TILT = [0,0,180];

ARRAY_BASE_CORRECTION = -1;
FINE = 0.5;
ULTRA_FINE = .1;
       
METALLIC="silver";
CHROME = [.9,.9,.9];
BLUE = [.4,.4,.95];
DARK_BLUE = [.2,.2,.7];
BLACK = [0,0,0];
DARK_GREEN = [0.2,0.5,0];
RED = [0.9,0.1,0,0.6];
DARK_RED = [1.0,1.6,0.7];

ETHERNET_LENGTH = 21.2;
ETHERNET_WIDTH = 16;
ETHERNET_HEIGHT = 13.3;

ETHERNET_DIMENSIONS = [ETHERNET_LENGTH, ETHERNET_WIDTH, ETHERNET_HEIGHT];

USB_LENGTH = 17.3;
USB_DIMENSIONS = [USB_LENGTH,13.3,16];

function position_x(ledge, port_length) = LENGTH - port_length + ledge;

module ethernet_port()
	{

    ledge = 1.2;
    pcb_margin = 1.5;  
    position = [position_x(ledge, ETHERNET_LENGTH), pcb_margin, HEIGHT];
        
	color(METALLIC)
        translate(position) 
            cube(ETHERNET_DIMENSIONS); 
	}

module usb_port ()
	{
    ledge = 8.5;
    position_y = 25;

	color(METALLIC)
        translate([position_x(ledge, USB_LENGTH), position_y, HEIGHT]) 
            cube(USB_DIMENSIONS);
	}
    
module composite_block ()
    {
        color("yellow")
            cube([10,10,13]);
    }
    
module composite_jack()
   {   
       translate([5,19,8])
            rotate(RIGHT)
                color(CHROME)
                    cylinder(h = 9.3, r = 4.15, $fs=FINE);
   } 

module composite_port ()
	{
    pcb_margin = 12;
    position_x = 41.4; 
    position_y = WIDTH - pcb_margin;
        
	translate([position_x, position_y, HEIGHT])
		{
		composite_block();

		composite_jack();
		}
	}
    
function half(dimension) = dimension / 2;
function radius(diameter) = half(diameter);
    
module audio_block()
    {
    length = 12.1;
    width = 11.5;
    height = 10.1;
    dimensions = [length, width, height];    
           
        color(BLUE)
            cube(dimensions);

    }

module audio_connector()
    {        
    diameter = 6.7;
    radius = radius(diameter);
        
    block_length = 12.1;
    block_width = 11.5;
    block_height = 10.1;
        
    position_jack = [ half(block_length) , block_width, block_height - radius ];
        
    translate(position_jack)
        rotate(LEFT)
            color(BLUE)
                cylinder(h = 3.5, r = radius, $fs= FINE);
    }


module audio_jack ()
	{        
    position = [ 59, 44.5, HEIGHT];
        
	translate(position)
		{ 
        audio_connector();    
        audio_block();
		}
	}


module gpio ()
	{
    position_x = -1;
    position_y = -WIDTH+6;
    position = [ position_x, position_y, HEIGHT]; 
        
	rotate(TILT)
        translate(position)
            off_pin_header(rows = 13, cols = 2);
	}

module hdmi ()
	{
    position_x = 37.1;
    position_y = -1;
    position = [ position_x, position_y, HEIGHT];    
        
    dimensions = [15.1,11.7,8-HEIGHT];
        
	color (METALLIC)
        translate (position)
            cube(dimensions);
	}

module power ()
	{
    position_x = -0.8;
    position_y = 3.8;
    position = [ position_x, position_y, HEIGHT];    
        
    dimensions = [ 5.6, 8, 4.4-HEIGHT];
        
	color(METALLIC)
        translate (position)
            cube ([5.6, 8,4.4-HEIGHT]);
	}
    
module sd_slot()
    {
    position_x = 0.9;
    position_y = 15.2;
    position = [ position_x, position_y, -5.2 + HEIGHT];    
        
    dimensions = [16.8, 28.5, 5.2-HEIGHT];
        
    color (BLACK)
        translate (position)
           cube (dimensions);
    }
    
module sd_card()
    {
    position = [-17.3,17.7,-2.9];    
        
    dimensions = [32, 24, 2];

	color (DARK_BLUE)
        translate (position)
            cube (dimensions);
    }

module sd ()
	{
	sd_slot();
    sd_card();
	}
    
function twenty_percent(value) = value * .2;    

module mhole ()
	{
	cylinder (r=1.5, h=HEIGHT+ twenty_percent(HEIGHT), $fs=ULTRA_FINE);
	}
    
module integrated_circuit () {
    color(DARK_GREEN)
        linear_extrude(height = HEIGHT)
            square([LENGTH,WIDTH]);

}

module holes(){
    positions = [[25.5, 18,-0.1], [LENGTH-5, WIDTH-12.5, -0.1]];
    
    number_of_holes = len(positions);
    
    for(i = [0: number_of_holes - ARRAY_BASE_CORRECTION]){
        translate( positions[i])
            mhole();
    }
}

module pcb ()
	{
		difference ()
		{
            integrated_circuit ();
            holes(); 
		}
	}
    
    
module positioned_led(position_x){
    position_y = WIDTH - 7.55;
    dimensions = [1.0, 1.6, 0.7];
    
    translate([position_x, position_y, HEIGHT]) 
            color(RED)
                cube(dimensions);
}

module led_group(position_x, size){
    position = position_x - SPACER;
    for (i = [1:size]){
        positioned_led(position + (SPACER * i));
    }

}

module leds()
	{        
        position_x = LENGTH - 11.5;
        second_x_position = position_x + SPACER + GROUP_SPACER;
        
		led_group(position_x, 2);
        led_group(second_x_position, 3);
	}

module rpi ()
	{
		pcb ();
		ethernet_port ();
		usb_port (); 
		composite_port (); 
		audio_jack (); 
		gpio (); 
		hdmi ();
		power ();
		sd ();
		leds ();
	}

rpi (); 