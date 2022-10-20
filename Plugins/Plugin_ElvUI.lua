local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginElvUI = ItemLock:NewModule("PluginElvUI")

function PluginElvUI:Init(repo, config)
  local E, L, V, P, G = unpack(ElvUI)
  local Bags = E:GetModule("Bags")

  -- Initialize the default plugin as a fallback if ElvUI's bag module is disabled and
  -- the default bags are used
  self.default = ItemLock:GetModule("PluginDefault")
  self.default:Init()

  hooksecurefunc(Bags, "UpdateSlot", function(self, frame, bagID, slotID)
    local bag = frame.Bags[bagID]
    local slot = bag and bag[slotID]
    ItemLock:UpdateSlot(bagID, slot)
  end)

  self:CustomSort(Bags, repo, config)
end

function PluginElvUI:GetSlotFrame(bagID, slotIndex)
  local containerFrameIndex

  if ItemLock:GetModule("Utils"):IsClassic() then
    containerFrameIndex = bagID - 1
  else
    containerFrameIndex = bagID
  end

  local itemIndex = slotIndex

  local customFrame = _G["ElvUI_ContainerFrameBag" .. containerFrameIndex .. "Slot" .. itemIndex]

  if customFrame then
    return customFrame
  else
    return self.default:GetSlotFrame(bagID, slotIndex)
  end
end

function PluginElvUI:CustomSort(Bags, repo, config)
  local buildBlackList = Bags.BuildBlacklist

  function Bags:BuildBlacklist(entries)
    if config:IsSortLockEnabled() then
      local lockedItemIDs = {}
      for _idx, itemID in pairs(repo:GetLockedItemIDs(config)) do lockedItemIDs[itemID] = true end

      buildBlackList(self, lockedItemIDs)
      buildBlackList(self, entries)
    else
      buildBlackList(self, entries)
    end
  end
end
