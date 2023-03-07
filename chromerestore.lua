local obj = {}
-- obj.__index = obj

function atRightLocation(window, geom)
	local tl = window:topLeft()
	local sz = window:size()
	return tl.x == geom.x
		and tl.y == geom.y
		and sz.w == geom.w
		and sz.h == geom.h
end

function obj:run()
	local filename = os.getenv('HOME') .. '/dev/.chrome.windows.location.txt'
	local windowPos = {}
	for line in io.lines(filename) do
		local x, y, w, h, windowName = string.match(line, "([+-]?%d+) ([+-]?%d+) ([+-]?%d+) ([+-]?%d+) (.+)")
		x = tonumber(x)
		y = tonumber(y)
		h = tonumber(h)
		w = tonumber(w)
		windowPos[windowName] = {
			x = x,
			y = y,
			w = w,
			h = h
		}
	end

	local chromeWindows = {}
	local chrome = hs.application.find("Chrome")
	for i, v in ipairs(chrome:allWindows()) do
		local title = v:title()
		if #title > 0 then
			local i, j, windowName = string.find(title, '%[([^%]]+)%]')
			if windowName ~= nil and #windowName > 0 then
				if not atRightLocation(v, windowPos[windowName]) then
					print('moved ' .. windowName)
					v:setTopLeft({ x = windowPos[windowName].x, y = windowPos[windowName].y })
					v:setSize({ w = windowPos[windowName].w, h = windowPos[windowName].h })
				else
					print(' stay ' .. windowName)
				end
			end
		end
	end
end

return obj
