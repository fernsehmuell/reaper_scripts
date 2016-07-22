-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

function clear_all_out_markers()
    retval, marker_count, regions_count = reaper.CountProjectMarkers(0) -- get number of markers
    for i=marker_count-1,0,-1 do -- count backwards, so numbering of markers does not change!
        index, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, i) -- get name of marker i
        if name == " out ]" then
            reaper.DeleteProjectMarkerByIndex(0, index-1) -- delete marker if it is an OUT marker
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
    retval, value = reaper.GetProjExtState(0, "Fernsehmuell", "StartpointIsZero") -- check if IN point is set and =zero
    in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) --get start and end  point
    
    if ((in_pos>0) or (value=="True")) and in_pos<position then
        reaper.Main_OnCommand(40626,0) -- Time selection: Set end point (40626)
        reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", "") -- clear datastore Value
    else -- out point is before IN Point or there is no IN-Point
        reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", position) -- store outpoint in datastore
        retval, retval2 = reaper.GetSet_LoopTimeRange(1,0,in_pos,in_pos,0) -- clear OUT (set it to value of IN)
    end
    
    clear_all_out_markers()    
    reaper.AddProjectMarker2(0, false, position, 0, " out ]", 0, 0xFFFF00|0x1000000) -- set marker
    reaper.Undo_EndBlock("Set OUT (fernsehmuell script)", -1)
end

main()
