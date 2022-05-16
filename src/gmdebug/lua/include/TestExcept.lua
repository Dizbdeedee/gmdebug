function (...) 
    if not {3}.xpCallActive then
        {3}.xpCallActive = true
        local noReturns,success,vrtn,vrtn2,vrtn3,vrtn4,vrtn5,vrtn6 = {2}(xpcall({0},{1},...))
        {3}.xpCallActive = false
        if success then
            if noReturns == 1 then return nil end
            if noReturns == 2 then return vrtn end
            if noReturns == 3 then return vrtn,vrtn2 end 
            if noReturns == 4 then return vrtn,vrtn2,vrtn3 end
            if noReturns == 5 then return vrtn,vrtn2,vrtn3,vrtn4 end
            if noReturns == 6 then return vrtn,vrtn2,vrtn3,vrtn4,vrtn5 end
            if noReturns == 7 then return vrtn,vrtn2,vrtn3,vrtn4,vrtn5,vrtn6 end
        else 
            print("error") error("nope") 
        end 
    else
        return {0}(...)
    end
end