-- 拼接短地址
local method = ngx.req.get_method()

local function createShortUri(uType, url)

	local retTable = {}
	
	
	if uType == 'ever' then
		sIndexKey = sIndexKeyEver
		connector = "_"
	end 
	
	if uType == 'temp' then
		sIndexKey = sIndexKeyTemp
		connector = ""
	end
	
	local sIndex, _  = red:incr(sIndexKey)
	if not sIndex then 
		red:set(sIndexKey, 1)
	end
	
	ngx.log(ngx.ERR, sIndex )

	local dec62 = ConvertDec2X(sIndex,62)

	if uType == 'temp' then
		if sIndex > sIndexMax then
			red:set(sIndexKey,1)
			dec62 = ConvertDec2X(1,62)
		end
	
		-- 62进制转换
		if string.len(dec62) > maxSurlLen then 
			red:set(sIndexKey, 1)
			dec62 = ConvertDec2X(1,62)
		end
	end


	local res, err = red:set("SURL:/".. connector .. dec62, url)
	if not res then 
		local dataTable = {}
		msg = "add sUrl failed"
		Response(1, msg , dataTable)
	end

	return connector .. dec62

end


-- 获取request_body参数
local function parseArgsFromRequestBody()
	ngx.req.read_body()
	url = ngx.req.get_post_args()["url"] or ""
	sUrl = ngx.req.get_post_args()["sUrl"] or ""
	uType = ngx.req.get_post_args()["uType"] or ""
	return url, sUrl, uType
	
end

-- Response 超简易封装
local function Response(code,msg,dataTable)
	local retTable = {}
	retTable["code"]= code
	retTable["data"]= dataTable
	retTable["msg"]= msg
	retTable["ts"]= ngx.now()*1000
	
	ret = cjson.encode(retTable);
	res = string.gsub(ret, "\\","")
	ngx.say(res)
	ngx.exit(200)
	
end

-- 获取原地址
local function getOriginUrl(sUrl)

	url, _ = red:get("SURL:".. sUrl)
	
	return url
	
end


-- 修改原地址
local function updateOriginUrlBySUrl(url, sUrl) 
	
	res = red:set("SURL:".. sUrl, url)
	return res
	
end


-- 签名认证
local function checkSignature() 
	local retTable = {}
	ngx.req.read_body()
	requestBody = ngx.req.get_body_data()
	index = string.find(requestBody, "&sign=", 1)
	if index == nil then
		msg = "have to be signed"
		Response(5, msg, retTable)
	end
	preSignBody=string.sub(requestBody,0,index-1)
	preSign=string.sub(requestBody,index+6,-1)
	
	sign = md5.sumhexa(preSignBody..signSalt)
	
	if sign == preSign then 
		return
	else
		msg = "sign failed"
		Response(6, msg, retTable)
	end
	
	return 
end

if method ~= "POST" then
	ngx.say("Method not allowed")
	ngx.exit(405)
end

isSignRequired = ngx.req.get_headers()["SignRequired"]
if isSignRequired == "1" then
	checkSignature()
end

red = rc.newRedisConn(redisSockFile)
local retTable = {}

if not red then 
	msg = "get redis connetion failed"
	Response(4, msg, retTable) 
end 



-- Post controller
if ngx.var.uri == "/shorturl/add" then

	-- 拼接短地址
	url, _, uType = parseArgsFromRequestBody()
	
	if url == nil or url == ""  or uType == "" or uType == nil then
		msg = "url, uType are all required"
		Response(8, msg,retTable)
	end
	
	
	sUrl = shortDomain .. "/" .. createShortUri(uType, url)
	
	if sUrl then 
		retTable["sUrl"] = sUrl
		msg = "success"
		Response(0, msg,retTable)
	end
end

-- Get controller
if ngx.var.uri == "/shorturl/get" then 
	_, sUrl, _  = parseArgsFromRequestBody()
	
	if sUrl == nil or sUrl == "" then
		msg = "sUrl is required"
		Response(10, msg,retTable)
	end
	
	url = getOriginUrl(sUrl)
	
	retTable["url"] = url
	msg = "success"
	Response(0, msg, retTable)
	
end

-- Put controller
if ngx.var.uri == "/shorturl/update" then

	url, sUrl, _ = parseArgsFromRequestBody()
	
	if url == nil or url == "" or sUrl == nil or sUrl == "" then
		msg = "url, sUrl, uType are all required"
		Response(9, msg,retTable)
	end
		
	ok = updateOriginUrlBySUrl(url, sUrl)
	
	if ok ~= "OK" then 
		msg = "update origin url failed"
		Response(2, msg,retTable)
	else 
		msg = "success"
		Response(0, msg, retTable)
	end
	
end
	
