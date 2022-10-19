local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Tooltip = ItemLock:NewModule("Tooltip")

function Tooltip:Init(repo, config)
  GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
    Tooltip:SetGameTooltip(tooltip, repo, config)
  end)
end

function Tooltip:SetGameTooltip(tooltip, repo, config)
  if not config:IsShowTooltipEnabled() then return end

  local _itemName, itemLink = tooltip:GetItem()
  local itemID = ItemLock:GetModule("Utils"):ItemLinkToItemID(itemLink)
  if itemID and repo:IsItemLocked(itemID, config) then
    tooltip:AddLine("Locked - ItemLock")
  end
end
