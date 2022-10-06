local name, ns = ...

function ns.Print(...) print("|cFFFF8400[" .. name .. "]|r", ...) end

if (LockedItems == nil) then
  LockedItems = {}
end

if (LockedItemNames == nil) then
  LockedItemNames = {}
end

if (EquipmentSetItemIds == nil) then
  EquipmentSetItemIds = {}
end

if (Config == nil) then
  Config = { sort_lock = false, set_lock = true }
end

IsMerchantOpen = false

local function LockItem(itemID)
  local item = Item:CreateFromItemID(itemID)
  LockedItems[itemID] = true;
  LockedItemNames[item:GetItemName()] = itemID;
  ns.Print("locked", item:GetItemLink())
end

local function UnlockItem(itemID)
  local item = Item:CreateFromItemID(itemID)
  LockedItems[itemID] = false;
  LockedItemNames[item:GetItemName()] = itemID;
  if Config["set_lock"] and EquipmentSetItemIds[itemID] then
    ns.Print(
      item:GetItemLink(),
      " remains locked since set_lock is enabled and is part of a set. ",
      "It will be unlocked when set_lock is disabled."
    )
  else
    ns.Print("unlocked", item:GetItemLink())
  end
end

local function isItemLocked(itemID)
  if Config["set_lock"] then
    return (EquipmentSetItemIds[itemID] or false) or (LockedItems[itemID] or false)
  else
    return (LockedItems[itemID] or false)
  end
end

local function getLockedItemIDs()
  local lockedItemIDs = {}

  for itemID, isLocked in pairs(LockedItems) do
    if (isLocked) then
      lockedItemIDs[itemID] = true
    end
  end

  if Config["set_lock"] then
    for itemID, _ in pairs(EquipmentSetItemIds) do
      lockedItemIDs[itemID] = true
    end
  end

  return lockedItemIDs
end

local function SetupSlotOverlay(slot)
  if slot.lockItemsInteractionOverlay then
    return slot.lockItemsInteractionOverlay, slot.lockItemsOverlay, slot.lockItemsOverlayTexture
  end

  slot.lockItemsInteractionOverlay = CreateFrame("FRAME", nil, slot)
  slot.lockItemsInteractionOverlay:SetFrameLevel(0)
  slot.lockItemsInteractionOverlay:SetSize(slot:GetSize())
  slot.lockItemsInteractionOverlay:SetPoint("CENTER")
  slot.lockItemsInteractionOverlay:SetScript("OnMouseDown", function(self, button) end)

  slot.lockItemsOverlay = CreateFrame("FRAME", nil, slot, "BackdropTemplate")
  slot.lockItemsOverlay:SetFrameLevel(20)
  slot.lockItemsOverlay:SetSize(slot:GetSize())
  slot.lockItemsOverlay:SetPoint("CENTER")
  slot.lockItemsOverlay:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  slot.lockItemsOverlay:SetBackdropColor(0, 0, 0, 0)

  slot.lockItemsOverlayTexture = slot.lockItemsOverlay:CreateTexture(nil, "OVERLAY")
  slot.lockItemsOverlayTexture:SetSize(20, 20)
  slot.lockItemsOverlayTexture:SetPoint("BOTTOMLEFT")
  slot.lockItemsOverlayTexture:SetAtlas("UI-CharacterCreate-PadLock")

  return slot.lockItemsInteractionOverlay, slot.lockItemsOverlay, slot.lockItemsOverlayTexture
end

local function SetupItemUnlockedSlot(slot)
  local interactionOverlay, lockOverlay, lockOverlayTexture = SetupSlotOverlay(slot)
  interactionOverlay:SetFrameLevel(0)
  lockOverlay:SetBackdropColor(0, 0, 0, 0)
  lockOverlayTexture:Hide()
end

local function SetupItemLockedSlot(slot)
  local interactionOverlay, lockOverlay, lockOverlayTexture = SetupSlotOverlay(slot)

  if IsMerchantOpen then
    interactionOverlay:SetFrameLevel(20)
  else
    interactionOverlay:SetFrameLevel(0)
  end

  lockOverlay:SetBackdropColor(0, 0, 0, 0.5)
  lockOverlayTexture:Show()
end

local function UpdateBagSlot(bagID, slot)
  local slotID = slot:GetID()
  local item = Item:CreateFromBagAndSlot(bagID, slotID)

  if item:IsItemEmpty() then
    SetupItemUnlockedSlot(slot)
  end

  if (isItemLocked(item:GetItemID())) then
    SetupItemLockedSlot(slot)
  else
    SetupItemUnlockedSlot(slot)
  end
end

local function UpdateSlots()
  for i = 0, NUM_BAG_SLOTS do
    for j = 1, GetContainerNumSlots(i) do
      if GetContainerItemID(i, j) then
        local containerFrameIndex = i + 1
        local itemIndex = GetContainerNumSlots(i) - (j - 1)

        -- bagnon splits container frames into fixed 36 slot chunks
        -- rather than the container capacity
        if IsAddOnLoaded("Bagnon") then
          local slotOffset = j + 1

          for k = i - 1, 0, -1 do
            slotOffset = slotOffset + GetContainerNumSlots(k)
          end

          containerFrameIndex = ceil(slotOffset / 36)
          itemIndex = slotOffset - (containerFrameIndex - 1) * 36
        end

        local slot = _G["ContainerFrame" .. containerFrameIndex .. "Item" .. itemIndex]
        UpdateBagSlot(i, slot)
      end
    end
  end
