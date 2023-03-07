hs.loadSpoon("WindowHalfsAndThirds")

hs.ipc.cliInstall("/opt/local", true)

local WH3defaultHotkeys = {
   left_half    = { {"cmd"             }, "Left" },
   right_half   = { {"cmd"             }, "Right" },
   top_half     = { {"cmd"             }, "Up" },
   bottom_half  = { {"cmd"             }, "Down" },
   third_left   = { {"alt"              }, "Left" },
   third_right  = { {"alt"              }, "Right" } -- ,
--   third_up     = { {"ctrl", "alt"       }, "Up" },
--   third_down   = { {"ctrl", "alt"       }, "Down" },
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
hs.hotkey.bind({"alt", "shift"}, "B", openswitch("Google Chrome"))
hs.hotkey.bind({"alt", "shift"}, "S", openswitch("Slack"))
hs.hotkey.bind({"alt", "shift"}, "Z", openswitch("zoom.us"))
hs.hotkey.bind({"alt", "shift"}, "Q", openswitch("Preview"))
hs.hotkey.bind({"alt", "shift"}, "X", function() hs.execute("sh -c '$HOME/dev/bin/grab-x $(pbpaste)'", true) end)
hs.hotkey.bind({"alt", "shift"}, "J", function() hs.execute("sh -c '$HOME/dev/bin/jira $(pbpaste)'", true) end)

function focusLastFocused()
	local wf = hs.window.filter
	local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
	if #lastFocused > 0 then lastFocused[1]:focus() end
end

function raisewindow(choice)
	if not choice then focusLastFocused(); return end
	print('raisewindow')
	print(choice)
	-- hs.pasteboard.setContents(choice["chars"])
	-- focusLastFocused()
	-- hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end

hs.hotkey.bind({"alt"}, "space", function()
	local chooser = hs.chooser.new(raisewindow)
	chooser:choices({
		{ ["text"] = "one" },
		{ ["text"] = "two" },
	})
	-- TODO chooser:searchSubText(true)

	-- local app = hs.application.get("zoom.us")
	-- print(app)
	-- app:activate(true)
end)

-- ======================================= Utilities
-- // disable window animations
hs.window.animationDuration = 0


hs.hotkey.bind({"alt", "shift"}, "H", function()
	hs.application.get("Hammerspoon"):activate(true)
end)

hs.hotkey.bind({"alt"}, "z", function()
	local app = hs.application.get("zoom.us")
	print(app)
	app:activate(true)
end)

local chromeRestore = require("chromerestore")
hs.hotkey.bind({"alt"}, "x", function()
	chromeRestore:run()
	hs.execute("$HOME/dev/bin/restore.window.positions", true)
end)
