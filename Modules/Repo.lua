local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Repo = ItemLock:NewModule("Repo")

function Repo:Init(db)
  self.db = db
  return self
end

function Repo:Profiles()
  return LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
end

function Repo:Get(key)
  return self.db.profile[key]
end

function Repo:Set(key, value)
  self.db.profile[key] = value
end

function Repo:ResetLockedItems()
  self:Set("lockedItems", {})
end

function Repo:SetEquipmentSetItemIDs(itemIDs)
  self:Set("equipmentSetItemIDs", itemIDs)
end

function Repo:IsItemInEquipmentSet(itemID)
  for equipmentItemID in pairs(self:Get("equipmentSetItemIDs")) do
    if equipmentItemID == itemID then return true end
  end

  return false
end

function Repo:GetLockedItemIDs()
  local lockedItemIDs = {}

  for itemID, isLocked in pairs(self:Get("lockedItems")) do
    if (isLocked) then
      tinsert(lockedItemIDs, itemID)
    end
  end

  if self:Get("equipmentSetLock") then
    for itemID in pairs(self:Get("equipmentSetItemIDs")) do
      tinsert(lockedItemIDs, itemID)
    end
  end

  return lockedItemIDs
end

function Repo:ToggleItemLock(itemID)
  if itemID == nil then return end

  if self:IsItemLocked(itemID) then
    self:UnlockItem(itemID)
  else
    self:LockItem(itemID)
  end
end

function Repo:IsItemLocked(itemID)
  local isLockedItem = self:Get("lockedItems")[itemID] or false

  if self:Get("equipmentSetLock") then
    local isEquipmentSetItem = self:Get("equipmentSetItemIDs")[itemID] or false
    return isLockedItem or isEquipmentSetItem
  else
    return isLockedItem
  end
end

function Repo:UnlockItem(itemID)
  self:Get("lockedItems")[itemID] = false
end

function Repo:LockItem(itemID)
  self:Get("lockedItems")[itemID] = true
end
