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
	-- third_left   = { {"alt",            }, "Left" },
	-- third_right  = { {"alt",            }, "Right" },
	-- third_up     = { {"alt",            }, "Up" },
	-- third_down   = { {"alt",            }, "Down" },
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
	-- TODO use screenPositions() to determine position x left to right, y top to bottom
	-- > hs.inspect(hs.screen.screenPositions())
	-- {
	--   [<userdata 1> -- hs.screen: Built-in Retina Display (0x600001fde9f8)] = {
	--     x = 0,
	--     y = 0
	--   },
	--   [<userdata 2> -- hs.screen: DELL U2723QE (0x600001fde938)] = {
	--     x = 0,
	--     y = -1
	--   }
	-- }
	--
	--
	--> hs.inspect(hs.screen.screenPositions())
	-- Loading extension: inspect
	-- {
	--   [<userdata 1> -- hs.screen: Dell AW3821DW (0x600003475838)] = {
	--     x = 1,
	--     y = 0
	--   },
	--   [<userdata 2> -- hs.screen: Built-in Retina Display (0x600003475338)] = {
	--     x = 0,
	--     y = 0
	--   },
	--   [<userdata 3> -- hs.screen: DELL U2719D (0x6000034774f8)] = {
	--     x = 2,
	--     y = 0
	--   }
	-- }

	local nScreen = #hs.screen.allScreens()
	local config = "solo"
	if nScreen >= 2 then
		for i, screen in ipairs(hs.screen.allScreens()) do
			-- print(i, screen:name(), screen:id())
			if screen:name() == 'Dell AW3821DW' then
				config = "home"
				break
			elseif screen:name() == 'DELL U2723QE' then
				config = "office"
				break
			end
		end
	end

	-- Use new percentage-based positioning for iTerm
	rw:positionItermWindows()

	-- Continue with file-based positioning for other apps
	if config == "home" then
		rw:run('Chrome', '%[([^%]]+)%]', 'Chrome.3.monitors.home')
	elseif config == "office" then
		rw:run('Chrome', '%[([^%]]+)%]', 'Chrome.2.monitors.office')
	end

	rw:run('zoom', '(.+)')
	rw:run('Slack', '.+(Slack)$')
	rw:run('Cursor', '(.+)')
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
			if appname == "Slack" then
				local slackApp = apps[i]
				hs.timer.doAfter(0.1, function() -- Add a small delay
					local slackWindow = slackApp:mainWindow() or slackApp:frontmostWindow()
					if slackWindow then
						slackWindow:focus() -- Then try to focus the window
					end
				end)
			end
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
local gSideBySideOriginalFrames = {}     -- Maps window ID to original frame

-- Add global table to store all window pairs
local gWindowPairs = {}  -- Array of pairs, each pair is {id1, id2}
local gCurrentPairIndex = 1

-- Initialize window filter
local windowFilter = hs.window.filter.new()

function addWindowPair(id1, id2)
    -- Add to gWindowPairs if not already present
    for _, pair in ipairs(gWindowPairs) do
        if (pair[1] == id1 and pair[2] == id2) or (pair[1] == id2 and pair[2] == id1) then
            return
        end
    end
    table.insert(gWindowPairs, {id1, id2})
end

function removeWindowPair(id1, id2)
    for i, pair in ipairs(gWindowPairs) do
        if (pair[1] == id1 and pair[2] == id2) or (pair[1] == id2 and pair[2] == id1) then
            table.remove(gWindowPairs, i)
            if gCurrentPairIndex > #gWindowPairs then
                gCurrentPairIndex = 1
            end
            return
        end
    end
end

