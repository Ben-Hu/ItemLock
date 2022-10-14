local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Config = ItemLock:NewModule("Config")

local function getFunc(repo, key, transform)
  transform = transform or function(...) return ... end
  return function() return transform(repo:Get(key)) end
end

local function setFunc(repo, key, transform)
  transform = transform or function(...) return ... end

  local func = function(_, ...)
    repo:Set(key, transform(...))
    ItemLock:SendMessage("ITEMLOCK_CONFIG_CHANGED")
  end

  return func
end

local function getColourFunc(repo, key)
  return getFunc(repo, key, function(colour)
    if colour then return unpack(colour) end
  end)
end

local function setColourFunc(repo, key)
  return setFunc(repo, key, function(r, g, b, a) return { r, g, b, a } end)
end

function Config:Defaults()
  return {
    vendorProtection = true,
    sortLock = true,
    equipmentSetLock = true,
    lockedBackgroundColor = { 0, 0, 0, 0 },
    lockedBorderColor = { 1, 1, 1, 1 }
  }
end

function Config:GetOptions()
  return {
    type = "group",
    name = "ItemLock",
    desc = "ItemLock",
    childGroups = "tab",
    args = {
      generalOptions = {
        type = "group",
        name = "General",
        order = 1,
        args = {
          vendorProtection = {
            name = "Vendor Protection",
            desc = "If enabled, locked items will become non-interactive when at a vendor.",
            type = "toggle",
            order = 1,
            set = setFunc(self.repo, "vendorProtection"),
            get = getFunc(self.repo, "vendorProtection")
          },
          sortLock = {
            name = "Item Position Lock",
            desc = "If enabled, items will not be moved by bag sorting.",
            type = "toggle",
            order = 2,
            set = setFunc(self.repo, "sortLock"),
            get = getFunc(self.repo, "sortLock")
          },
          equipmentSetLock = {
            name = "Equipment Set Lock",
            desc = "If enabled, any items in your equipment set will be automatically locked.",
            type = "toggle",
            order = 3,
            set = setFunc(self.repo, "equipmentSetLock"),
            get = getFunc(self.repo, "equipmentSetLock")
          }
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
            get = getColourFunc(self.repo, "lockedBackgroundColor"),
            set = setColourFunc(self.repo, "lockedBackgroundColor")
          },
          lockedBorderColor = {
            name = "Locked Border Color",
            desc = "The color of the border for locked items.",
            type = "color",
            hasAlpha = true,
            order = 2,
            get = getColourFunc(self.repo, "lockedBorderColor"),
            set = setColourFunc(self.repo, "lockedBorderColor")
          }
        }
      },
      profiles = self.repo:Profiles()
    }
  }
end

function Config:Init(repo)
  self.repo = repo
  LibStub("AceConfig-3.0"):RegisterOptionsTable("ItemLock", self:GetOptions())
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ItemLock", "ItemLock")
end

function Config:OpenOptionsFrame()
  -- https://github.com/Stanzilla/WoWUIBugs/issues/89
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function Config:IsVendorProtectionEnabled()
  return self.repo:Get("vendorProtection") or self:Defaults()["vendorProtection"]
end

function Config:IsSortLockEnabled()
  return self.repo:Get("sortLock") or self:Defaults()["sortLock"]
end

function Config:IsEquipmentSetLockEnabled()
  return self.repo:Get("equipmentSetLock") or self:Defaults()["equipmentSetLock"]
end

function Config:GetLockedBackgroundColor()
  return self.repo:Get("lockedBackgroundColor") or self:Defaults()["lockedBackgroundColor"]
end

function Config:GetLockedBorderColor()
  return self.repo:Get("lockedBorderColor") or self:Defaults()["lockedBorderColor"]
end
