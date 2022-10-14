local ItemLock = LibStub("AceAddon-3.0"):NewAddon("ItemLock", "AceConsole-3.0", "AceEvent-3.0")

local function initDB(addon)
  local defaults = { lockedItems = {}, equipmentSetItemIDs = {} }
  for key, val in ipairs(addon.config:Defaults()) do defaults[key] = val end

  local db = LibStub("AceDB-3.0"):New("ItemLockDB", { profile = defaults })
  db.RegisterCallback(addon, "OnProfileChanged", "UpdateSlots")
  db.RegisterCallback(addon, "OnProfileCopied", "UpdateSlots")
  db.RegisterCallback(addon, "OnProfileReset", "UpdateSlots")

  return db
end

function ItemLock:OnInitialize()
  self.isMerchantOpen = false

  self.repo = self:GetModule("Repo")
  self.config = self:GetModule("Config")
  self.sorting = self:GetModule("Sorting")
  self.slot = self:GetModule("Slot")
  self.utils = self:GetModule("Utils")

  local db = initDB(self)
  self.repo:Init(db)
  self.config:Init(self.repo)
  self.sorting:Init(self.repo, self.config)

  self:RegisterChatCommand("il", "SlashCommand")
  self:RegisterChatCommand("itemlock", "SlashCommand")
end

function ItemLock:SlashCommand(cmd)
  cmd = cmd:trim()

  if cmd == "list" or cmd == "ls" then
    for idx, itemID in pairs(self.repo:GetLockedItemIDs()) do
      self:Print(tostring(idx) .. ".", Item:CreateFromItemID(itemID):GetItemLink())
    end
  elseif cmd == "lock" then
    self:ToggleCurrentItemLock()
  elseif cmd == "reset" then
    self.repo:ResetLockedItems()
  else
    self:GetModule("Config"):OpenOptionsFrame()
  end
end

function ItemLock:OnEnable()
  self:RegisterEvent("DELETE_ITEM_CONFIRM")
  self:RegisterEvent("MERCHANT_CLOSED")
  self:RegisterEvent("MERCHANT_SHOW")
  self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
  self:RegisterEvent("VARIABLES_LOADED")
  self:RegisterMessage("ITEMLOCK_CONFIG_CHANGED", "CONFIG_CHANGED")
end

function ItemLock:DELETE_ITEM_CONFIRM(_event, itemName)
  local _itemName, itemLink = GetItemInfo(itemName)
  local itemID = self.utils:ItemLinkToItemID(itemLink)
  if self.repo:IsItemLocked(itemID) then
    self:Print("|cFFFF0000WARNING - DELETING A LOCKED ITEM|r", itemLink)
  end
end

function ItemLock:MERCHANT_CLOSED()
  self.isMerchantOpen = false
  self:UpdateSlots()
end

function ItemLock:MERCHANT_SHOW()
  self.isMerchantOpen = true
  self:UpdateSlots()
end

function ItemLock:EQUIPMENT_SETS_CHANGED()
  self:LoadEquipmentSets()
  self:UpdateSlots()
end

function ItemLock:VARIABLES_LOADED()
  self:LoadEquipmentSets()
end

function ItemLock:CONFIG_CHANGED()
  self:LoadEquipmentSets()
  self:UpdateSlots()
end

function ItemLock:ToggleCurrentItemLock()
  local itemID = self.utils:GetTooltipItemID()

  if self.config:IsEquipmentSetLockEnabled() and
      self.repo:IsItemInEquipmentSet(itemID) then
    self:Print(
      Item:CreateFromItemID(itemID):GetItemLink(),
      "belongs to an equipment set and will remain locked as equipment set locking is enabled."
    )
  end

  self.repo:ToggleItemLock(itemID)
  self:UpdateSlots()
end

function ItemLock:UpdateSlots()
  for bagID, slotFrames in pairs(self.utils:GetSlotsByBagID()) do
    for _idx, slotFrame in pairs(slotFrames) do
      self:UpdateSlot(bagID, slotFrame)
    end
  end
end

function ItemLock:UpdateSlot(bagID, slotFrame)
  local slotID = slotFrame:GetID()
  local item = Item:CreateFromBagAndSlot(bagID, slotID)

  if item:IsItemEmpty() or self.repo:IsItemLocked(item:GetItemID()) ~= true then
    self.slot:Setup(slotFrame, false, true, self.config)
  else
    local isInteractable = not self.isMerchantOpen or not self.config:IsVendorProtectionEnabled()
    self.slot:Setup(slotFrame, true, isInteractable, self.config)
  end
end

function ItemLock:LoadEquipmentSets()
  local itemIDs = self.utils:GetEquipmentSetItemIDs()
  self.repo:SetEquipmentSetItemIDs(itemIDs)
end

-- Default Bags
hooksecurefunc("ContainerFrame_Update", function(bag)
  local bagID = bag:GetID()
  local bagName = bag:GetName()
  for itemIndex = 1, bag.size, 1 do
    local slotFrame = _G[bagName .. "Item" .. itemIndex]
    ItemLock:UpdateSlot(bagID, slotFrame)
  end
end)

-- Bagnon
if IsAddOnLoaded("Bagnon") then
  hooksecurefunc(Bagnon.Item, "Update", function(slotFrame)
    local bagID = slotFrame:GetBag()
    ItemLock:UpdateSlot(bagID, slotFrame)
  end)
end
