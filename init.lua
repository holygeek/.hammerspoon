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
	if #hs.screen.allScreens() == 3 then
		rw:run('iTerm', '^(%a)$')
		rw:run('Chrome', '%[([^%]]+)%]')
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
function raiseWindow(titlePattern)
	return function()
		hs.window.find(titlePattern):focus()
	end
end
function raiseIterm(termName)
	hs.window.find('^' .. termName .. '$'):focus()
end
function startTmux()
	for i=1,#iterms do
		local termName = iterms[i]
		raiseIterm(termName)
		hs.eventtap.keyStrokes('tm ' .. termName .. '\n')
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
-- chrome windows
require("browser")
hs.hotkey.bind({"alt"}, "o",  raiseOther)
-- vpn
hs.hotkey.bind({"alt"}, "p", function() hs.application.find("Cisco"):activate() end)
-- slack
hs.hotkey.bind({"alt"}, "c", raiseWindow("Slack"))
-- iterm2 windows
-- ==============
hs.hotkey.bind({"cmd", "alt"}, "t", startTmux)
for i=1,#iterms do
	local termName = iterms[i]
	hs.hotkey.bind({"alt"}, termName, raiseWindow('^' ..  termName .. '$'))
end
-- move frontmost window to center display
hs.hotkey.bind({"alt", "shift"}, "c", centerFrontmostWindow)

-- hs.console.clearConsole()
-- hs.hints.windowHints(hs.window.focusedWindow():application():allWindows())
-- hs.hints.windowHints()
