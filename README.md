# Fernsehmüll Reaper Scripts
Collection of my Reaper Scripts

## Avid Media Composer like keyboard functions
### IN and OUT Marks
* SetIN_(i): Sets IN mark at cursor position
* SetOUT_(O): Sets OUT mark at cursor position 
* MarkClip_(T): Mark clip/region in selected Tracks, if no track is selected use all tracks
* GotoIN_(Q): Goto IN mark
* GotoOUT_(W): Goto OUT mark
* Clear_Both_Marks_(G): Clear IN and OUT mark
* Clear_IN_Marks_(D): Clear IN mark
* Clear_OUT_Marks_(F): Clear OUT mark

###Edit
* Extract_(X): Extract time selection on selected tracks
* Lift_(Y): Lift time selection on selected tracks

###Navigate
* Reverse_Play_Shuttle_(J): Move cursor backwards, press multiple times to increase speed
* Reverse_Play_Shuttle_Background: Background function used by Reverse_Play_Shuttle_(J) (dont' rename this file!) 
* Pause_(K): Pause
* Forward_Play_Shuttle_(L): Play forwards, press multiple times to increase speed

##Installation
Copy the .lua files to your Reaper scripts directory or any other directory you like. In Reaper choose Actions/Show actions list...
Press the "Load..." button on the lower right side. Select all of the fernsehmuell_ scripts and press Open/Enter.
You can find the scripts in the action list under: Script: fernsehmuell_... Now assign Keyboardshortcuts to each script ("Add..." button)
The recommended key is the letter in () at the end of the filename.
