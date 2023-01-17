local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Slot = ItemLock:NewModule("Slot")

local function getClickBindModifierFunction(config)
  local modifier = config:GetClickBindModifier()

  if modifier == "ALT" then
    return IsAltKeyDown
  elseif modifier == "CTRL" then
    return IsControlKeyDown
  elseif modifier == "SHIFT" then
    return IsShiftKeyDown
  end
end

local function buildOnClickHookScript(config)
  return function(_frame, button, _down)
    if not config:IsClickBindEnabled() then return end

    local clickBindButton = config:GetClickBindButton()
    local modifierFunction = getClickBindModifierFunction(config)

    if button == clickBindButton and modifierFunction() then
      ItemLock:ToggleCurrentItemLock()
    end
  end
end

function Slot:Setup(slotFrame, isLocked, isInteractable, config)
  if slotFrame.lockItemsInteractionOverlay then
    self:Update(slotFrame, isLocked, isInteractable, config)
  else
    self:Init(slotFrame, config)
    self:Update(slotFrame, isLocked, isInteractable, config)
  end
end

function Slot:Init(slotFrame, config)
  local appearanceOverlay = self:CreateAppearanceOverlay(slotFrame, config)
  self:CreateIconTexture(appearanceOverlay, config)
  self:CreateBorder(appearanceOverlay, config)
  self:CreateInteractionOverlay(slotFrame)
end

function Slot:CreateAppearanceOverlay(frame, config)
  if not frame.lockItemsAppearanceOverlay then
    frame.lockItemsAppearanceOverlay = CreateFrame("FRAME", nil, frame, "BackdropTemplate")
    frame.lockItemsAppearanceOverlay:SetSize(frame:GetSize())
    frame.lockItemsAppearanceOverlay:SetPoint("CENTER")
    frame.lockItemsAppearanceOverlay:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background"
    })
    frame.lockItemsAppearanceOverlay:SetFrameLevel(20)
    frame.lockItemsAppearanceOverlay:SetBackdropColor(0, 0, 0, 0)

    if frame.RegisterForClicks then
      frame:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
      frame:HookScript('OnClick', buildOnClickHookScript(config))
    end
  end
  return frame.lockItemsAppearanceOverlay
end

function Slot:CreateIconTexture(frame, config)
  if not frame.texture then
    local size = config:GetLockIconSize()
    local position = config:GetLockIconPosition()

    frame.texture = frame:CreateTexture(nil, "OVERLAY")
    frame.texture:SetAtlas("UI-CharacterCreate-PadLock")

    self:UpdateIconTexture(frame.texture, position, size)
  end
  return frame.texture
end

function Slot:CreateBorder(frame, config)
  local thickness = config:GetLockedBorderThickness()
  return self:UpdateBorder(frame, thickness, { 0, 0, 0, 0 })
end

function Slot:CreateInteractionOverlay(frame)
  if not frame.lockItemsInteractionOverlay then
    frame.lockItemsInteractionOverlay = CreateFrame("FRAME", nil, frame)
    frame.lockItemsInteractionOverlay:SetSize(frame:GetSize())
    frame.lockItemsInteractionOverlay:SetPoint("CENTER")
    frame.lockItemsInteractionOverlay:SetScript("OnMouseDown", function() end)
    frame.lockItemsInteractionOverlay:SetFrameLevel(20)
    frame.lockItemsInteractionOverlay:Hide()
  end
  return frame.lockItemsInteractionOverlay
end

function Slot:UpdateAppearanceOverlay(frame, color, showLockIcon)
  if showLockIcon then
    frame.lockItemsAppearanceOverlay.texture:Show()
  else
    frame.lockItemsAppearanceOverlay.texture:Hide()
  end

  frame.lockItemsAppearanceOverlay:SetBackdropColor(color[1], color[2], color[3], color[4])
end

function Slot:UpdateIconTexture(texture, position, size)
  texture:ClearAllPoints()
  texture:SetPoint(position)
  texture:SetSize(size, size)
  return texture
end

function Slot:UpdateBorder(frame, thickness, color)
  if not frame.border then
    frame.border = {}
  end

  local offset = thickness / 2

  for i = 0, 3 do
    if not frame.border[i] then
      frame.border[i] = frame:CreateLine(nil, "BACKGROUND", nil, 0)
    end

    frame.border[i]:SetColorTexture(color[1], color[2], color[3], color[4])
    frame.border[i]:SetThickness(thickness)

    if i == 0 then
      frame.border[i]:SetStartPoint("TOPLEFT", -offset, 0)
      frame.border[i]:SetEndPoint("TOPRIGHT", offset, 0)
    elseif i == 1 then
      frame.border[i]:SetStartPoint("TOPRIGHT", 0, offset)
      frame.border[i]:SetEndPoint("BOTTOMRIGHT", 0, -offset)
    elseif i == 2 then
      frame.border[i]:SetStartPoint("BOTTOMRIGHT", offset, 0)
      frame.border[i]:SetEndPoint("BOTTOMLEFT", -offset, 0)
    else
      frame.border[i]:SetStartPoint("BOTTOMLEFT", 0, -offset)
      frame.border[i]:SetEndPoint("TOPLEFT", 0, offset)
    end
  end

  return frame.border
end

function Slot:UpdateInteractionOverlay(frame, isInteractable)
  if isInteractable then
    frame.lockItemsInteractionOverlay:Hide()
  else
    frame.lockItemsInteractionOverlay:Show()
  end
end

function Slot:UpdateLockedSlotFrame(slotFrame, isInteractable, config)
  local lockedBackgroundColor = config:GetLockedBackgroundColor()
  local lockedBorderThickness = config:GetLockedBorderThickness()
  local lockedBorderColor = config:GetLockedBorderColor()
  local showIcon = config:IsShowLockIcon()
  local iconPosition = config:GetLockIconPosition()
  local iconSize = config:GetLockIconSize()

  Slot:UpdateInteractionOverlay(slotFrame, isInteractable)
  Slot:UpdateAppearanceOverlay(slotFrame, lockedBackgroundColor, showIcon)
  Slot:UpdateIconTexture(slotFrame.lockItemsAppearanceOverlay.texture, iconPosition, iconSize)
  Slot:UpdateBorder(slotFrame.lockItemsAppearanceOverlay, lockedBorderThickness, lockedBorderColor)
end

function Slot:UpdateUnlockedSlotFrame(slotFrame)
  Slot:UpdateInteractionOverlay(slotFrame, true)
  Slot:UpdateAppearanceOverlay(slotFrame, { 0, 0, 0, 0 }, false)
  Slot:UpdateBorder(slotFrame.lockItemsAppearanceOverlay, 0, { 0, 0, 0, 0 })
end

function Slot:Update(slotFrame, isLocked, isInteractable, config)
  if isLocked then
    self:UpdateLockedSlotFrame(slotFrame, isInteractable, config)
  else
    self:UpdateUnlockedSlotFrame(slotFrame)
  end
end
