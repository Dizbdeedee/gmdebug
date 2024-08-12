function (func, usrCallback, ...)
   -- if not {0}.xpCallActive then
   --    {0}.xpCallActive = true
   local function totalBack(err)
      print("IN TOTAL BACK")
      {1}(err, 1)
      usrCallback(err)
   end
   return {2}(func, totalBack, ...)
   -- else
   --    return {2}(func, usrCallback, ...)
   -- end
end
