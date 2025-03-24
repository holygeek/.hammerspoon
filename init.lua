hs.ipc.cliInstall("/opt/local", true)

hs.window.animationDuration = 0

-- Reload config automatically
function reloadConfig(files)
	doReload = false
	for _,file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
			break
		end
	end
	if doReload then
		hs.reload()
	end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/dev/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- WindowHalfsAndThirds.Spooon
hs.loadSpoon("WindowHalfsAndThirds")
local WH3defaultHotkeys = {
	left_half    = { {"alt", "shift"    }, "Left" },
	right_half   = { {"alt", "shift"    }, "Right" },
	top_half     = { {"alt", "shift"    }, "Up" },
	bottom_half  = { {"alt", "shift"    }, "Down" },
	third_left   = { {"alt",            }, "Left" },
	third_right  = { {"alt",            }, "Right" },
	third_up     = { {"alt",            }, "Up" },
	third_down   = { {"alt",            }, "Down" },
	--    top_left     = { {"ctrl",        "cmd"}, "1" },
	--    top_right    = { {"ctrl",        "cmd"}, "2" },
	--    bottom_left  = { {"ctrl",        "cmd"}, "3" },
	--    bottom_right = { {"ctrl",        "cmd"}, "4" },
	--    max_toggle   = { {"ctrl", "alt", "cmd"}, "f" },
	--    max          = { {"ctrl", "alt", "cmd"}, "Up" },
	--    undo         = { {        "alt", "cmd"}, "z" },
	--    center       = { {        "alt", "cmd"}, "c" },
	--    larger       = { {        "alt", "cmd", "shift"}, "Right" },
	--    smaller      = { {        "alt", "cmd", "shift"}, "Left" },
}
spoon.WindowHalfsAndThirds:bindHotkeys(WH3defaultHotkeys)

--  // Window switcher
local switcher  = require('switcher')
-- Alt-B is bound to the switcher dialog for all apps.
-- Alt-shift-B is bound to the switcher dialog for the current app.
function openswitch(name)
	return function()
		-- print("OHAI " .. name .. " is " .. hs.application.frontmostApplication():name())
		if hs.application.frontmostApplication():name() == name then
			-- print("NAME: [" .. hs.application.frontmostApplication():name() .. "]")
			-- switcher:switcherfunc()
			switcher:selectWindow(true)
		else
			hs.application.launchOrFocus(name)
		end
	end
end
-- hs.hotkey.bind({"alt", "shift"}, "b", openswitch("Google Chrome"))
hs.hotkey.bind({"alt", "shift"}, "j", function() hs.execute("sh -c '$HOME/dev/bin/jira $(pbpaste)'", true) end)
hs.hotkey.bind({"alt", "shift"}, "q", openswitch("Preview"))
hs.hotkey.bind({"alt", "shift"}, "s", openswitch("Slack"))
hs.hotkey.bind({"alt", "shift"}, "x", function() hs.execute("sh -c '$HOME/dev/bin/grab-x $(pbpaste)'", true) end)
hs.hotkey.bind({"alt", "shift"}, "z", openswitch("zoom.us"))
hs.hotkey.bind({"alt"}, "space", function() switcher:selectWindow(false) end)
hs.hotkey.bind({"alt", "shift"}, "h", function() hs.application.get("Hammerspoon"):activate(true) end)
function twoWindow()
	local ws = hs.window.orderedWindows()
	print('1', ws[2]:title(), ws[1]:role())
	print('2', ws[3]:title(), ws[2]:role())
	hs.grid.set(ws[2], hs.geometry(0, 0, 0.5, 0))
	hs.grid.set(ws[3], hs.geometry(0.5, 0, 0.5, 0))
end
hs.hotkey.bind({"ctrl", "alt"}, "2", twoWindow)

-- screencapture to ram
function captureToRam()
	hs.execute("screencapture -c -i")
end
hs.hotkey.bind({"alt", "shift"}, "4", captureToRam)

-- SkyRocket.spoon moves window with alt+click
local SkyRocket = hs.loadSpoon("SkyRocket")
sky = SkyRocket:new({
	-- Opacity of resize canvas
	opacity = 0.6,
	-- Which modifiers to hold to move a window?
	-- moveModifiers = {'cmd', 'shift'},
	moveModifiers = {'alt'},
	-- Which mouse button to hold to move a window?
	moveMouseButton = 'left',
	-- Which modifiers to hold to resize a window?
	resizeModifiers = {'alt', 'shift'},
	-- Which mouse button to hold to resize a window?
	resizeMouseButton = 'left',
})

