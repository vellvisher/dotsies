-- Enable repl via /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/ipc/bin/hs
require("hs.ipc")

require("ar.window")

-- Easier installation of spoons.
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("KSheet")

ksheetVisible = false
hs.hotkey.bind({"alt"}, "H", function()
      if ksheetVisible then
         spoon.KSheet:hide()
         ksheetVisible = false
      else
         spoon.KSheet:show()
         ksheetVisible = true
      end
end)

-- Spectacle Window Manager Keybindings For Hammerspoon
-- https://github.com/scottwhudson/Lunette
hs.loadSpoon("Lunette")
spoon.Lunette:bindHotkeys()

-- Aliases

-- Easily dump variables to the console.
i = hs.inspect.inspect
inspect = hs.inspect.inspect
d = hs.doc
doc = hs.doc

function split(str, delimiter)
   local result = {}
   for match in (str..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(result, match);
   end
   return result
end

function fuzzyMatch(terms, text)
   if terms == nil or terms == '' then
      return true
   end
   local haystack = text:lower()
   for _, needle in ipairs(split(terms, " ")) do
      hs.printf(needle)
      if not haystack:match(needle:lower()) then
         return false
      end
   end
   return true
end

function activateFirstOf(queries)
   local query = hs.fnutils.find(queries, function(query) return hs.application.find(query["bundleID"]) ~= nil end)
   if not query then
      hs.alert.show("No app found\n "..hs.inspect.inspect(queries))
      return
   end

   local app = hs.application.find(query["bundleID"])
   if not app:activate() then
      hs.alert.show(app["bundleID"].." not activated :/")
      return
   end
end

function emacsExecute(activate, elisp)
   if activate then
      activateFirstOf({
            {
               bundleID="org.gnu.Emacs",
               name="Emacs"
            }
      })
   end

   output,success = hs.execute("~/homebrew/bin/emacsclient -ne \""..elisp.."\" -s /tmp/emacs*/server")
   if not success then
      hs.alert.show("Emacs did not execute: "..elisp)
   end

   return output, success
end

function addEmacsOrgModeTODO()
   appRequestingOrgEdit = hs.application.frontmostApplication()
   emacsExecute(false, "(ar/hammerspoon-org-modal-add-todo)")
   activateFirstOf({
            {
               bundleID="org.gnu.Emacs",
               name="Emacs"
            }
      })
end

function backFromEmacsOrgEdit()
   if appRequestingOrgEdit == nil then
      hs.alert("Not editing org file")
      return
   end
   if appRequestingOrgEdit:bundleID() == "org.gnu.Emacs" then
      -- No need to bounce back to Emacs if invoked from Emacs.
      return
   end
   appRequestingOrgEdit:activate()
   appRequestingOrgEdit = nil
end

function addEmacsOrgModeGoLink()
   emacsExecute(false, "(ar/org-add-short-link-in-file)")
end

function getEmacsOrgShortLinks()
   output,success = emacsExecute(false, "(ar/org-short-links-json)")
   if not success then
      return nil
   end
   local decoded = hs.json.decode(output)
   return hs.json.decode(decoded)
end

function searchEmacsOrgShortLinks()
   local chooser = hs.chooser.new(function(choice)
         if not choice then
            ar.window.focusPrevious()
            return
         end
         output,success = hs.execute("open http://"..choice['text'])
         if not success then
            hs.alert.show("Could not open: "..choice['text'])
         end
   end)

   local links = hs.fnutils.map(getEmacsOrgShortLinks(), function(item)
                                   return {
                                      text=item['link'],
                                      subText=item['description']
                                   }
   end)
   chooser:queryChangedCallback(function(query)
         chooser:choices(hs.fnutils.filter(links, function(item)
                                              hs.printf(item["text"])
                                              -- Concat text and subText to search in either
                                              return fuzzyMatch(query, item["text"]..item["subText"]) end))
   end)

   chooser:choices(links)
   chooser:show()
end

hs.hotkey.bind({"alt"}, "T", addEmacsOrgModeTODO)
hs.hotkey.bind({"alt"}, "L", searchEmacsOrgShortLinks)

hs.hotkey.bind({"alt"}, "D", function() activateFirstOf({
            {
               bundleID="com.kapeli.dashdoc",
               name="Dash"
            }
}) end)

hs.hotkey.bind({"alt"}, "E", function() activateFirstOf({
            {
               bundleID="org.gnu.Emacs",
               name="Emacs"
            }
}) end)

hs.hotkey.bind({"alt"}, "X", function() activateFirstOf({
            {
               bundleID="com.apple.dt.Xcode",
               name="Xcode"
            }
}) end)

hs.hotkey.bind({"alt"}, "B", function() activateFirstOf({
            {
               bundleID="org.mozilla.firefox",
               name="Firefox"
            },
            {
               bundleID="com.apple.Safari",
               name="Safari"
            },
            {
               bundleID="com.google.Chrome",
               name="Google Chrome"
            },
}) end)

hs.hotkey.bind({"alt"}, "M", function() activateFirstOf({
            {
               bundleID="com.apple.mail",
               name="Mail"
            },
            {
               bundleID="org.epichrome.app.GoogleMail",
               name="Google Mail"
            },
}) end)

hs.hotkey.bind({"alt"}, "C", function() activateFirstOf({
            {
               bundleID="com.apple.iCal",
               name="Calendar"
            },
            {
               bundleID="org.epichrome.app.GoogleCalend",
               name="Google Calendar"
            },
}) end)

hs.hotkey.bind({"alt"}, "S", function() activateFirstOf({
            {
               bundleID="com.electron.chat",
               name="Google Chat"
            },
}) end)

-- Window management

hs.window.animationDuration = 0

hs.grid.setMargins("0x0")

hs.grid.setGrid("4x2")

hs.hotkey.bind({"alt"}, "G", hs.grid.show)

function reframeFocusedWindow()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen():frame()

   f.x = screen.x + 15
   f.y = screen.y + 15
   f.w = screen.w - 30
   f.h = screen.h - 30

   win:setFrame(f)
end

hs.hotkey.bind({"alt"}, "F", reframeFocusedWindow)

function readFile(file)
   local f = assert(io.open(file, "rb"))
   local content = f:read("*all")
   f:close()
   return content
end


function findfunction(x)
   assert(type(x) == "string")
   local f=_G
   for v in x:gmatch("[^%.]+") do
      if type(f) ~= "table" then
         return nil, "looking for '"..v.."' expected table, not "..type(f)
      end
      f=f[v]
   end
   if type(f) == "function" then
      return f
   else
      return nil, "expected function, not "..type(f)
   end
end

function getModuleByName(name)
   return hs.fnutils.find(doc._jsonForModules, function(module)
                             return module['name'] == name
   end)
end

-- Given  "hs.window.desktop("
-- We get "hs.window.desktop() -> hs.window object"
function signatureFromQualifiedName(qualifiedName)
   -- hs.grid.show( -> hs.grid
   -- hs.grid.show -> hs.grid
   local moduleName = string.match(qualifiedName, "(.*)[.]")

   -- hs.grid.show(-> show
   -- hs.grid.show -> show
   local name = string.match(qualifiedName, "[.]([a-zA-Z]*)[(]?$")

   local module = getModuleByName(moduleName)
   if not module then
      return nil
   end

   local constant = hs.fnutils.find(module['Constant'], function(f)
                                       return f['name'] == name
   end)
   if constant then
      return constant['signature']
   end

   local constructor = hs.fnutils.find(module['Constructor'], function(f)
                                          return f['name'] == name
   end)
   if constructor then
      return constructor['signature']
   end

   local method = hs.fnutils.find(module['Method'], function(f)
                                     return f['name'] == name
   end)
   if method then
      return method['signature']
   end

   local variable = hs.fnutils.find(module['Variable'], function(f)
                                       return f['name'] == name
   end)
   if variable then
      return variable['signature']
   end

   local phunction = hs.fnutils.find(module['Function'], function(f)
                                        return f['name'] == name
   end)
   if phunction then
      return phunction['signature']
   end

   return nil
end

function signatureCompletionForText(text)
   local completions = hs.completionsForInputString(text)
   return hs.fnutils.imap(completions, function(fallback)
                             local signature = signatureFromQualifiedName(fallback)
                             if signature then
                                return signature
                             end

                             return fallback
   end)
end

hs.hotkey.bind({"alt"}, "N", ar.window.focusNext)
hs.hotkey.bind({"alt"}, "P", ar.window.focusPrevious)

--
-- ace-window style focused-window switcher.
--
hs.hints.hintChars = {'a','s','d','f','g','h','j','k','l'}
hs.hotkey.bind({"alt"}, "J", hs.hints.windowHints)

-- This must be the last line.
-- hs.notify.new({title="Hammerspoon", informativeText="Reloaded"}):send()
spoon.SpoonInstall:andUse("FadeLogo",
                          {
                             config = {
                                default_run = 1.0,
                             },
                             start = true
})
