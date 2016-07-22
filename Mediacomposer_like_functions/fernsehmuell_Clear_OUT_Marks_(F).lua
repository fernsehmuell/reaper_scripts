-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

function main()
    reaper.Undo_BeginBlock()
        in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) --get start and end point
        reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", "") -- clear OUT-Point datastore Value
        retval, retval2 = reaper.GetSet_LoopTimeRange(1,0,in_pos,in_pos,0) -- clear out (set to same position as in point)
        
        retval, marker_count, regions_count = reaper.CountProjectMarkers(0) -- get number of markers
        for i=marker_count-1,0,-1 do -- count backwards, so numbering of markers does not change!
            index, isrgn, pos, rgnend, name, mindex = reaper.EnumProjectMarkers2(NULL, i) -- get name of marker i
                if name == " out ]" then
                  reaper.DeleteProjectMarkerByIndex(0, index-1) -- delete marker if it is an OUT marker
            end
        end
    reaper.Undo_EndBlock("Clear OUT marks (fernsehmuell script)", -1)
end

main()
