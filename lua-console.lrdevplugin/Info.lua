--[[----------------------------------------------------------------------------

Info.lua
Summary information for Lua Console plug-in.

Adds two menu items to Lightroom.

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'com.nitoyon.lr.console',

	LrPluginName = LOC "$$$/Console/PluginName=Lua Console",

	LrExportMenuItems = {
		title = "Show Console",
		file = "Console.lua",
	},

	VERSION = { major=3, minor=0, revision=0, build=200000, },

}


	