local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Repo = ItemLock:NewModule("Repo")

function Repo:Init()
  local defaults = { lockedItems = {}, equipmentSetItemIDs = {} }
  self.db = LibStub("AceDB-3.0"):New("ItemLockRepo", { profile = defaults })
end

function Repo:ResetLockedItems()
  self.db.profile.lockedItems = {}
end

function Repo:SetEquipmentSetItemIDs(itemIDs)
  self.db.profile.equipmentSetItemIDs = itemIDs
end

function Repo:IsItemInEquipmentSet(itemID)
  for equipmentItemID in pairs(self.db.profile.equipmentSetItemIDs) do
    if equipmentItemID == itemID then return true end
  end

  return false
end

function Repo:GetLockedItemIDs(config)
  local lockedItemIDs = {}

  for itemID, isLocked in pairs(self.db.profile.lockedItems) do
    if (isLocked) then
      tinsert(lockedItemIDs, itemID)
    end
  end

  if config:IsEquipmentSetLockEnabled() then
    for itemID in pairs(self.db.profile.equipmentSetItemIDs) do
      tinsert(lockedItemIDs, itemID)
    end
  end

  return lockedItemIDs
end

function Repo:ToggleItemLock(itemID, config)
  if itemID == nil then return end

  if self:IsItemLocked(itemID, config) then
    self:UnlockItem(itemID)
  else
    self:LockItem(itemID)
  end
end

function Repo:IsItemLocked(itemID, config)
  local isLockedItem = self.db.profile.lockedItems[itemID] or false

  if config:IsEquipmentSetLockEnabled() then
    local isEquipmentSetItem = self.db.profile.equipmentSetItemIDs[itemID] or false
    return isLockedItem or isEquipmentSetItem
  else
    return isLockedItem
  end
end

function Repo:UnlockItem(itemID)
  self.db.profile.lockedItems[itemID] = false
end

function Repo:LockItem(itemID)
  self.db.profile.lockedItems[itemID] = true
end
