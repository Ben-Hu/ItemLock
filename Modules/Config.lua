local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Config = ItemLock:NewModule("Config")

local function getFunc(repo, key)
  return function() return repo:Get(key) end
end

local function setFunc(repo, key)
  local func = function(_, value)
    repo:Set(key, value)
    ItemLock:SendMessage("ITEMLOCK_CONFIG_CHANGED")
  end

  return func
end

function Config:Defaults()
  return {
    vendorProtection = true,
    sortLock = true,
    equipmentSetLock = true
  }
end

function Config:GetOptions()
  return {
    type = "group",
    args = {
      vendorProtection = {
        type = "toggle",
        name = "Vendor Protection",
        desc = "If enabled, locked items will become non-interactive when at a vendor.",
        set = setFunc(self.repo, "vendorProtection"),
        get = getFunc(self.repo, "vendorProtection")
      },
      sortLock = {
        type = "toggle",
        name = "Item Position Lock",
        desc = "If enabled, items will not be moved by bag sorting.",
        set = setFunc(self.repo, "sortLock"),
        get = getFunc(self.repo, "sortLock")
      },
      equipmentSetLock = {
        type = "toggle",
        name = "Equipment Set Lock",
        desc = "If enabled, any items in your equipment set will be automatically locked.",
        set = setFunc(self.repo, "equipmentSetLock"),
        get = getFunc(self.repo, "equipmentSetLock")
      }
    }
  }
end

function Config:Init(repo)
  self.repo = repo
  LibStub("AceConfig-3.0"):RegisterOptionsTable("ItemLock", self:GetOptions())
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ItemLock", "ItemLock")

  LibStub("AceConfig-3.0"):RegisterOptionsTable("ItemLock_Profiles", repo:Profiles())
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ItemLock_Profiles", "Profiles", "ItemLock")
end

function Config:OpenOptionsFrame()
  -- https://github.com/Stanzilla/WoWUIBugs/issues/89
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function Config:IsVendorProtectionEnabled()
  return self.repo:Get("vendorProtection") or false
end

function Config:IsSortLockEnabled()
  return self.repo:Get("sortLock") or false
end

function Config:IsEquipmentSetLockEnabled()
  return self.repo:Get("equipmentSetLock") or false
end
