#!/bin/sh

xinput --list short
#â¡ Virtual core pointer                    	id=2	[master pointer  (3)]
#â   â³ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
#â   â³ Cypress USB Keyboard                    	id=9	[slave  pointer  (2)]
#â   â³ Logitech USB Receiver                   	id=10	[slave  pointer  (2)]

xinput --list-props 11

#Device 'Logitech USB Receiver':
#	Device Enabled (152):	1
#	Coordinate Transformation Matrix (154):	1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000
#	Device Accel Profile (278):	0
#	Device Accel Constant Deceleration (279):	1.000000
#	Device Accel Adaptive Deceleration (280):	1.000000
#	Device Accel Velocity Scaling (281):	10.000000
#	Device Product ID (272):	1133, 50433
#	Device Node (273):	"/dev/input/event13"
#	Evdev Axis Inversion (282):	0, 0
#	Evdev Axes Swap (284):	0
#	Axis Labels (285):	"Rel X" (162), "Rel Y" (163), "Rel Vert Wheel" (303)
#	Button Labels (286):	"Button Left" (155), "Button Middle" (156), "Button Right" (157), "Button Wheel Up" (158), "Button Wheel Down" (159), "Button Horiz Wheel Left" (160), "Button Horiz Wheel Right" (161), "Button Side" (301), "Button Extra" (302), "Button Unknown" (275), "Button Unknown" (275), "Button Unknown" (275), "Button Unknown" (275)
#	Evdev Scrolling Distance (287):	1, 1, 1
#	Evdev Middle Button Emulation (288):	0
#	Evdev Middle Button Timeout (289):	50
#	Evdev Middle Button Button (290):	2
#	Evdev Third Button Emulation (291):	0
#	Evdev Third Button Emulation Timeout (292):	1000
#	Evdev Third Button Emulation Button (293):	3
#	Evdev Third Button Emulation Threshold (294):	20
#	Evdev Wheel Emulation (295):	0
#	Evdev Wheel Emulation Axes (296):	0, 0, 4, 5
#	Evdev Wheel Emulation Inertia (297):	10
#	Evdev Wheel Emulation Timeout (298):	200
#	Evdev Wheel Emulation Button (299):	4
#	Evdev Drag Lock Buttons (300):	0

# enable wheel emulation setting to button 8
xinput -set-prop 11 295 1
xinput -set-prop 11 299 8

# accelarate mouse movements
xinput --set-prop 11 278 3
xinput --set-prop 11 279 0.8

