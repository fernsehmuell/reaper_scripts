function goto_in()
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

function main()
    reaper.Undo_BeginBlock()
        toggle_state=reaper.GetToggleCommandState(40311)
        toggle_state_one=reaper.GetToggleCommandState(40310)
        reaper.Main_OnCommand(40309,0) -- Set ripple editing off
        reaper.Main_OnCommand(40289,0) -- unselect all items
        reaper.Main_OnCommand(40718,0) -- Item: Select all items on selected tracks in current time selection
        if reaper.CountSelectedMediaItems(0) > 0 then
            reaper.Main_OnCommand(40312,0) -- Item: Remove selected area of items
        end
    
        if toggle_state==1 then
            reaper.Main_OnCommand(40311,0) -- Set ripple editing all tracks
        elseif toggle_state_one==1 then
            reaper.Main_OnCommand(40310,0) -- Set ripple editing on selected tracks
        end
        reaper.Main_OnCommand(40289,0) -- unselect all items
        goto_in()
    reaper.Undo_EndBlock("Lift (fernsehmuell script)", -1)
end

main()
