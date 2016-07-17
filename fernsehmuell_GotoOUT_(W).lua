function main()
    playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec
    if playstate==1 then reaper.Main_OnCommand(1016,0) end --stop as mediacomposer does (do we need that?)
    
    in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) --get start and end point
    retval, out_before_in = reaper.GetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point") --check if there is an OUT-Point in the datastore
    
    if (in_pos~=out_pos) then -- there is a "normal" OUT point
        reaper.MoveEditCursor(out_pos-reaper.GetCursorPosition(), 0)
    elseif (out_before_in ~= "") then -- there is a stored OUT point
        reaper.MoveEditCursor(tonumber(out_before_in)-reaper.GetCursorPosition(), 0)
    else
        reaper.Main_OnCommand(40043,0) --there is no outpoint just go to the end
    end
end

reaper.defer(main) -- run without generating an undo point