function focusLastFocused()
	local wf = hs.window.filter
	local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
	-- print('lastFocused', lastFocused[2]:title())
	if #lastFocused > 1 then lastFocused[2]:focus() end
end
hs.hotkey.bind({"alt"}, "tab", focusLastFocused)


hs.hotkey.bind({"alt"}, "z", function()
	local zooms = {hs.application.find("zoom.us")}
	for i=1,#zooms do
		zooms[i]:activate(true)
	end
end)

local rw = require("restorewindow")
hs.hotkey.bind({"alt"}, "x", function()
	-- if #hs.screen.allScreens() == 3 then
	local nScreen = #hs.screen.allScreens()
	if nScreen >= 2 then
		if nScreen == 3 then
			rw:run('iTerm', '^(%a)$', 'iTerm.3.monitors.home')
			rw:run('Chrome', '%[([^%]]+)%]', 'Chrome.3.monitors.home')
		else
			rw:run('iTerm', '^(%a)$', 'iTerm.2.monitors.office')
			rw:run('Chrome', '%[([^%]]+)%]', 'Chrome.2.monitors.office')
		end
		rw:run('zoom', '(.+)')
		rw:run('Slack', '.+(Slack)$')
	else
		rw:run('iTerm', '^(%a)$', 'iTerm.laptop')
	end
	hs.alert.show("Done")
	-- hs.execute("$HOME/dev/bin/restore.window.positions", true)
end)

hs.hotkey.showHotkeys({"cmd", "alt"}, "k")

-- alt+key
local iterms = { "s", "a", "f", "g", "h", "i", "k", "l", "r", "v" }
-- todo alt+n and alt+p
function centerFrontmostWindow()
	local w = hs.window.frontmostWindow()
	if w then
		w:setFrame(hs.geometry.new(2987.0,-397.0,1454.0,1368.0))
	end
end
function raiseWindowTitlePattern(appName, titlePattern)
	return function()
		-- local start = os.clock()
		local app = hs.application.find(appName)
		if not app then
			print(appName, "no such app")
			return
		end
		local w = app:findWindow(titlePattern)
		if not w then
			print(appName, titlePattern, "no such window")
			return
		end
		w:focus()
		-- print(os.clock() - start)
		--  local cmd = "cat $HOME/tmp/chrome.windows|grep '\\[" .. name .. "\\]'|grep -o '[0-9]*'"

		--  local windowid, status, exitType, rc = hs.execute(cmd)
		--  -- hs.alert.show(output)
		--  print("windowid", windowid)

		--  -- Tue 19 Nov 2024 22:25:43 +08 doesn't work. hypothesis: chrome-cli windowid  not same
		--  local w = hs.window.get(tonumber(windowid))

		-- print("output", output)
		-- print("status", status, "exitType", exitType, "rc", rc)

		-- local w = hs.window.find(titlePattern)
		-- if w then
		-- 	w:focus()
		-- else
		-- 	print("no Chrome window found matching " .. name .. ". Check ~/tmp/chrome.dinwos?")
		-- end
	end
end
function raiseWindow(titlePattern)
	return function()
		local start = os.clock()
		local w = hs.window.find(titlePattern)
		if w then
			w:focus()
		-- else print("no window found matching " ..titlePattern)
		end
		print(os.clock() - start)
	end
end
function raiseAllWindow(appname)
	return function()
		local apps = {hs.application.find(appname)}
		for i=1,#apps do
			apps[i]:activate(true)
		end
	end
end
function raiseIterm(termName)
	local w = hs.window.find('^' .. termName .. '$')
	if w then
		w:focus()
		return true
	else
		print("could not find ^" .. termName .. "$")
		return false
	end
end
function startTmux()
	for i=1,#iterms do
		local termName = iterms[i]
		if raiseIterm(termName) then
			hs.eventtap.keyStrokes('tm ' .. termName .. '\n')
		else
			print("could not raise " .. termName)
		end
	end
