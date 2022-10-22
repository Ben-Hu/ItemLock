local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginLiteBag = ItemLock:NewModule("PluginLiteBag")

function PluginLiteBag:Init(repo, config)
  hooksecurefunc('LiteBagPanel_UpdateBag', function(bag)
    for i = 1, bag.size do
      local slotFrame = bag.itemButtons[i]
      ItemLock:UpdateSlot(bag:GetID(), slotFrame)
    end
  end)

  LiteBag_RegisterHook('LiteBagItemButton_Update', function(slotFrame)
    ItemLock:UpdateSlot(slotFrame:GetParent():GetID(), slotFrame)
  end)
end

function PluginLiteBag:GetSlotFrame(bagID, slotIndex)
  local containerFrameIndex = bagID + 1
  local itemIndex = slotIndex
  return _G["LiteBagInventoryPanelContainerFrame" .. containerFrameIndex .. "Item" .. itemIndex]
end
