--[[----------------------------------------------------------------------------

Console.lua

------------------------------------------------------------------------------]]


-- Access the Lightroom SDK namespaces.
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrTasks = import 'LrTasks'
local LrPrefs = import 'LrPrefs'
local LrShell = import 'LrShell'
local f = LrView.osFactory()

local bind = LrView.bind
local prefs = LrPrefs.prefsForPlugin()
local Newline = WIN_ENV and "\r\n" or "\n"
local AccessKey = WIN_ENV and "&" or ""

local function initText(prefs)
	local text = "local LrApplication = import 'LrApplication'\n" ..
		'local catalog = LrApplication.activeCatalog()\n' ..
		'\n' ..
		'local s = ""\n' ..
		'for i  = 0, 5 do\n' ..
		'    local photos = catalog:findPhotos {\n' ..
		'        searchDesc = {\n' ..
		'             criteria = "rating",\n' ..
		'             operation = "==",\n' ..
		'             value = i,\n' ..
		'        }\n' ..
		'    }\n' ..
		'    s = s .. string.format("Rate %d: %05d photo(s)\\n", i, #photos)\n' ..
		'end\n' ..
		'\n' ..
		'return s\n'
	prefs.consoleText = text:gsub("\n", Newline)
end

local function showSdkPathDialog(prefs, prop)
	prop.sdk_path = prefs.sdk_path

	local verb = LrDialogs.presentModalDialog {
		title = "SDK Path",
		contents = f:column {
			bind_to_object = prop,
			f:static_text {
				title = 'Manual PDF Path:',
			},
			f:row{
				fill = 1,
				f:edit_field {
					fill = 1,
					width_in_chars = 30,
					value = bind 'sdk_path',
				},
				f:push_button {
					title = AccessKey .. 'Browse',
					action = function()
						local path = LrDialogs.runOpenPanel {
							fileTypes = 'pdf',
							initialDirectory = prop.sdk_path,
						}
						if path then
							prop.sdk_path = path[1]
						end
					end
				},
			},
		},
	}

	if verb == 'ok' then
		prefs.sdk_path = LrPathUtils.parent(LrPathUtils.parent(prop.sdk_path))
	end
end

local function executeSdkPath(prefs, prop, relative_path)
	if prefs.sdk_path then
		local target_path = LrPathUtils.child(prefs.sdk_path, relative_path)
		if not LrFileUtils.exists(target_path) then
			showSdkPathDialog(prefs, prop)
		end
	else
		showSdkPathDialog(prefs, prop)
	end

	local target_path = LrPathUtils.child(prefs.sdk_path, relative_path)

	-- use default app
	if WIN_ENV then
		LrShell.openFilesInApp({""}, target_path)
	else
		LrShell.openFilesInApp({target_path}, "open")
	end
end

LrFunctionContext.callWithContext('consoleDialog', function(context)
	LrDialogs.attachErrorDialogToFunctionContext(context)
	local prop = LrBinding.makePropertyTable(context)

	if not prefs.consoleText then
		initText(prefs)
	end
	prop.text = prefs.consoleText

	-- Create the contents for the dialog.
	local c = f:column {
		fill = 1,
		bind_to_object = prop,
		f:static_text {
			fill = 1,
			title = "Command:",
		},
		f:row {
			fill = 1,
			f:edit_field {
				fill = 1,
				width_in_chars = 40,
				height_in_lines = 20,
				value = bind 'text',
			},
		},
	}
	local a = f:row {
		bind_to_object = prop,
		f:push_button {
			title = AccessKey .. "API Reference",
			action = function()
				executeSdkPath(prefs, prop, 'Manual\\Lightroom SDK Guide.pdf')
			end
		},
		f:push_button {
			title = "SDK " .. AccessKey .. "Manual",
			action = function()
				executeSdkPath(prefs, prop, 'API Reference\\index.html')
			end
		},
	}

	while true do
		-- show dialog
		local verb = LrDialogs.presentModalDialog {
			title = "Lightroom Lua Console",
			contents = c,
			accessoryView = a,
			resizable = true,
			actionVerb = 'Exec',
			save_frame = 'consoleDlgPosition',
		}

		-- cancel
		if verb == "cancel" then break end

		-- exec
		prefs.consoleText = prop.text
		local func, msg = loadstring(prop.text)
		if not func then
			LrDialogs.message("failed", msg, "info" );
			return
		end

		-- call the func async
		LrTasks.startAsyncTask(function()
			local status, ret = LrTasks.pcall(func)
			if status then
				LrDialogs.message( "result", tostring(ret), "info" );
			else
				LrDialogs.message( "error", ret, "warning" );
			end
		end)
	end
end)