end
-- https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
local otherRaised = 1
function raiseOther()
	local w = hs.window.allWindows()
	local others = {}
	local j = 1
	for i=1,#w do
		local app = w[i]:application()
		if not app then goto continue end
		if app:name() == 'iTerm2' then goto continue end

		local title = w[i]:title()
		--DEBUG print('title', title)
		if title and #title > 0 then
			if app:name() == 'Google Chrome' then
				local name = string.find(title, '%[([^%]]+)%]')
				if name then
					-- could be named chrome window, unless it's a ticket, then add to others
					local jiraticket = string.find(name, '%[%u+-%d+%]')
					if jiraticket then
						others[title] = w[i]
						--DEBUG print("  ADDED")
						-- table.insert(others, w[i])
					end
				else
					others[title] = w[i]
					--DEBUG print("  ADDED")
					-- table.insert(others, w[i])
				end
			else
				others[title] = w[i]
				--DEBUG print("  ADDED")
			end
		end
		::continue::
	end


	-- sort others table alphabetically by the title
	local toselect = {}
	local j = 1
	for title, w in spairs(others) do
		toselect[j] = w
		j = j + 1
	end
	otherRaised = otherRaised + 1
	if otherRaised > #toselect then
		otherRaised = 1
	end
	if #toselect > 0 then
		local w = toselect[otherRaised]
		print('other: raising ' .. w:title())
		w:focus()
	end
end

-- alt + key
-- =========
-- chrome windows
require("browser")
hs.hotkey.bind({"alt"}, "o",  raiseOther)
-- vpn
-- hs.hotkey.bind({"alt"}, "p", function() hs.application.find("Cisco"):activate() end)
hs.hotkey.bind({"alt"}, "p", function() hs.application.find("Zscaler"):activate() end)
-- slack
hs.hotkey.bind({"alt"}, "c", raiseAllWindow("Slack"))
-- cursor
hs.hotkey.bind({"alt"}, "b", raiseAllWindow("Cursor"))
-- zoom
hs.hotkey.bind({"alt"}, "z", raiseAllWindow("zoom.us"))
-- hs.hotkey.bind({"alt"}, "z", function()
-- 	local zooms = {hs.application.find("zoom.us")}
-- 	for i=1,#zooms do
-- 		zooms[i]:activate(true)
-- 	end
-- end)

-- Notes window
hs.hotkey.bind({"alt"}, "n", raiseAllWindow('Notes'))

-- raiseWindow seems to be very slow due to hs.window.find
function raiseAppWindow(appName, title)
	return function()
		-- local start = os.clock()
		local app = hs.appfinder.appFromName(appName)
		if not app then
			print("no app found for " .. appName)
			return
		end
		local w = app:getWindow(title)
		if w then
			w:focus()
		else
			print("no window found matching " .. title)
		end
		-- print(os.clock() - start)
	end
end
-- iterm2 windows
-- ==============
hs.hotkey.bind({"cmd", "alt"}, "t", startTmux)
for i=1,#iterms do
	local termName = iterms[i]
	-- hs.hotkey.bind({"alt"}, termName, raiseWindow('^' ..  termName .. '$'))
	hs.hotkey.bind({"alt"}, termName, raiseAppWindow('iTerm', termName))
end

-- 2025-01-06 00:06:16: no window found matching ghostty.b
-- ran with "~/bin/ghostty.run b"
-- hs.hotkey.bind({"alt"}, "b", raiseAppWindow('Ghostty', 'ghostty.b'))

-- move frontmost window to center display
hs.hotkey.bind({"alt", "shift"}, "c", centerFrontmostWindow)

