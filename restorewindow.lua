local obj = {}
-- obj.__index = obj

function wait (s)
    io.popen("gsleep " .. s):close()
end

function atRightLocation(window, geom)
	local tl = window:topLeft()
	local sz = window:size()

	if pcall(function()
		local title = window:title()
		if tl.x ~= geom.x then print('x ' .. tl.x .. '!=' .. geom.x .. ' ' ..  title) end
		if tl.y ~= geom.y then print('y ' .. tl.y .. '!=' .. geom.y .. ' ' ..  title) end
		if sz.w ~= geom.w then print('w ' .. tl.w .. '!=' .. geom.w .. ' ' ..  title) end
		if sz.h ~= geom.h then print('h ' .. tl.h .. '!=' .. geom.h .. ' ' ..  title) end
	end) then
		-- no errors
	else
		print(' uh oh')
	end

	return tl.x == geom.x
		and tl.y == geom.y
		and sz.w == geom.w
		and sz.h == geom.h
end

function placeWindow(v, f, windowName)
	-- v:setTopLeft({ x = f.x, y = f.y })
	-- v:setSize({ w = f.w, h = f.h })
	local nAttempts = 20
	for i=1,nAttempts do -- try 10 times
		print(' ' .. i .. ' moving ' .. windowName .. string.format(" w:setFrame(hs.geometry.new(%d, %d, %d, %d)", f.x, f.y, f.w, f.h))
		v:setFrame(hs.geometry.new(f.x, f.y, f.w, f.h))
		if atRightLocation(v, f) then
			print(' ' .. windowName .. ' done after ' .. i .. '.0 attempts')
			return
		end
		wait(0.5)
		-- if atRightLocation(v, f) then
		-- 	print(' ' .. windowName .. ' done after ' .. i .. '.5 attempts')
		-- 	return
		-- end
	end
	print('gave up on ' .. windowName .. ' after ' .. nAttempts .. ' attempts')
end

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function obj:run(appName, titlePattern)
	local windowPos = {}
	local filename = os.getenv('HOME') .. '/.hammerspoon/.windows.' .. appName
	local hasMainWindow = false
	for line in io.lines(filename) do
		if string.sub(line, 1, 1) ~= '#' then
			local x, y, w, h, windowName = string.match(line, "([+-]?%d+) ([+-]?%d+) ([+-]?%d+) ([+-]?%d+) (.+)")
			x = tonumber(x)
			y = tonumber(y)
			h = tonumber(h)
			w = tonumber(w)
			if ends_with(windowName, "=main") then
				hasMainWindow = true
			end
			windowPos[windowName] = {
				x = x,
				y = y,
				w = w,
				h = h
			}
		end
	end

	local moved = false
	local app = hs.application.find(appName)
	local mainWindow = nil
	if hasMainWindow then
		mainWindow = app:mainWindow()
	end
	for i, v in ipairs(app:allWindows()) do
		local title = v:title()
		if #title > 0 then
			local i, j, windowName = string.find(title, titlePattern)
			if hasMainWindow and mainWindow == v then
				windowName = windowName .. '=main'
			end
			if windowName ~= nil and #windowName > 0 then
				local f = windowPos[windowName]
				if not f then
					print('hmm ' .. windowName .. ' has no entry in windowPos')
				elseif not atRightLocation(v, f) then
					moved = 1
					print(windowName .. ' misplaced')
					placeWindow(v, f, windowName)
				else
					-- print(' stay ' .. windowName)
				end
			end
		end
	end
	if not moved then
		print(appName .. ' window locations not changed')
	end
end

return obj
