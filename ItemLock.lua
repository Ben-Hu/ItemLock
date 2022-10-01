local name, ns = ...

function ns.Print(...) print("|cFFFF8400" .. name .. "|r:", ...) end

local lockItemButton = CreateFrame("BUTTON", "LockItemButton")
SetBindingClick("ALT-L", lockItemButton:GetName(), "ALT-L")

if (LockedItems == nil) then
  LockedItems = {}
end

if (LockedItemNames == nil) then
  LockedItemNames = {}
end

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
  if slot.lockItemsOverlay then
    return slot.lockItemsOverlay
  end

  local overlay = CreateFrame("FRAME", nil, slot)
  overlay:SetFrameLevel(4)
  overlay:SetAllPoints()

  slot.lockItemsOverlay = overlay:CreateTexture(nil, "OVERLAY")
  slot.lockItemsOverlay:SetSize(25, 25)
  slot.lockItemsOverlay:SetPoint('CENTER')
  slot.lockItemsOverlay:SetAtlas("UI-CharacterCreate-PadLock")
  slot.lockItemsOverlay:Hide()

  return slot.lockItemsOverlay
end

local function ShowItemLocked(slot)
  local overlay = SetupSlotOverlay(slot)
  overlay:Show()
end

local function ShowItemUnlocked(slot)
  local overlay = SetupSlotOverlay(slot)
  overlay:Hide()
end

local function UpdateBagSlot(bagID, slot)
  local slotID = slot:GetID()
  local item = Item:CreateFromBagAndSlot(bagID, slotID)

  if item:IsItemEmpty() then
    ShowItemUnlocked(slot)
    return
  end

  if (LockedItems[item:GetItemID()]) then
    ShowItemLocked(slot)
  else
    ShowItemUnlocked(slot)
  end
end

local function UpdateSlotsWithItem(itemID)
  for i = 0, NUM_BAG_SLOTS do
    for j = 1, GetContainerNumSlots(i) do
      local containerItemID = GetContainerItemID(i, j)
      if (containerItemID == itemID) then
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

local function HandleLockItem(itemLink)
  local itemID = tonumber(strmatch(itemLink, "item:(%d+):"));

  if (itemID == nil) then
    return
  end

  if (LockedItems[itemID]) then
    UnlockItem(itemID);
    UpdateSlotsWithItem(itemID);
  else
    LockItem(itemID);
    UpdateSlotsWithItem(itemID);
  end
end

lockItemButton:SetScript("OnClick", function(self, keyBinding)
  local _, itemLink = GameTooltip:GetItem();

  if (itemLink) then
    HandleLockItem(itemLink)
  end
end)

-- Merchant Buyback
local deleteWarningFrame = CreateFrame("FRAME", "LockedItemsDeleteWarningHandler");
deleteWarningFrame:RegisterEvent("DELETE_ITEM_CONFIRM");
deleteWarningFrame:SetScript("OnEvent", function(self, event, itemName)
  local itemID = LockedItemNames[itemName]
  if (itemID and LockedItems[itemID]) then
    local item = Item:CreateFromItemID(itemID);
    ns.Print("|cFFFF0000 WARNING - DELETING A LOCKED ITEM |r", item:GetItemLink());
  end
end);

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

  if cmd == "ls" then
    for itemId, isLocked in pairs(LockedItems) do
      if (isLocked) then
        local item = Item:CreateFromItemID(itemId)
        ns.Print(item:GetItemLink())
      end
    end
  end
end
