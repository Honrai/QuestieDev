---@class QuestieAnnounce
local QuestieAnnounce = QuestieLoader:CreateModule("QuestieAnnounce")
---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")


QuestieAnnounce._itemCache = {} -- cache data since this happens on item looted it could happen a lot with auto loot

function QuestieAnnounce:Announce(questId, progressType, itemId, objectiveText, objectiveProgress)
    if Questie.db.char.questAnnounce and "disabled" ~= Questie.db.char.questAnnounce and UnitInParty("player") then
        local message = nil
        local questLevel, questName = unpack(QuestieDB.QueryQuest(questId, "questLevel", "name"))

        if progressType == "objective" then
            local objective = nil
            if itemId then
                objective = objectiveProgress.." "..(select(2,GetItemInfo(itemId)))
            else
                objective = objectiveProgress.." "..objectiveText
            end
            message = QuestieLocale:GetUIString("QUEST_ANNOUNCE_OBJECTIVE", objective, "[["..tostring(questLevel).."] "..questName.." ("..tostring(questId)..")]")
        elseif progressType == "item" then
            message = QuestieLocale:GetUIString("QUEST_ANNOUNCE_QUESTITEM", (select(2,GetItemInfo(itemId))), "[["..tostring(questLevel).."] "..questName.." ("..tostring(questId)..")]")
        end

        SendChatMessage(message, "PARTY")
    end
end

function QuestieAnnounce:ItemLooted(text)
    local itemId = tonumber(string.match(text, "item:(%d+)"))
    if not QuestieAnnounce._itemCache[itemId] then
        QuestieAnnounce._itemCache[itemId] = QuestieDB.QueryItemSingle(itemId, "startQuest") or false -- we do "or false" here because nil cant be inserted into _itemCache
    end
    local startQuest = QuestieAnnounce._itemCache[itemId]
    if startQuest and startQuest > 0 then
        QuestieAnnounce:Announce(startQuest, "item", itemId)
    end
end

