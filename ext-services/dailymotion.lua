local oop = medialib.load("oop")

local DailyMotionService = oop.class("DailyMotionService", "HTMLService")

local all_patterns = {
	"https?://www.dailymotion.com/video/([A-Za-z0-9_%-]+)",
	"https?://dailymotion.com/video/([A-Za-z0-9_%-]+)"
}

function DailyMotionService:parseUrl(url)
	for _,pattern in pairs(all_patterns) do
		local id = string.match(url, pattern)
		if id then
			return {id = id}
		end
	end
end

function DailyMotionService:isValidUrl(url)
	return self:parseUrl(url) ~= nil
end

local player_url = "http://wyozi.github.io/gmod-medialib/dailymotion.html?id=%s"
function DailyMotionService:resolveUrl(url, callback)
	local urlData = self:parseUrl(url)
	local playerUrl = string.format(player_url, urlData.id)

	callback(playerUrl, {start = urlData.start})
end

-- https://api.dailymotion.com/video/x2isgrj_if-frank-underwood-was-your-coworker_fun
function DailyMotionService:query(url, callback)
	local urlData = self:parseUrl(url)
	local metaurl = string.format("https://api.dailymotion.com/video/%s?fields=duration,title", urlData.id)

	http.Fetch(metaurl, function(result, size)
		if size == 0 then
			callback("http body size = 0")
			return
		end

		local data = {}
		data.id = urlData.id

		local jsontbl = util.JSONToTable(result)

		if jsontbl then
			data.title = jsontbl.title
			data.duration = jsontbl.duration
		else
			data.title = "ERROR"
		end

		callback(nil, data)
	end, function(err) callback("HTTP: " .. err) end)
end

medialib.load("media").registerService("dailymotion", DailyMotionService)