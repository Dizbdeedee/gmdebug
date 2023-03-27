function (...)
    if not {3}.xpCallActive then
        {3}.xpCallActive = true
        return {2}(xpcall({0},{1},...))
    else
        return {0}(...)
    end
end