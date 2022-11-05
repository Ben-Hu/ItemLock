local ItemLock = LibStub("AceAddon-3.0"):NewAddon("ItemLock", "AceConsole-3.0", "AceEvent-3.0")
ItemLock.version = GetAddOnMetadata("ItemLock", "Version")

function ItemLock:OnInitialize()
  self.isMerchantOpen = false

  self.repo = self:GetModule("Repo")
  self.config = self:GetModule("Config")
  self.logger = self:GetModule("Logger")
  self.slot = self:GetModule("Slot")
  self.utils = self:GetModule("Utils")
  self.tooltip = self:GetModule("Tooltip")

  self.repo:Init()
  self.config:Init(self)
  self.logger:Init(self.config)
  self.tooltip:Init(self.repo, self.config)

  self:LoadPlugins()

  self:RegisterChatCommand("il", "SlashCommand")
  self:RegisterChatCommand("itemlock", "SlashCommand")
end

function ItemLock:SlashCommand(cmd)
  cmd = cmd:trim()

  if cmd == "list" or cmd == "ls" then
    for idx, itemID in pairs(self.repo:GetLockedItemIDs(self.config)) do
      self.logger:Print(tostring(idx) .. ".", Item:CreateFromItemID(itemID):GetItemLink())
    end
  elseif cmd == "lock" then
    self:ToggleCurrentItemLock()
  elseif cmd == "reset" then
    self.repo:ResetLockedItems()
    self:UpdateSlots()
  elseif cmd == "version" or cmd == "v" then
    self.logger:Print("version", ItemLock.version)
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
  self:RegisterMessage("ITEMLOCK_CONFIG_CHANGED", "CONFIG_CHANGED")
end

function ItemLock:DELETE_ITEM_CONFIRM(_event, itemName)
  local _itemName, itemLink = GetItemInfo(itemName)
  local itemID = self.utils:ItemLinkToItemID(itemLink)
  if self.repo:IsItemLocked(itemID, self.config) then
    self.logger:Warn(self.logger:Red("DELETING A LOCKED ITEM"), itemLink)
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

function ItemLock:ToggleCurrentItemLock()
  local itemID = self.utils:GetTooltipItemID()
  if not itemID then return end

  self.repo:ToggleItemLock(itemID, self.config)

  local itemLink = Item:CreateFromItemID(itemID):GetItemLink()

  if self.config:IsEquipmentSetLockEnabled() and
      self.repo:IsItemInEquipmentSet(itemID) then
    self.logger:Info(
      itemLink,
      "belongs to an equipment set and will remain locked as equipment set locking is enabled."
    )
  elseif self.repo:IsItemLocked(itemID, self.config) then
    self.logger:Info("locked", itemLink)
  else
    self.logger:Info("unlocked", itemLink)
  end

  self:UpdateSlots()
end

function ItemLock:UpdateSlots()
  for bagID, slotFrames in pairs(self.utils:GetSlotsByBagID(self.plugin)) do
    for _idx, slotFrame in pairs(slotFrames) do
      self:UpdateSlot(bagID, slotFrame)
    end
  end
end

function ItemLock:UpdateSlot(bagID, slotFrame)
  if not slotFrame then return end

  local slotID = slotFrame:GetID()
  local item = Item:CreateFromBagAndSlot(bagID, slotID)

  if item:IsItemEmpty() or self.repo:IsItemLocked(item:GetItemID(), self.config) ~= true then
    self.slot:Setup(slotFrame, false, true, self.config)
  else
    local isInteractable = not self.isMerchantOpen or not self.config:IsVendorProtectionEnabled()
    self.logger:Debug("Locked Item at", slotFrame:GetName())
    self.slot:Setup(slotFrame, true, isInteractable, self.config)
  end
end

function ItemLock:LoadEquipmentSets()
  local itemIDs = self.utils:GetEquipmentSetItemIDs()
  self.repo:SetEquipmentSetItemIDs(itemIDs)
end

function ItemLock:LoadPlugins()
  if IsAddOnLoaded("Bagnon") or IsAddOnLoaded("Combuctor") then
    self.plugin = self:GetModule("PluginBagnonCombuctor")
  elseif IsAddOnLoaded("ArkInventory") then
    self.plugin = self:GetModule("PluginArkInventory")
  elseif IsAddOnLoaded("LiteBag") then
    self.plugin = self:GetModule("PluginLiteBag")
  elseif IsAddOnLoaded("AdiBags") then
    self.plugin = self:GetModule("PluginAdiBags")
  elseif IsAddOnLoaded("ElvUI") then
    self.plugin = self:GetModule("PluginElvUI")
  else
    self.plugin = self:GetModule("PluginDefault")
  end

  self.plugin:Init(self.repo, self.config)
  self.logger:Debug(self.plugin:GetName(), "loaded")
end
