local redis = require ("redis")

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 1)

function _M.newRedisConn(redisSockFile)

    local sock_file = redisSockFile
    local red = redis:new()

    red:set_timeout(3000)

    -- 失败重连
    for con_count = 1, 3 do
        local ok, err = red:connect("unix:".. sock_file)
        if ok then
            return red
        end
        ngx.log(ngx.ERR, "Connect redis unix:" .. sock_file ..  ". failed: " .. err .. ", trycount: " .. con_count)
    end
    return nil
end


return _M