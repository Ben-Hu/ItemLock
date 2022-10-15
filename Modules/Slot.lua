local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Slot = ItemLock:NewModule("Slot")

function Slot:Setup(slotFrame, isLocked, isInteractable, config)
  if slotFrame.lockItemsInteractionOverlay then
    self:Update(slotFrame, isLocked, isInteractable, config)
  else
    self:Init(slotFrame, config)
    self:Update(slotFrame, isLocked, isInteractable, config)
  end
end

function Slot:Init(slotFrame, config)
  local appearanceOverlay = self:CreateAppearanceOverlay(slotFrame)
  self:CreateAppearanceOverlayTexture(appearanceOverlay, config)
  self:CreateAppearanceOverlayBorder(appearanceOverlay)
  self:CreateInteractionOverlay(slotFrame)
end

function Slot:CreateInteractionOverlay(frame)
  if not frame.lockItemsInteractionOverlay then
    frame.lockItemsInteractionOverlay = CreateFrame("FRAME", nil, frame)
    frame.lockItemsInteractionOverlay:SetFrameLevel(0)
    frame.lockItemsInteractionOverlay:SetSize(frame:GetSize())
    frame.lockItemsInteractionOverlay:SetPoint("CENTER")
    frame.lockItemsInteractionOverlay:SetScript("OnMouseDown", function() end)
  end
  return frame.lockItemsInteractionOverlay
end

function Slot:CreateAppearanceOverlay(frame)
  if not frame.lockItemsAppearanceOverlay then
    frame.lockItemsAppearanceOverlay = CreateFrame("FRAME", nil, frame, "BackdropTemplate")
    frame.lockItemsAppearanceOverlay:SetFrameLevel(20)
    frame.lockItemsAppearanceOverlay:SetSize(frame:GetSize())
    frame.lockItemsAppearanceOverlay:SetPoint("CENTER")
    frame.lockItemsAppearanceOverlay:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background"
    })
    frame.lockItemsAppearanceOverlay:SetBackdropColor(0, 0, 0, 0)
  end
  return frame.lockItemsAppearanceOverlay
end

function Slot:CreateAppearanceOverlayTexture(frame, config)
  if not frame.texture then
    frame.texture = frame:CreateTexture(nil, "OVERLAY")
    frame.texture:SetSize(20, 20)
    frame.texture:SetPoint("BOTTOMLEFT")
    frame.texture:SetAtlas("UI-CharacterCreate-PadLock")
  end
  return frame.texture
end

function Slot:CreateAppearanceOverlayBorder(frame)
  if not frame.border then
    frame.border = {}

    for i = 0, 3 do
      frame.border[i] = frame:CreateLine(nil, "BACKGROUND", nil, 0)
      frame.border[i]:SetThickness(1)
      frame.border[i]:SetColorTexture(0, 0, 0, 0)

      if i == 0 then
        frame.border[i]:SetStartPoint("TOPLEFT")
        frame.border[i]:SetEndPoint("TOPRIGHT")
      elseif i == 1 then
        frame.border[i]:SetStartPoint("TOPRIGHT")
        frame.border[i]:SetEndPoint("BOTTOMRIGHT")
      elseif i == 2 then
        frame.border[i]:SetStartPoint("BOTTOMRIGHT")
        frame.border[i]:SetEndPoint("BOTTOMLEFT")
      else
        frame.border[i]:SetStartPoint("BOTTOMLEFT")
        frame.border[i]:SetEndPoint("TOPLEFT")
      end
    end
  end

  return frame.border
end

local function setBorderColor(frame, r, g, b, a)
  if not frame.border then
    Slot:CreateAppearanceOverlayBorder(frame)
  end

  for i = 0, 3 do frame.border[i]:SetColorTexture(r, g, b, a) end
end

local function updateLockedSlotFrame(slotFrame, isInteractable, config)
  local lockedBackgroundColor = config:GetLockedBackgroundColor()
  local lockedBorderColor = config:GetLockedBorderColor()

  if isInteractable then
    slotFrame.lockItemsInteractionOverlay:SetFrameLevel(0)
  else
    slotFrame.lockItemsInteractionOverlay:SetFrameLevel(20)
  end

  if config:IsShowLockIcon() then
    slotFrame.lockItemsAppearanceOverlay.texture:Show()
  else
    slotFrame.lockItemsAppearanceOverlay.texture:Hide()
  end

  slotFrame.lockItemsAppearanceOverlay:SetBackdropColor(
    lockedBackgroundColor[1],
    lockedBackgroundColor[2],
    lockedBackgroundColor[3],
    lockedBackgroundColor[4]
  )

  setBorderColor(slotFrame.lockItemsAppearanceOverlay,
    lockedBorderColor[1],
    lockedBorderColor[2],
    lockedBorderColor[3],
    lockedBorderColor[4]
  )
end

local function updateUnlockedSlotFrame(slotFrame)
  slotFrame.lockItemsInteractionOverlay:SetFrameLevel(0)
  slotFrame.lockItemsAppearanceOverlay:SetBackdropColor(0, 0, 0, 0)
  slotFrame.lockItemsAppearanceOverlay.texture:Hide()
  setBorderColor(slotFrame.lockItemsAppearanceOverlay, 0, 0, 0, 0)
end

function Slot:Update(slotFrame, isLocked, isInteractable, config)
  if isLocked then
    updateLockedSlotFrame(slotFrame, isInteractable, config)
  else
    updateUnlockedSlotFrame(slotFrame)
  end
end
