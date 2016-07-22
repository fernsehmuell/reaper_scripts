-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

function main()
    reaper.Undo_BeginBlock()
        in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) --get start and end point
        reaper.Main_OnCommand(40635,0) -- Time selection: Remove time selection (40635)
        reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", out_pos) -- store outpoint in datastore
        reaper.SetProjExtState(0, "Fernsehmuell", "StartpointIsZero", "") -- clear IN-Point is Zero datastore Value
        
        retval, marker_count, regions_count = reaper.CountProjectMarkers(0) -- get number of markers
        for i=marker_count-1,0,-1 do -- count backwards, so numbering of markers does not change!
            index, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, i) -- get name of marker i
            if name == " [ in" then
                reaper.DeleteProjectMarkerByIndex(0, index-1) -- delete marker if it is an IN marker
            end
        end
    reaper.Undo_EndBlock("Clear IN marks (fernsehmuell script)", -1)
end

main()
