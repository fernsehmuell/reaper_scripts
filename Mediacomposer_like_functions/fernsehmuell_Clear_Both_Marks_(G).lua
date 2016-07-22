-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

function clear_all_in_and_out_markers()
    retval, marker_count, regions_count = reaper.CountProjectMarkers(0) -- get number of markers
    for i=marker_count-1,0,-1 do -- count backwards, so numbering of markers does not change!
        index, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, i) -- get name of marker i
        if name == " [ in" or name == " out ]" then
            reaper.DeleteProjectMarkerByIndex(0, index-1) -- delete marker if it is a IN or OUT marker
        end
    end
end

function there_are_in_and_out_points()
    in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) --get start and end point
    retval, isstartpointzero = reaper.GetProjExtState(0, "Fernsehmuell", "StartpointIsZero") --check if there is an OUT-Point in the datastore
    if isstartpointzero~="" then
        if isstartpointzero=="True" then
            in_pos=0
        end
    end
    retval, out_before_in = reaper.GetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point") --check if there is an OUT-Point in the datastore
    if (out_before_in ~= "") then out_pos=tonumber(out_before_in) end -- if there is an OUT in the datastore, then use that one
    if out_pos==in_pos and out_pos>0 then out_pos=out_pos+1 end -- if IN and OUT are on the end we need this hack
    if in_pos==0 and out_pos==0 then out_pos=1 end
    return in_pos~=out_pos
end  

function main()
    reaper.Undo_BeginBlock()
        if reaper.GetPlayState()==1 then --stop as mediacomposer does (do we need that?)
            reaper.Main_OnCommand(1008,0)
            reaper.Main_OnCommand(1016,0)
        end
        
        reaper.Main_OnCommand(40635,0) -- Time selection: Remove time selection (40635)
        reaper.SetProjExtState(0, "Fernsehmuell", "StartpointIsZero", "False") -- clear IN-Point is Zero datastore value
        reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", "") -- clear OUT-Point datastore value
        clear_all_in_and_out_markers()
    reaper.Undo_EndBlock("Clear both marks (fernsehmuell script)", -1)
end

if there_are_in_and_out_points() then
    main()
end