-- hs.console.clearConsole()
-- hs.hints.windowHints(hs.window.focusedWindow():application():allWindows())
-- hs.hints.windowHints()
-- Timer
-- hs.timer.doAfter(2, function() hs.alert.show('foo bar') end
-- Move mouse
-- hs.mouse.setAbsolutePosition({x=100,y=100})
-- hs.mouse.setAbsolutePosition({x=cursorLocation.x+100,y=cursorLocation.y+100})

-- Add global maps for window pairing and state
local gWindowsPaired = {}      -- Maps window ID to its paired window ID
local gWindowsArranged = {}    -- Maps window ID to arranged state (true/false)
local gOriginalFrames = {}     -- Maps window ID to original frame

function toggleLastTwoWindows()
    local w = hs.window.frontmostWindow()
    if not w then
        return
    end

    local currentId = w:id()

    -- Check if current window is already paired
    if gWindowsPaired[currentId] then
        local pairedId = gWindowsPaired[currentId]
        local pairedWindow = hs.window.get(pairedId)

        -- Verify paired window still exists
        if not pairedWindow then
            -- Clean up orphaned pairing
            gWindowsPaired[currentId] = nil
            gWindowsArranged[currentId] = nil
            gOriginalFrames[currentId] = nil
            return
        end

        -- Toggle arrangement state
        if gWindowsArranged[currentId] then
            -- Restore original positions
            w:setFrame(gOriginalFrames[currentId])
            pairedWindow:setFrame(gOriginalFrames[pairedId])
            gWindowsArranged[currentId] = false
            gWindowsArranged[pairedId] = false
        else
            -- Arrange side by side on the current window's screen
            local screen = w:screen()
            local frame = screen:frame()

            w:setFrame({
                x = frame.x,
                y = frame.y,
                w = frame.w / 2,
                h = frame.h * 0.7
            })

            pairedWindow:setFrame({
                x = frame.x + frame.w / 2,
                y = frame.y,
                w = frame.w / 2,
                h = frame.h * 0.7
            })

            gWindowsArranged[currentId] = true
            gWindowsArranged[pairedId] = true
        end
    else
        -- Create new pairing with second last window
        local orderedWindows = hs.window.orderedWindows()
        if #orderedWindows < 2 then
            return
        end

        -- Find the second window that isn't already paired
        local secondWindow = nil
        for i = 1, #orderedWindows do
            local candidateId = orderedWindows[i]:id()
            if candidateId ~= currentId and not gWindowsPaired[candidateId] then
                secondWindow = orderedWindows[i]
                break
            end
        end

        if not secondWindow then
            hs.alert.show("No unpaired windows available")
            return
        end

        local secondId = secondWindow:id()

        -- Store original frames before arranging
        gOriginalFrames[currentId] = w:frame():copy()
        gOriginalFrames[secondId] = secondWindow:frame():copy()

        -- Create bidirectional pairing
        gWindowsPaired[currentId] = secondId
        gWindowsPaired[secondId] = currentId

        -- Arrange side by side on the current window's screen
        local screen = w:screen()
        local frame = screen:frame()

        w:setFrame({
            x = frame.x,
            y = frame.y,
            w = frame.w / 2,
            h = frame.h * 0.7
        })

        secondWindow:setFrame({
            x = frame.x + frame.w / 2,
            y = frame.y,
            w = frame.w / 2,
            h = frame.h * 0.7
        })

        gWindowsArranged[currentId] = true
        gWindowsArranged[secondId] = true
    end
end

-- Add function to clean up when a window is closed
local windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
    local windowId = window:id()
    if gWindowsPaired[windowId] then
        local pairedId = gWindowsPaired[windowId]
        -- Clean up both windows' data
        gWindowsPaired[windowId] = nil
        gWindowsPaired[pairedId] = nil
        gWindowsArranged[windowId] = nil
        gWindowsArranged[pairedId] = nil
        gOriginalFrames[windowId] = nil
        gOriginalFrames[pairedId] = nil
    end
end)

-- Single hotkey for toggling
hs.hotkey.bind({"alt"}, "2", toggleLastTwoWindows)


-- Add global map to store original window frames
local gOriginalFrames = {}
-- Resize current window to full width of screen
hs.hotkey.bind({"alt","shift"}, "w", function()
    local w = hs.window.frontmostWindow()
    if not w then
        return
    end

    -- Get window ID and current frame
    local windowId = w:id()
    local wFrame = w:frame()
    local screen = w:screen()
    local frame = screen:frame()

    -- If window is not full width
    if wFrame.w ~= frame.w then
        -- Store original frame in map
        gOriginalFrames[windowId] = wFrame:copy()

        -- Resize to full width
        w:setFrame({
            x = frame.x,
            y = wFrame.y,
            w = frame.w,
            h = wFrame.h
        })
    else
        -- Restore to original width if we have stored state
        if gOriginalFrames[windowId] then
            w:setFrame(gOriginalFrames[windowId])
            gOriginalFrames[windowId] = nil  -- Clear stored state
        else
            -- Default to half width if no stored state
            w:setFrame({
                x = frame.x,
                y = wFrame.y,
                w = frame.w / 2,
                h = wFrame.h
            })
        end
    end
end)
