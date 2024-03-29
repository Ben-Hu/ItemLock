local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Config = ItemLock:NewModule("Config")

local function getOrDefault(db, key)
  local value = db.profile[key]
  if value == nil then
    return Config:Defaults()[key]
  else
    return value
  end
end

local function getFunc(db, key, transform)
  transform = transform or function(...) return ... end

  local func = function()
    local value = getOrDefault(db, key)
    return transform(value)
  end

  return func
end

local function setFunc(db, key, transform)
  transform = transform or function(...) return ... end

  local func = function(_, ...)
    db.profile[key] = transform(...)
    ItemLock:SendMessage("ITEMLOCK_CONFIG_CHANGED")
  end

  return func
end

local function getColourFunc(db, key)
  return getFunc(db, key, function(colour)
    if colour then return unpack(colour) end
  end)
end

local function setColourFunc(db, key)
  return setFunc(db, key, function(r, g, b, a) return { r, g, b, a } end)
end

function Config:Defaults()
  return {
    vendorProtection = true,
    sortLock = true,
    equipmentSetLock = true,
    showTooltip = false,
    logLevel = "WARN",
    lockedBackgroundColor = { 0, 0, 0, 0.5 },
    lockedBorderColor = { 1, 1, 1, 1 },
    lockedBorderThickness = 1.5,
    showLockIcon = true,
    lockIconPosition = "BOTTOMLEFT",
    lockIconSize = 20,
    clickBind = true,
    clickBindButton = "LeftButton",
    clickBindModifier = "ALT"

  }
end

function Config:GetOptions()
  return {
    type = "group",
    name = "ItemLock",
    desc = "ItemLock",
    childGroups = "tab",
    args = {
      description = {
        type = "description",
        name = "Version " .. ItemLock.version
      },
      generalOptions = {
        type = "group",
        name = "General",
        order = 1,
        args = {
          featuresHeader = {
            name = "Features",
            type = "header",
            order = 0,
          },
          vendorProtection = {
            name = "Vendor Protection",
            desc = "If enabled, locked items will become non-interactive when at a vendor.",
            type = "toggle",
            order = 1,
            get = getFunc(self.db, "vendorProtection"),
            set = setFunc(self.db, "vendorProtection")
          },
          sortLock = {
            name = "Item Position Lock",
            desc = "If enabled, items will not be moved by bag sorting. Note: this only works with Bagnon & ElvUI's custom sorting.",
            type = "toggle",
            order = 2,
            get = getFunc(self.db, "sortLock"),
            set = setFunc(self.db, "sortLock")
          },
          equipmentSetLock = {
            name = "Equipment Set Lock",
            desc = "If enabled, any items in your equipment set will be automatically locked.",
            type = "toggle",
            order = 3,
            get = getFunc(self.db, "equipmentSetLock"),
            set = setFunc(self.db, "equipmentSetLock"),
          },
          showTooltip = {
            name = "Tooltip Text",
            desc = "If enabled, locked items will have text added to the tooltip to indicate so.",
            type = "toggle",
            order = 4,
            get = getFunc(self.db, "showTooltip"),
            set = setFunc(self.db, "showTooltip"),
          },
          clickBindHeader = {
            name = "Click Bind",
            type = "header",
            order = 5,
          },
          clickBind = {
            name = "Enable Click Binds",
            desc = "Use mouse button click binds to lock items?",
            type = "toggle",
            order = 6,
            get = getFunc(self.db, "clickBind"),
            set = setFunc(self.db, "clickBind"),
          },
          clickBindButton = {
            name = "Click Bind Button",
            desc = "The mouse button to use for the click bind",
            type = "select",
            values = {
              LeftButton = "LeftButton",
              RightButton = "RightButton",
              MiddleButton = "MiddleButton"
            },
            sorting = { "LeftButton", "RightButton", "MiddleButton" },
            order = 7,
            get = getFunc(self.db, "clickBindButton"),
            set = setFunc(self.db, "clickBindButton"),
          },
          clickBindModifier = {
            name = "Click Bind Modifier",
            desc = "The modifier to use for the click bind",
            type = "select",
            values = {
              CTRL = "CTRL",
              SHIFT = "SHIFT",
              ALT = "ALT"
            },
            sorting = { "CTRL", "SHIFT", "ALT" },
            order = 8,
            get = getFunc(self.db, "clickBindModifier"),
            set = setFunc(self.db, "clickBindModifier"),
          },
          debugHeader = {
            name = "Debug",
            type = "header",
            order = 9,
          },
          logLevel = {
            name = "Log Level",
            desc = "Determines the minimum level/type of log messages to be printed.",
            type = "select",
            values = {
              DEBUG = "DEBUG",
              INFO = "INFO",
              WARN = "WARN",
              ERROR = "ERROR"
            },
            sorting = { "DEBUG", "INFO", "WARN", "ERROR" },
            order = 10,
            get = getFunc(self.db, "logLevel"),
            set = setFunc(self.db, "logLevel"),
          },
        },
      },
      appearanceOptions = {
        type = "group",
        name = "Appearance",
        order = 2,
        args = {
          lockedBackgroundColor = {
            name = "Locked Background Color",
            desc = "The color of the overlay's background for locked items.",
            type = "color",
            hasAlpha = true,
            order = 1,
            get = getColourFunc(self.db, "lockedBackgroundColor"),
            set = setColourFunc(self.db, "lockedBackgroundColor")
          },
          lockedBorderColor = {
            name = "Locked Border Color",
            desc = "The color of the border for locked items.",
            type = "color",
            hasAlpha = true,
            order = 2,
            get = getColourFunc(self.db, "lockedBorderColor"),
            set = setColourFunc(self.db, "lockedBorderColor")
          },
          lockedBorderThickness = {
            name = "Locked Border Thickness",
            desc = "The thickness of the border for locked items.",
            type = "range",
            min = 0,
            max = 5,
            order = 3,
            get = getFunc(self.db, "lockedBorderThickness"),
            set = setFunc(self.db, "lockedBorderThickness")
          },
          showLockIcon = {
            name = "Show Lock Icon",
            desc = "Show the lock icon on locked items.",
            type = "toggle",
            order = 4,
            get = getFunc(self.db, "showLockIcon"),
            set = setFunc(self.db, "showLockIcon")
          },
          lockIconPosition = {
            name = "Lock Icon Position",
            desc = "The position of the lock icon on locked items.",
            type = "select",
            values = {
              CENTER = "CENTER",
              LEFT = "LEFT",
              RIGHT = "RIGHT",
              BOTTOMLEFT = "BOTTOMLEFT",
              BOTTOMRIGHT = "BOTTOMRIGHT",
              TOPLEFT = "TOPLEFT",
              TOPRIGHT = "TOPRIGHT",
            },
            order = 5,
            get = getFunc(self.db, "lockIconPosition"),
            set = setFunc(self.db, "lockIconPosition")
          },
          lockIconSize = {
            name = "Lock Icon Size",
            desc = "The size of the lock icon on locked items.",
            type = "range",
            min = 0,
            max = 50,
            order = 6,
            get = getFunc(self.db, "lockIconSize"),
            set = setFunc(self.db, "lockIconSize")
          }
        }
      },
      profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    }
  }
