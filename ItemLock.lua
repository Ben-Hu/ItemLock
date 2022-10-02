local name, ns = ...

function ns.Print(...) print("|cFFFF8400[" .. name .. "]|r", ...) end

if (LockedItems == nil) then
  LockedItems = {}
end

if (LockedItemNames == nil) then
  LockedItemNames = {}
end

IsMerchantOpen = false

local function LockItem(itemID)
  local item = Item:CreateFromItemID(itemID);
  LockedItems[itemID] = true;
  LockedItemNames[item:GetItemName()] = itemID;
  ns.Print("locked", item:GetItemLink())
end

local function UnlockItem(itemID)
  local item = Item:CreateFromItemID(itemID);
  LockedItems[itemID] = false;
  LockedItemNames[item:GetItemName()] = itemID;
  ns.Print("unlocked", item:GetItemLink())
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
    return
  end

  if (LockedItems[item:GetItemID()]) then
    SetupItemLockedSlot(slot)
  else
    SetupItemUnlockedSlot(slot)
  end
end

local function UpdateSlots()
  for i = 0, NUM_BAG_SLOTS do
    for j = 1, GetContainerNumSlots(i) do
      local containerItemID = GetContainerItemID(i, j)
      if (LockedItems[containerItemID] ~= nil) then
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
          itemIndex = slotOffset % 36
        end

        local slot = _G["ContainerFrame" .. containerFrameIndex .. "Item" .. itemIndex]
        UpdateBagSlot(i, slot)
      end
    end
  end
end

local function toggleCurrentItemLock()
  local _, itemLink = GameTooltip:GetItem();

  if (itemLink == nil) then
    return
  end

  local itemID = tonumber(strmatch(itemLink, "item:(%d+):"));

  if (itemID == nil) then
    return
  end

  if (LockedItems[itemID]) then
    UnlockItem(itemID);
    UpdateSlots();
  else
    LockItem(itemID);
    UpdateSlots();
  end
end

-- Events
local deleteWarningFrame = CreateFrame("FRAME", "LockedItemsDeleteWarningHandler");
deleteWarningFrame:RegisterEvent("DELETE_ITEM_CONFIRM");
deleteWarningFrame:SetScript("OnEvent", function(self, event, itemName)
  local itemID = LockedItemNames[itemName]
  if (itemID and LockedItems[itemID]) then
    local item = Item:CreateFromItemID(itemID);
    ns.Print("|cFFFF0000 WARNING - DELETING A LOCKED ITEM |r", item:GetItemLink());
  end
end);

local merchantFrame = CreateFrame("FRAME", "LockedItemsMerchantHandler");
merchantFrame:RegisterEvent("MERCHANT_CLOSED")
merchantFrame:RegisterEvent("MERCHANT_SHOW")
merchantFrame:SetScript("OnEvent", function(self, event, arg)
  if (event == "MERCHANT_CLOSED") then
    IsMerchantOpen = false
    UpdateSlots()
  else
    IsMerchantOpen = true
    UpdateSlots()
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

-- Bagnon
if IsAddOnLoaded("Bagnon") then
  hooksecurefunc(Bagnon.Item, "Update", function(slot)
    local bagID = slot:GetBag()
    UpdateBagSlot(bagID, slot)
  end)
end

-- slash cmds
_G["SLASH_" .. name:upper() .. "1"] = "/il"

SlashCmdList[name:upper()] = function(cmd)
  cmd = cmd:trim()

  if cmd == "list" or cmd == "ls" then
    for itemId, isLocked in pairs(LockedItems) do
      if (isLocked) then
        local item = Item:CreateFromItemID(itemId)
        ns.Print(item:GetItemLink())
      end
    end
  end

  if cmd == "lock" then
    toggleCurrentItemLock()
  end
end
