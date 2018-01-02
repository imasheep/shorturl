-- 拼接短地址
local function createShorturi(url)

	local sIndex, err = red:incr(sIndexKey)
	if not sIndex then 
		red:set(sIndexKey, 1)
	end

	-- 62进制转换
	local dec62 = ConvertDec2X(sIndex,62)
	if string.len(dec62) > maxSurlLen then 
		red:set(sIndexKey, 1)
		dec62 = ConvertDec2X(1,62)
	end
		

	local res, err = red:set("/"..dec62, url)
	if not res then 
		Response(1, "null" )
	end

	return dec62

end


-- 获得post参数里的url
local function getUrl()
	local request_method = ngx.var.request_method
	if request_method == "POST" then
		ngx.req.read_body()
		url = ngx.req.get_post_args()["url"] or ""
	end
	return url
end


local function Response(code, sUrl)
	ngx.say("{\"code\":"..code..",\"sUrl\":\""..sUrl.."\"}")
	ngx.exit(200)
end


red = rc.newRedisConn(redisSockFile)
if not red then Response(2, "null") end 

-- 拼接短地址
shorturl = shortDomain .. "/".. createShorturi(getUrl)

if shorturl then 
	Response(0, shorturl)
end








