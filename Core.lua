local ItemLock = LibStub("AceAddon-3.0"):NewAddon("ItemLock", "AceConsole-3.0", "AceEvent-3.0")

function ItemLock:OnInitialize()
  self.isMerchantOpen = false

  self.repo = self:GetModule("Repo")
  self.config = self:GetModule("Config")
  self.sorting = self:GetModule("Sorting")
  self.slot = self:GetModule("Slot")
  self.utils = self:GetModule("Utils")

  self.repo:Init()
  self.config:Init(self)
  self.sorting:Init(self.repo, self.config)

  self:RegisterChatCommand("il", "SlashCommand")
  self:RegisterChatCommand("itemlock", "SlashCommand")
end

function ItemLock:SlashCommand(cmd)
  cmd = cmd:trim()

  if cmd == "list" or cmd == "ls" then
    for idx, itemID in pairs(self.repo:GetLockedItemIDs(self.config)) do
      self:Print(tostring(idx) .. ".", Item:CreateFromItemID(itemID):GetItemLink())
    end
  elseif cmd == "lock" then
    self:ToggleCurrentItemLock()
  elseif cmd == "reset" then
    self.repo:ResetLockedItems()
    self:UpdateSlots()
  else
    self:GetModule("Config"):OpenOptionsFrame()
  end
end

function ItemLock:OnEnable()
  self:RegisterEvent("DELETE_ITEM_CONFIRM")
  self:RegisterEvent("MERCHANT_CLOSED")
  self:RegisterEvent("MERCHANT_SHOW")
  self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
  self:RegisterEvent("PLAYER_LOGIN")
  self:RegisterEvent("BAG_UPDATE")
  self:RegisterMessage("ITEMLOCK_CONFIG_CHANGED", "CONFIG_CHANGED")
end

function ItemLock:DELETE_ITEM_CONFIRM(_event, itemName)
  local _itemName, itemLink = GetItemInfo(itemName)
  local itemID = self.utils:ItemLinkToItemID(itemLink)
  if self.repo:IsItemLocked(itemID, self.config) then
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

function ItemLock:PLAYER_LOGIN()
  self:LoadEquipmentSets()
  self:UpdateSlots()
end

function ItemLock:CONFIG_CHANGED()
  self:LoadEquipmentSets()
  self:UpdateSlots()
end

function ItemLock:BAG_UPDATE(...)
  -- handle updates only for the default UI, all Bagnon's updates
  -- are handled via the post hook for Bagnon.Item.Update
  if not IsAddOnLoaded("Bagnon") then
    local event, bagIndex = ...
    local bagID = bagIndex + 1
    local bag = _G["ContainerFrame" .. bagID]

    if bag then
      -- event fires twice in Classic with -2 bagIndex for the backpack in classic for some reason
      local bagName = bag:GetName()
      local bagSize = GetContainerNumSlots(bagIndex)

      for itemIndex = 1, bagSize, 1 do
        local slotIndex = bagSize - itemIndex + 1
        local slotFrame = _G[bagName .. "Item" .. slotIndex]
        ItemLock:UpdateSlot(bagIndex, slotFrame)
      end
    end
  end
end

function ItemLock:ToggleCurrentItemLock()
  local itemID = self.utils:GetTooltipItemID()
  if not itemID then return end

  self.repo:ToggleItemLock(itemID, self.config)

  if self.config:IsVerboseEnabled() then
    local itemLink = Item:CreateFromItemID(itemID):GetItemLink()

    if self.config:IsEquipmentSetLockEnabled() and
        self.repo:IsItemInEquipmentSet(itemID) then
      self:Print(
        itemLink,
        "belongs to an equipment set and will remain locked as equipment set locking is enabled."
      )
    elseif self.repo:IsItemLocked(itemID, self.config) then
      self:Print(itemLink, "locked")
    else
      self:Print(itemLink, "unlocked")
    end

  end

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

  if item:IsItemEmpty() or self.repo:IsItemLocked(item:GetItemID(), self.config) ~= true then
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

function ItemLock:SetGameTooltip(tooltip)
  if not self.config:IsShowTooltipEnabled() then return end

  local _itemName, itemLink = tooltip:GetItem()
  local itemID = ItemLock:GetModule("Utils"):ItemLinkToItemID(itemLink)
  if itemID and self.repo:IsItemLocked(itemID, self.config) then
    tooltip:AddLine("Locked - ItemLock")
  end
end

-- Default UI
if _G.ContainerFrame_OnShow then
  hooksecurefunc("ContainerFrame_OnShow", function()
    ItemLock:UpdateSlots()
  end)
end

GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
  ItemLock:SetGameTooltip(tooltip)
end)


-- Bagnon
if IsAddOnLoaded("Bagnon") then
  hooksecurefunc(Bagnon.Item, "Update", function(slotFrame)
    local bagID = slotFrame:GetBag()
    ItemLock:UpdateSlot(bagID, slotFrame)
  end)
end

-- ElvUI
if IsAddOnLoaded("ElvUI") then
  local E, L, V, P, G = unpack(ElvUI)

  hooksecurefunc(E:GetModule("Bags"), "UpdateSlot", function(self, frame, bagID, slotID)
    local bag = frame.Bags[bagID]
    local slot = bag and bag[slotID]
    ItemLock:UpdateSlot(bagID, slot)
  end)
end
