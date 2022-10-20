local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginDefault = ItemLock:NewModule("PluginDefault")

local function handleBagUpdate(bagIndex)
  local bagID = bagIndex + 1
  local bagFrame = _G["ContainerFrame" .. bagID]

  if bagFrame then
    -- event fires twice in Classic with -2 bagIndex for the backpack in classic for some reason
    local bagName = bagFrame:GetName()
    local bagSize = GetContainerNumSlots(bagIndex)

    for itemIndex = 1, bagSize, 1 do
      local slotIndex = bagSize - itemIndex + 1
      local slotFrame = _G[bagName .. "Item" .. slotIndex]
      ItemLock:UpdateSlot(bagIndex, slotFrame)
    end
  end
end

local function onEvent(self, event, ...)
  if event == "BAG_UPDATE" then
    handleBagUpdate(...)
  end
end

function PluginDefault:Init()
  if _G.ContainerFrame_OnShow then
    hooksecurefunc("ContainerFrame_OnShow", function()
      ItemLock:UpdateSlots()
    end)
  end

  self.frame = CreateFrame("Frame")
  self.frame:RegisterEvent("BAG_UPDATE")
  self.frame:SetScript("OnEvent", onEvent)

  self:CustomSort()
end

function PluginDefault:GetSlotFrame(bagID, slotIndex)
  local containerFrameIndex = bagID + 1
  local itemIndex = GetContainerNumSlots(bagID) - (slotIndex - 1)

  return _G["ContainerFrame" .. containerFrameIndex .. "Item" .. itemIndex]
end

function PluginDefault:CustomSort()
  -- noop
end
