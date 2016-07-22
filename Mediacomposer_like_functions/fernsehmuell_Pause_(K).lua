reaper.Main_OnCommand(1008,0) --pause
reaper.Main_OnCommand(1016,0) --stop
reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 0) -- store state in datastore
reaper.Main_OnCommand(40521, 0) -- set play speed to 1
