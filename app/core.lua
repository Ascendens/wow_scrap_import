--[[
Copyright 2020 Andrey Kotelnik aka Kagrayz
Scrap Import is distributed under the terms of the GNU General Public License (Version 3).
As a special exception, the copyright holders of this addon do not give permission to
redistribute and/or modify it.

This addon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the addon. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.

This file is part of Scrap Import.
--]]

Scrap_Import = LibStub("AceAddon-3.0"):NewAddon("Scrap_Import", "AceConsole-3.0")

local Scrap = Scrap;
local AceGUI = LibStub("AceGUI-3.0")

--- Import item
local function importItem(id)
    if id == nil or Scrap:IsJunk(id) then
        return false
    end

    return Scrap:ToggleJunk(id)
end

--- Import item from ticker object
local function importWithTicker(ticker, id)
    if id == nil and ticker then
        id = ticker.params.id
    end

    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(id);
    if sellPrice ~= nil then
        if ticker then
            -- Scrap_Import:Print("Item info fetched via ticker.")
            ticker:Cancel()
        end

        return importItem(id)
    end

    if not ticker then
        -- Scrap_Import:Print("Item is unknown. Getting info via ticker.")
        ticker = C_Timer.NewTicker(0.3, importWithTicker, 5)
        ticker.params = {id = id}
    end
end

--- Import items
local function import(widget, event, ids)
    for id in ids:gmatch("%d+") do
        importWithTicker(nil, tonumber(id))
    end
    --- Clear
    widget:SetText("")
end

--- Draw import frame
local function showImportFrame()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Scrap Import")
    frame:SetStatusText("Insert list of IDs into the edit box")
    frame:SetLayout("Fill")

    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel("Insert item IDs:")
    editbox:SetCallback("OnEnterPressed", import)
    frame:AddChild(editbox)
end

--- Slash commands
Scrap_Import:RegisterChatCommand("scrap_import", showImportFrame);
