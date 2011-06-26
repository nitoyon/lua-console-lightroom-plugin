# Lua Console Lightroom Plugin

## About

This plugin adds "Lua Console" for Lightroom 3.0+, in which you can evaluate lua code.

Example code:

    local LrApplication = import 'LrApplication'
    local catalog = LrApplication.activeCatalog()
    
    local s = ""
    for i  = 0, 5 do
        local photos = catalog:findPhotos {
            searchDesc = {
                 criteria = "rating",
                 operation = "==",
                 value = i,
            }
        }
        s = s .. string.format("Rate %d: %05d photo(s)\\n", i, #photos)
    end
    
    return s

This code reports the distribution of ratio, like:

    Rate 0: 17920 photo(s)
    Rate 1: 00033 photo(s)
    Rate 2: 00023 photo(s)
    Rate 3: 00013 photo(s)
    Rate 4: 00004 photo(s)
    Rate 5: 00010 photo(s)

## How to install

  1. Download a source code.
  2. Open Lightroom's **Plugin Manager**.
  3. Push **Add** button and input **lua-console.lrdevplugin** path.

## How to use

**File** > **Plugin Extras** > **Show Console**

Click **Execute** button to evaluate code.