end

function Config:Init(addon)
  self.db = LibStub("AceDB-3.0"):New("ItemLockConfig", { profile = self:Defaults() })
  self.db.RegisterCallback(addon, "OnProfileChanged", "UpdateSlots")
  self.db.RegisterCallback(addon, "OnProfileCopied", "UpdateSlots")
  self.db.RegisterCallback(addon, "OnProfileReset", "UpdateSlots")

  LibStub("AceConfig-3.0"):RegisterOptionsTable("ItemLock", self:GetOptions())
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ItemLock", "ItemLock")
end

function Config:OpenOptionsFrame()
  -- https://github.com/Stanzilla/WoWUIBugs/issues/89
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function Config:IsVendorProtectionEnabled()
  return getOrDefault(self.db, "vendorProtection")
end

function Config:IsSortLockEnabled()
  return getOrDefault(self.db, "sortLock")
end

function Config:IsEquipmentSetLockEnabled()
  return getOrDefault(self.db, "equipmentSetLock")
end

function Config:IsShowTooltipEnabled()
  return getOrDefault(self.db, "showTooltip")
end

function Config:IsClickBindEnabled()
  return getOrDefault(self.db, "clickBind")
end

function Config:GetClickBindButton()
  return getOrDefault(self.db, "clickBindButton")
end

function Config:GetClickBindModifier()
  return getOrDefault(self.db, "clickBindModifier")
end

function Config:GetLogLevel()
  return getOrDefault(self.db, "logLevel")
end

function Config:GetLockedBackgroundColor()
  return getOrDefault(self.db, "lockedBackgroundColor")
end

function Config:GetLockedBorderColor()
  return getOrDefault(self.db, "lockedBorderColor")
end

function Config:GetLockedBorderThickness()
  return getOrDefault(self.db, "lockedBorderThickness")
end

function Config:IsShowLockIcon()
  return getOrDefault(self.db, "showLockIcon")
end

function Config:GetLockIconPosition()
  return getOrDefault(self.db, "lockIconPosition")
end

function Config:GetLockIconSize()
  return getOrDefault(self.db, "lockIconSize")
end
