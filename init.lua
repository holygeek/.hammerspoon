
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
hs.hotkey.bind({"alt", "shift"}, "B", openswitch("Google Chrome"))
hs.hotkey.bind({"alt", "shift"}, "J", function() hs.execute("sh -c '$HOME/dev/bin/jira $(pbpaste)'", true) end)
hs.hotkey.bind({"alt", "shift"}, "Q", openswitch("Preview"))
hs.hotkey.bind({"alt", "shift"}, "S", openswitch("Slack"))
hs.hotkey.bind({"alt", "shift"}, "X", function() hs.execute("sh -c '$HOME/dev/bin/grab-x $(pbpaste)'", true) end)
hs.hotkey.bind({"alt", "shift"}, "Z", openswitch("zoom.us"))
hs.hotkey.bind({"alt"}, "space", function() switcher:selectWindow(false) end)
hs.hotkey.bind({"alt", "shift"}, "H", function() hs.application.get("Hammerspoon"):activate(true) end)

-- SkyRocket.spoon
local SkyRocket = hs.loadSpoon("SkyRocket")
sky = SkyRocket:new({
  -- Opacity of resize canvas
  opacity = 0.3,
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


hs.hotkey.bind({"alt"}, "z", function() hs.application.get("zoom.us"):activate(true) end)

local rw = require("restorewindow")
hs.hotkey.bind({"alt"}, "x", function()
	rw:run('Chrome', os.getenv('HOME') .. '/dev/.chrome.windows.location.txt', '%[([^%]]+)%]')
	rw:run('iTerm', os.getenv('HOME') .. '/dev/.iterm2.windows.location.txt', '(%a) %(%-?%a+%)')
	-- hs.execute("$HOME/dev/bin/restore.window.positions", true)
end)

hs.hotkey.showHotkeys({"cmd", "shift"}, "k")
