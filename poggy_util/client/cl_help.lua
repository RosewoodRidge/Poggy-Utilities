-- ============================================================================
-- POGGY HELP SYSTEM - Client Script
-- Opens a futuristic help/tutorial UI with searchable categories
-- Command: /help
-- ============================================================================

local helpOpen = false

local function Debug(msg)
    if Config and Config.PoggyDebug and Config.PoggyDebug.Enabled then
        print("^3[POGGY-HELP]^7 " .. msg)
    end
end

-- ============================================================================
-- OPEN / CLOSE
-- ============================================================================
local function OpenHelp()
    if helpOpen then return end
    helpOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action     = "openHelp",
        categories = Config.HelpData or {}
    })
    Debug("Help opened with " .. #(Config.HelpData or {}) .. " categories")
end

local function CloseHelp()
    if not helpOpen then return end
    helpOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeHelp" })
    Debug("Help closed")
end

-- ============================================================================
-- NUI CALLBACKS
-- ============================================================================
RegisterNUICallback('closeHelp', function(_, cb)
    CloseHelp()
    cb('ok')
end)

-- ============================================================================
-- COMMANDS
-- ============================================================================
RegisterCommand('help', function()
    if helpOpen then
        CloseHelp()
    else
        OpenHelp()
    end
end, false)

-- ============================================================================
-- UNSTUCK FROM HELP UI
-- ============================================================================
RegisterNUICallback('unstuckFromHelp', function(_, cb)
    CloseHelp()
    ExecuteCommand('unstuck')
    cb('ok')
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================
exports('OpenHelp', OpenHelp)
exports('CloseHelp', CloseHelp)

print("^2[poggy_util]^7 Help system loaded (/help)")
