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
* Add_Edit_(S): like the Reaper Split function, but this does not split locked items. And it does not mark any items. (you can change this behavior by changing to variables in the script)
* Extract_(X): Extract time selection on selected tracks
* Lift_(Y): Lift time selection on selected tracks

###Navigate
* Reverse_Play_Shuttle_(J): Move cursor backwards, press multiple times to increase speed
* Reverse_Play_Shuttle_Background: Background function used by Reverse_Play_Shuttle_(J) (don't rename this file!) 
* Pause_(K): Pause
* Forward_Play_Shuttle_(L): Play forwards, press multiple times to increase speed
* Step_backwards_40ms_(3): Step backwards 40ms (1 video frame @25fps)
* Step_backwards_400ms_(1): Step backwards 400ms (10 video frames @25fps)
* Step_forwards_40ms_(4): Step forwards 40ms (1 video frame @25fps)
* Step_backwards_400ms_(2): Step forwards 400ms (10 video frame @25fps)
* Go_to_next_event: Move cursor to next event in selected tracks. If no track is selected move to next event in all tracks
* Go_to_prev_event: Move cursor to previous event in selected tracks. If no track is selected move to previous event in all tracks


##Installation
Copy the .lua files to your Reaper scripts directory or any other directory you like. In Reaper choose Actions/Show actions list...
Press the "Load..." button on the lower right side. Select all of the fernsehmuell_ scripts and press Open/Enter.
You can find the scripts in the action list under: Script: fernsehmuell_... Now assign Keyboardshortcuts to each script ("Add..." button)
The recommended key is the letter in () at the end of the filename.
If you use the Forward_Play_Shuttle_(L) for the first time a "ReaScript task control" window pops up. Check the checkbox and press "New instance"
