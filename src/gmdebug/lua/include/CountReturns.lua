function (...)
    local noReturns = select("#",...)
    return noReturns,...
end