function cyclePairedWindows()
    if #gWindowPairs == 0 then
        hs.alert.show("No paired windows")
        return
    end

    -- Get the current pair
    local pair = gWindowPairs[gCurrentPairIndex]
    local win1 = hs.window.get(pair[1])
    local win2 = hs.window.get(pair[2])

    -- Check if windows still exist
    if not win1 or not win2 then
        -- Remove invalid pair
        removeWindowPair(pair[1], pair[2])
        return
    end

    -- Bring both windows to front
    win1:focus()
    win2:focus()

    -- Move to next pair
    gCurrentPairIndex = gCurrentPairIndex + 1
    if gCurrentPairIndex > #gWindowPairs then
        gCurrentPairIndex = 1
    end

    -- Show which pair we're on
    hs.alert.show("Pair " .. gCurrentPairIndex .. " of " .. #gWindowPairs)
end

function toggleSideBySideLastTwoWindows()
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
            gSideBySideOriginalFrames[currentId] = nil
            removeWindowPair(currentId, pairedId)
            return
        end

        -- Toggle arrangement state
        if gWindowsArranged[currentId] then
            -- Restore original positions
            w:setFrame(gSideBySideOriginalFrames[currentId])
            pairedWindow:setFrame(gSideBySideOriginalFrames[pairedId])
            gWindowsArranged[currentId] = false
            gWindowsArranged[pairedId] = false
            -- Remove from pairs when restoring
            removeWindowPair(currentId, pairedId)
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
            -- Add to pairs when arranging
            addWindowPair(currentId, pairedId)
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
        gSideBySideOriginalFrames[currentId] = w:frame():copy()
        gSideBySideOriginalFrames[secondId] = secondWindow:frame():copy()

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
        -- Add new pair when arranging
        addWindowPair(currentId, secondId)
    end
end

-- Modify window filter to maintain gWindowPairs and restore remaining window
windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
    local windowId = window:id()
    if gWindowsPaired[windowId] then
        local pairedId = gWindowsPaired[windowId]
        local remainingWindow = hs.window.get(pairedId)

        -- Restore the remaining window if it exists
        if remainingWindow and gSideBySideOriginalFrames[pairedId] then
            remainingWindow:setFrame(gSideBySideOriginalFrames[pairedId])
        end

        -- Clean up both windows' data
        gWindowsPaired[windowId] = nil
        gWindowsPaired[pairedId] = nil
        gWindowsArranged[windowId] = nil
        gWindowsArranged[pairedId] = nil
        gSideBySideOriginalFrames[windowId] = nil
        gSideBySideOriginalFrames[pairedId] = nil
        -- Remove from pairs
        removeWindowPair(windowId, pairedId)
    end
end)

-- Single hotkey for toggling
hs.hotkey.bind({"alt"}, "2", toggleSideBySideLastTwoWindows)

-- Add global map to store original window frames
local gOriginalWidths = {}
-- Resize current window to full width of screen
function toggleFullWidth()
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
        gOriginalWidths[windowId] = wFrame:copy()

        -- Resize to full width
        w:setFrame({
            x = frame.x,
            y = wFrame.y,
            w = frame.w,
            h = wFrame.h
        })
    else
        -- Restore to original width if we have stored state
        if gOriginalWidths[windowId] then
            w:setFrame(gOriginalWidths[windowId])
            gOriginalWidths[windowId] = nil  -- Clear stored state
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
end
hs.hotkey.bind({"alt","shift"}, "w", toggleFullWidth)

-- Add new hotkey for cycling through pairs
hs.hotkey.bind({"alt", "shift"}, "2", cyclePairedWindows)

-- Window chooser
local windowChooser = hs.chooser.new(function(choice)
    if not choice then return end
    local win = choice["win"]
    if win then
        win:focus()
    end
end)

windowChooser:searchSubText(true)
windowChooser:bgDark(true)
windowChooser:rows(10)

function showChromeBracketWindows()
    local choices = {}

    -- Chrome windows
    local chromeApp = hs.application.find("Google Chrome")
    if chromeApp then
        for _, win in ipairs(chromeApp:allWindows()) do
            local title = win:title()
            -- Check if title starts with [something]
            local bracketContent = title:match("^%[([^%]]+)%]")
            if bracketContent then
                table.insert(choices, {
                    text = title,
                    subText = bracketContent,
                    win = win,
                    app = "Chrome"
                })
            end
        end
    end

    -- Future: Add other applications here
    -- local otherApp = hs.application.find("AppName")
    -- if otherApp then
    --     -- Add windows from otherApp
    -- end

    if #choices == 0 then
        return
    end

    -- Sort choices alphabetically by bracket content
    table.sort(choices, function(a, b) return a.subText < b.subText end)

    windowChooser:choices(choices)
    windowChooser:query(nil)
    windowChooser:show()
end

hs.hotkey.bind({"alt"}, "j", showChromeBracketWindows)
