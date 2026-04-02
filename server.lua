-- ══════════════════════════════════════════════════════════════
--  uv-books  ·  server.lua
--  Supports: QBCore, QBox (qbx_core), ox_inventory, jaksam_inventory, qb-inventory
-- ══════════════════════════════════════════════════════════════

local MAX_PAGES = 20
local MAX_CHARS = 800

-- ── Framework & inventory detection ──────────────────────────

local Framework = nil   -- "qbx" | "qb"
local Inventory = nil   -- "ox"  | "qb" | "jaksam"
local QBCore    = nil   -- only populated when running plain QBCore

CreateThread(function()

    -- Framework
    if GetResourceState("qbx_core") == "started" then
        Framework = "qbx"
        print("[uv-books] Framework detected: QBox (qbx_core)")
    elseif GetResourceState("qb-core") == "started" then
        Framework = "qb"
        QBCore = exports["qb-core"]:GetCoreObject()
        print("[uv-books] Framework detected: QBCore")
    else
        print("[uv-books] ^1WARNING: No supported framework found!^0")
    end

    -- Inventory
    if GetResourceState("jaksam_inventory") == "started" then
        Inventory = "jaksam"
        print("[uv-books] Inventory detected: jaksam_inventory (ox-compatible)")
    elseif GetResourceState("ox_inventory") == "started" then
        Inventory = "ox"
        print("[uv-books] Inventory detected: ox_inventory")
    elseif GetResourceState("qb-inventory") == "started" or
           GetResourceState("qs-inventory") == "started" or
           GetResourceState("ps-inventory") == "started" or
           GetResourceState("lj-inventory") == "started" then
        Inventory = "qb"
        print("[uv-books] Inventory detected: qb-style inventory")
    else
        Inventory = (Framework == "qbx") and "ox" or "qb"
        print("[uv-books] Inventory fallback: " .. Inventory)
    end

end)


-- ── Helper: get player object ────────────────────────────────

local function GetPlayer(src)
    if Framework == "qbx" then
        return exports.qbx_core:GetPlayer(src)
    elseif Framework == "qb" and QBCore then
        return QBCore.Functions.GetPlayer(src)
    end
    return nil
end


-- ── Helper: send notification ────────────────────────────────

local function Notify(src, msg, nType)
    if GetResourceState("ox_lib") == "started" then
        TriggerClientEvent("ox_lib:notify", src, {
            description = msg,
            type        = nType or "info",
        })
    elseif Framework == "qb" then
        TriggerClientEvent("QBCore:Notify", src, msg, nType)
    elseif Framework == "qbx" then
        exports.qbx_core:Notify(src, msg, nType)
    end
end


-- ── Helper: add item to player ───────────────────────────────

local function AddItem(src, item, count, metadata)
    if Inventory == "ox" then
        return exports.ox_inventory:AddItem(src, item, count, metadata)
    elseif Inventory == "jaksam" then
        return exports.jaksam_inventory:AddItem(src, item, count, metadata)
    else
        local Player = GetPlayer(src)
        if Player then
            return Player.Functions.AddItem(item, count, false, metadata)
        end
    end
    return false
end


-- ── Helper: remove item from player ──────────────────────────

local function RemoveItem(src, item, count, slot)
    if Inventory == "ox" then
        return exports.ox_inventory:RemoveItem(src, item, count, nil, slot)
    elseif Inventory == "jaksam" then
        return exports.jaksam_inventory:RemoveItem(src, item, count, nil, slot)
    else
        local Player = GetPlayer(src)
        if Player then
            return Player.Functions.RemoveItem(item, count, slot)
        end
    end
    return false
end


-- ── Helper: update item metadata ─────────────────────────────

local function SetMetadata(src, slot, metadata)
    if Inventory == "ox" then
        exports.ox_inventory:SetMetadata(src, slot, metadata)
        return true
    elseif Inventory == "jaksam" then
        exports.jaksam_inventory:SetMetadata(src, slot, metadata)
        return true
    else
        -- qb-style: remove and re-add with new metadata
        local success = RemoveItem(src, "book", 1, slot)
        if success then
            return AddItem(src, "book", 1, metadata)
        end
    end
    return false
end


-- ══════════════════════════════════════════════════════════════
--  Track active writers (slot info for draft saving)
-- ══════════════════════════════════════════════════════════════

local ActiveWriters = {}  -- [src] = { slot = N }


-- ══════════════════════════════════════════════════════════════
--  Create book event
-- ══════════════════════════════════════════════════════════════

