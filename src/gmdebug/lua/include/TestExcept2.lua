function (...) 
    if not {3}.xpCallActive then
        return {2}(xpcall({0},{1},...)))
    else
        return {0}(...)
    end
end