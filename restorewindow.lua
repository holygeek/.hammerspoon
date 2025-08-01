local obj = {}
-- obj.__index = obj

-- Hardcoded iTerm window positions as percentages of screen dimensions
-- Format: {x%, y%, width%, height%}
local itermPositions = {
    -- When on laptop only (all windows on single screen)
    laptop = {
        a = {16.4, 9.1, 71.0, 72.4},   -- centered main window
        s = {0, 0, 50, 100},           -- left half
        v = {50, 0, 50, 100},          -- right half
        r = {50, 0, 50, 100},   -- right half variant
        f = {0, 0, 100, 100},       -- full width
        g = {0, 0, 50, 50},    -- left upper
        i = {50, 0, 50, 50},   -- right upper
        h = {0, 0, 100, 50},       -- full width top half
        l = {0, 50, 100, 50},     -- full width bottom half
        k = {15, 0, 70, 100}    -- center large
    },
    -- When external monitors available
    external = {
        -- Positions on external monitor (as % of external monitor size)
        s = { 0 , 0, 34, 100},           -- left half
        v = {34,  0, 34, 100},          -- right half
        r = {68,  0, 32, 100},          -- right half (same as v)
        f = {34,  0, 66, 100},          -- full screen
        k = {30,  0, 55, 100},           -- left 55%
        g = { 0,  0, 50, 54},            -- left upper
        i = {50,  0, 50, 54},           -- right upper
        h = {34,  0, 66, 50},         -- full width top half
        l = {34, 50, 66, 50},          -- full width bottom half
        -- Position on laptop screen (as % of laptop screen size)
        a = {16.4, 14.5, 71.0, 72.4}  -- centered on laptop
    }
}

function wait (s)
    io.popen("gsleep " .. s):close()
end

-- Function to find the biggest external monitor by resolution
function findBiggestExternalMonitor()
    local screens = hs.screen.allScreens()
    local internalScreen = hs.screen.primaryScreen()
    local biggestExternal = nil
    local maxArea = 0

    for _, screen in ipairs(screens) do
        if screen ~= internalScreen then
            local size = screen:frame()
            local area = size.w * size.h
            if area > maxArea then
                maxArea = area
                biggestExternal = screen
            end
        end
    end

    return biggestExternal
end

-- Function to position iTerm windows using percentage-based positions
function obj:positionItermWindows()
    local itermApp = hs.application.find("iTerm2") or hs.application.find("iTerm")
    if not itermApp then
        print("iTerm not found")
        return
    end

    local screens = hs.screen.allScreens()
    local laptopScreen = hs.screen.primaryScreen()
    local externalScreen = findBiggestExternalMonitor()

    -- Determine which position set to use
    local positions = externalScreen and itermPositions.external or itermPositions.laptop

    -- Position each iTerm window
    for _, window in ipairs(itermApp:allWindows()) do
        local title = window:title()
        -- Extract single letter from title (match pattern ^[a-z]$)
        local letter = title:match("^([a-z])$")

        if letter and positions[letter] then
            local pos = positions[letter]
            local targetScreen = laptopScreen

            -- If external monitor exists and this isn't window 'a', use external monitor
            if externalScreen and letter ~= 'a' then
                targetScreen = externalScreen
            end

            local frame = targetScreen:frame()
            local newFrame = {
                x = frame.x + (frame.w * pos[1] / 100),
                y = frame.y + (frame.h * pos[2] / 100),
                w = frame.w * pos[3] / 100,
                h = frame.h * pos[4] / 100
            }

            print(string.format("Positioning iTerm '%s' to {x=%.0f, y=%.0f, w=%.0f, h=%.0f}",
                letter, newFrame.x, newFrame.y, newFrame.w, newFrame.h))

            window:setFrame(newFrame)
        end
    end
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
	local nAttempts = 1 -- 20
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

function obj:run(appName, titlePattern, fileSuffix)
	local windowPos = {}
	fileSuffix = fileSuffix or appName
	print('file suffix', fileSuffix)
	local filename = os.getenv('HOME') .. '/.hammerspoon/.windows.' .. fileSuffix
	local hasMainWindow = false
	for line in io.lines(filename) do
		if string.sub(line, 1, 1) ~= '#' then
			local x, y, w, h, windowName = string.match(line, "([+-]?%d+) ([+-]?%d+) ([+-]?%d+) ([+-]?%d+) (.+)")
			x = tonumber(x)
			y = tonumber(y)
			h = tonumber(h)
			w = tonumber(w)
			if windowName then
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
	end

	local moved = false
	local app = hs.application.find(appName)
	if not app then
		return
	end
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