RegisterNetEvent("uv-books:server:createBook", function(bookData)

    local src    = source
    local Player = GetPlayer(src)

    if not Player   then return end
    if not bookData then return end
    if not bookData.pages then return end

    if type(bookData.pages) ~= "table" then
        print("[uv-books] Exploit attempt (pages not table) from " .. src)
        return
    end

    if #bookData.pages > MAX_PAGES then
        print("[uv-books] Exploit attempt (too many pages) from " .. src)
        return
    end

    local hasContent = false

    for i = 0, MAX_PAGES - 1 do
        local page = bookData.pages[i] or bookData.pages[tostring(i)] or ""

        if type(page) ~= "string" then
            print("[uv-books] Invalid page type from " .. src)
            return
        end

        if string.len(page) > MAX_CHARS then
            print("[uv-books] Exploit attempt (page too long) from " .. src)
            return
        end

        if page ~= "" then hasContent = true end
    end

    if not hasContent then
        Notify(src, "You can't publish an empty book.", "error")
        return
    end

    local pageCount = 0
    for _, page in pairs(bookData.pages) do
        if type(page) == "string" and page ~= "" then
            pageCount = pageCount + 1
        end
    end

    local author = (bookData.signed and bookData.signature ~= "") and bookData.signature or "Unknown"
    local genre  = (bookData.genre and bookData.genre ~= "") and bookData.genre or nil

    -- Build inventory description
    local desc = '"' .. (bookData.title or "Untitled Book") .. '" by ' .. author
    if genre then
        desc = desc .. " · " .. genre
    end

    -- Remove the old book (blank or draft) from the slot they were writing in
    local writerInfo = ActiveWriters[src]
    if writerInfo and writerInfo.slot then
        RemoveItem(src, "book", 1, writerInfo.slot)
    end
    ActiveWriters[src] = nil

    local info = {
        title       = bookData.title or "Untitled Book",
        author      = author,
        content     = bookData.pages,
        images      = bookData.images or {},
        genre       = genre or "",
        font        = bookData.font or "",
        signed      = bookData.signed or false,
        signature   = bookData.signature or "",
        description = desc,
    }

    local success = AddItem(src, "book", 1, info)
    Notify(src, success and "Book published!" or "Failed to create book!", success and "success" or "error")

end)


-- ══════════════════════════════════════════════════════════════
--  Save draft event
-- ══════════════════════════════════════════════════════════════

RegisterNetEvent("uv-books:server:saveDraft", function(draftData)

    local src = source
    local Player = GetPlayer(src)
    if not Player then return end
    if not draftData then return end

    local writerInfo = ActiveWriters[src]
    if not writerInfo or not writerInfo.slot then
        Notify(src, "Could not save draft.", "error")
        return
    end

    local draftMeta = {
        draft = {
            title  = draftData.title or "",
            pages  = draftData.pages or {},
            images = draftData.images or {},
            font   = draftData.font or "",
        }
    }

    local success = SetMetadata(src, writerInfo.slot, draftMeta)
    ActiveWriters[src] = nil

    if success then
        Notify(src, "Draft saved!", "success")
    else
        Notify(src, "Failed to save draft.", "error")
    end

end)


-- ══════════════════════════════════════════════════════════════
--  Register "book" as a useable item
-- ══════════════════════════════════════════════════════════════

local function OnBookUsed(src, item)

    local info = (item and item.info) or (item and item.metadata) or {}
    local slot = item and item.slot

    -- Track the slot for draft saving
    ActiveWriters[src] = { slot = slot }

    if info.content and type(info.content) == "table" and next(info.content) ~= nil then
        -- Published book → reader
        ActiveWriters[src] = nil
        TriggerClientEvent("uv-books:client:readBook", src, info)
    elseif info.draft and type(info.draft) == "table" then
        -- Draft book → writer with draft data loaded
        TriggerClientEvent("uv-books:client:startWriting", src, info.draft)
    else
        -- Blank book → fresh writer
        TriggerClientEvent("uv-books:client:startWriting", src)
    end

end

-- ══════════════════════════════════════════════════════════════
--  📚 Useable item — registration varies by inventory
-- ══════════════════════════════════════════════════════════════

-- ox_inventory export
exports("book", function(event, item, inventory, slot, data)
    if event == "usingItem" then
        local src = inventory.id

        local slotData = exports.ox_inventory:GetSlot(src, slot)
        local info = (slotData and slotData.metadata) or {}

        -- Track slot
        ActiveWriters[src] = { slot = slot }

        if info.content and type(info.content) == "table" and next(info.content) ~= nil then
            ActiveWriters[src] = nil
            TriggerClientEvent("uv-books:client:readBook", src, info)
        elseif info.draft and type(info.draft) == "table" then
            TriggerClientEvent("uv-books:client:startWriting", src, info.draft)
        else
            TriggerClientEvent("uv-books:client:startWriting", src)
        end
    end
end)

-- For non-ox inventories
CreateThread(function()
    while Framework == nil do Wait(100) end

    if Inventory == "jaksam" then
        exports["jaksam_inventory"]:registerUsableItem("book", function(playerId, item)
            OnBookUsed(playerId, item)
        end)
        print("[uv-books] Registered useable item via jaksam_inventory")

    elseif Inventory == "qb" then
        if Framework == "qb" and QBCore then
            QBCore.Functions.CreateUseableItem("book", function(source, item)
                OnBookUsed(source, item)
            end)
            print("[uv-books] Registered useable item via QBCore")

        elseif Framework == "qbx" then
            local core = exports["qb-core"]:GetCoreObject()
            if core then
                core.Functions.CreateUseableItem("book", function(source, item)
                    OnBookUsed(source, item)
                end)
                print("[uv-books] Registered useable item via QBox bridge")
            end
        end

    else
        print("[uv-books] Using ox_inventory export for item registration")
    end
end)

-- Clean up on player disconnect
AddEventHandler("playerDropped", function()
    ActiveWriters[source] = nil
end)
