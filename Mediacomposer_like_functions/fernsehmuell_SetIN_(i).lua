-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

function clear_all_in_markers()
    retval, marker_count, regions_count = reaper.CountProjectMarkers(0) -- get number of markers
    for i=marker_count-1,0,-1 do -- count backwards, so numbering of markers does not change!
        index, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, i) -- get name of marker i
        if name == " [ in" then
            reaper.DeleteProjectMarkerByIndex(0, index-1) -- delete marker if it is an IN marker
        end
    end
end

function get_position()
    playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec possible to combine bits
    if playstate==1 or playstate==4 then
        return reaper.GetPlayPosition()
    else
        return reaper.GetCursorPosition()
    end
end

function main()
    reaper.Undo_BeginBlock()
        position=get_position()
        if position==0 then
            reaper.SetProjExtState(0, "Fernsehmuell", "StartpointIsZero", "True") -- Set IN-Point is Zero datastore value
        end    
        in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) --get start and end point
        retval, out_before_in = reaper.GetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point") --check if there is an OUT-Point in the datastore
        
        if (out_before_in ~= "") then out_pos=tonumber(out_before_in) end -- if there is an OUT in the datastore, then use that one
        
        if (out_pos>position) then
            reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", "") -- clear datastore Value
            retval, retval2 = reaper.GetSet_LoopTimeRange(1,0,position,out_pos,0)
        else
            reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", out_pos)
            retval, retval2 = reaper.GetSet_LoopTimeRange(1,0,position,position,0)
        end
        clear_all_in_markers()
        reaper.AddProjectMarker2(0, false, position, 0, " [ in", 0, 0xFFFF00|0x1000000) -- set marker
    reaper.Undo_EndBlock("Set IN (fernsehmuell script)", -1)
end

main()
