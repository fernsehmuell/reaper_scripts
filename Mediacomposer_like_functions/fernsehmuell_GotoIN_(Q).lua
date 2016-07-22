function main()
    playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec
    if playstate==1 then reaper.Main_OnCommand(1016,0) end --stop as mediacomposer does (do we need that?)
    
    in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) -- get start and end point
    
    if (in_pos==0.0 and out_pos==0.0) then -- no start point set, OR startpoint is 0.0 -> goto start like avid MC
        reaper.Main_OnCommand(40042,0) --Transport: Go to start of project (40042)
    else
        if (in_pos~=out_pos) then -- start and end point are set
            reaper.Main_OnCommand(40630,0) --Go to start of time selection
        else
            actpos=reaper.GetCursorPosition()
            reaper.MoveEditCursor(in_pos-actpos, 0)
        end
    end
end

reaper.defer(main) -- run without generating an undo point

