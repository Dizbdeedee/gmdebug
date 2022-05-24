function (...)
    {0}.xpCallActive = false
    local pass = select(1,...)
    if pass then
        return select(2,...)
    else
        error("Error")
    end
end