end

local function getCurrentItemID()
  local _, itemLink = GameTooltip:GetItem()

  if itemLink == nil then
    return nil
  end

  return tonumber(strmatch(itemLink, "item:(%d+):"))
end

local function toggleCurrentItemLock()
  local itemID = getCurrentItemID()

  if itemID == nil then
    return
  end

  if isItemLocked(itemID) then
    UnlockItem(itemID)
  else
    LockItem(itemID)
  end

  UpdateSlots()
end

-- Events
local function handleDeleteItemConfirm(...)
  local itemName = ...
  local itemID = LockedItemNames[itemName]
  if itemID and isItemLocked(itemID) then
    local item = Item:CreateFromItemID(itemID)
    ns.Print("|cFFFF0000 WARNING - DELETING A LOCKED ITEM |r", item:GetItemLink())
  end
end

local function handleMerchantEvent(isMerchantOpen)
  IsMerchantOpen = isMerchantOpen
  UpdateSlots()
end

local function loadEquipmentSetItems()
  EquipmentSetItemIds = {}
  for i = 0, C_EquipmentSet.GetNumEquipmentSets() do
    local itemArray = C_EquipmentSet.GetItemIDs(i)
    for j = 1, 19 do
      if itemArray and itemArray[j] then
        EquipmentSetItemIds[itemArray[j]] = true
      end
    end
  end
  UpdateSlots()
end

local function handleEquipmentSetsChanged()
  loadEquipmentSetItems()
end

local itemLockFrame = CreateFrame("FRAME", "ItemLockFrame")
itemLockFrame:RegisterEvent("DELETE_ITEM_CONFIRM")
itemLockFrame:RegisterEvent("MERCHANT_CLOSED")
itemLockFrame:RegisterEvent("MERCHANT_SHOW")
itemLockFrame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
itemLockFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "DELETE_ITEM_CONFIRM" then
    handleDeleteItemConfirm(...)
  elseif event == "MERCHANT_CLOSED" then
    handleMerchantEvent(false)
  elseif event == "MERCHANT_SHOW" then
    handleMerchantEvent(true)
  elseif event == "EQUIPMENT_SETS_CHANGED" then
    handleEquipmentSetsChanged()
  end
end)

-- Default Bags
hooksecurefunc("ContainerFrame_Update", function(bag)
  local bagID = bag:GetID()
  local bagName = bag:GetName()
  for i = 1, bag.size, 1 do
    local slot = _G[bagName .. "Item" .. i]
    UpdateBagSlot(bagID, slot)
  end
end)

local function setupCustomSorting()
  local GetOrder = Bagnon.Sorting.GetOrder

  function Bagnon.Sorting:GetOrder(spaces, family)
    if Config["sort_lock"] then
      local newSpaces = {}

      for _, space in pairs(spaces) do
        if space.item == nil or not (isItemLocked(space.item.id)) then
          table.insert(newSpaces, space)
        else
          space.item.sorted = true
        end
      end

      return GetOrder(self, newSpaces, family)
    else
      return GetOrder(self, spaces, family)
    end
  end

  local sortBags = _G.SortBags

  if _G.SortBags then
    function _G.SortBags()
      if Config["sort_lock"] then
        Bagnon.Sorting:Start(UnitName('player'), Bagnon.InventoryFrame.Bags)
      else
        sortBags()
      end
    end
  end

  ns.Print("custom sorting initialized")
end

-- Bagnon
if IsAddOnLoaded("Bagnon") then
  hooksecurefunc(Bagnon.Item, "Update", function(slot)
    local bagID = slot:GetBag()
    UpdateBagSlot(bagID, slot)
  end)

  setupCustomSorting()
end

if Config["set_lock"] then
  loadEquipmentSetItems()
end

-- slash cmds
local function toggleConfig(key)
  Config[key] = not (Config[key] or false)
  ns.Print(key, ": ", Config[key])
end

_G["SLASH_" .. name:upper() .. "1"] = "/il"

SlashCmdList[name:upper()] = function(cmd)
  cmd = cmd:trim()

  if cmd == "list" or cmd == "ls" then
    for itemId in pairs(getLockedItemIDs()) do
      local item = Item:CreateFromItemID(itemId)
      ns.Print(item:GetItemLink())
    end
  end

  if cmd == "lock" then
    toggleCurrentItemLock()
  end

  if cmd == "sort_lock" then
    toggleConfig("sort_lock")
  end

  if cmd == "set_lock" then
    toggleConfig("set_lock")
    loadEquipmentSetItems()
  end

  if cmd == "config" then
    for key, value in pairs(Config) do
      ns.Print(key, ": ", value)
    end
  end

  if cmd == "reset" then
    LockedItems = {}
    LockedItemNames = {}
  end
end
