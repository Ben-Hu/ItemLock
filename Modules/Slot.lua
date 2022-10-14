local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Slot = ItemLock:NewModule("Slot")

function Slot:Setup(slotFrame, isLocked, isInteractable)
  if slotFrame.lockItemsInteractionOverlay then
    self:Update(slotFrame, isLocked, isInteractable)
  else
    self:Init(slotFrame)
    self:Update(slotFrame, isLocked, isInteractable)
  end
end

function Slot:Init(slotFrame)
  slotFrame.lockItemsInteractionOverlay = CreateFrame("FRAME", nil, slotFrame)
  slotFrame.lockItemsInteractionOverlay:SetFrameLevel(0)
  slotFrame.lockItemsInteractionOverlay:SetSize(slotFrame:GetSize())
  slotFrame.lockItemsInteractionOverlay:SetPoint("CENTER")
  slotFrame.lockItemsInteractionOverlay:SetScript("OnMouseDown", function() end)

  slotFrame.lockItemsOverlay = CreateFrame("FRAME", nil, slotFrame, "BackdropTemplate")
  slotFrame.lockItemsOverlay:SetFrameLevel(20)
  slotFrame.lockItemsOverlay:SetSize(slotFrame:GetSize())
  slotFrame.lockItemsOverlay:SetPoint("CENTER")
  slotFrame.lockItemsOverlay:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  slotFrame.lockItemsOverlay:SetBackdropColor(0, 0, 0, 0)

  slotFrame.lockItemsOverlayTexture = slotFrame.lockItemsOverlay:CreateTexture(nil, "OVERLAY")
  slotFrame.lockItemsOverlayTexture:SetSize(20, 20)
  slotFrame.lockItemsOverlayTexture:SetPoint("BOTTOMLEFT")
  slotFrame.lockItemsOverlayTexture:SetAtlas("UI-CharacterCreate-PadLock")
end

function Slot:Update(slotFrame, isLocked, isInteractable)
  if isLocked then
    if isInteractable then
      slotFrame.lockItemsInteractionOverlay:SetFrameLevel(0)
    else
      slotFrame.lockItemsInteractionOverlay:SetFrameLevel(20)
    end
    slotFrame.lockItemsOverlay:SetBackdropColor(0, 0, 0, 0.5)
    slotFrame.lockItemsOverlayTexture:Show()
  else
    slotFrame.lockItemsInteractionOverlay:SetFrameLevel(0)
    slotFrame.lockItemsOverlay:SetBackdropColor(0, 0, 0, 0)
    slotFrame.lockItemsOverlayTexture:Hide()
  end
end
