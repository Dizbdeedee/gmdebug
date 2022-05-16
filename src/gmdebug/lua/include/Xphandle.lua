function (...)
    if not select(1,...) then error("Run failed") end
    return select(2,...)
end