# QLED
Control LED Tape through an Arduino, QLab, and MIDI

## Usage:
* Open QLED. It lives in the menu bar.
* In QLab Preferences, select QLED as the MIDI Patch.
* Add a MIDI note control cue in QLab
  * CHANNEL represents the channel of LED Tape (1 or 2)
  * CONTROL NUMBER represents the color (RGB) to be chaned. R=0, G=1, B=2
  * CONTROL VALUE represents the intensity (0-100) of the color.


## Technical Notes:
* A two-byte array is written to the Aruino, with the first value representing the color to change, and the second representing the intensity of the color.
* The USB port written to (tape channel) is controlled internally.
