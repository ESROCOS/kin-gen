local M = {}

M.write_out_file = function(path, filename, res)
    local fd = io.open(path..filename,'w')
    fd:write(res)
    fd:close()
end


--- helper, print a bright red errormsg
M.errmsg = function(...)
   print(ansicolors.bright(ansicolors.red(table.concat({...}, ' '))))
end

--- helper, print a yellow warning msg
M.warnmsg = function(...)
   print(ansicolors.yellow(table.concat({...}, ' ')))
end

--- helper, print a green sucess msg
M.succmsg = function(...)
   print(ansicolors.green(table.concat({...}, ' ')))
end


return M