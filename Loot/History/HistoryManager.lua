local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.History = addon.Loot.History or {}

local Constants =
    addon.Loot.Distributions.Constants

local HistoryManager = {}
HistoryManager.__index = HistoryManager

local function getAwardedDistributions(
    sessionManager
)
    local distributions = {}

    for _, session in ipairs(
        sessionManager:GetAllSessions()
    ) do
        local manager =
            session:GetDistributions()

        for _, distribution in ipairs(
            manager:GetAll()
        ) do
            local award =
                distribution:GetAward()

            if distribution:GetWinner() ~= nil
                and award ~= nil
                and award.state
                == Constants.AwardStates.SUCCESS
            then
                table.insert(
                    distributions,
                    {
                        distribution = distribution,
                        session = session,
                    }
                )
            end
        end
    end

    return distributions
end

local function getTimestamp(entry)
    return entry.distribution:GetAwardedAt()
        or 0
end

function HistoryManager.New(
    sessionManager
)
    assert(
        sessionManager ~= nil,
        "Session manager is required"
    )

    return setmetatable({
        sessionManager = sessionManager,
    }, HistoryManager)
end

function HistoryManager:GetAll()
    local entries =
        getAwardedDistributions(
            self.sessionManager
        )

    table.sort(
        entries,
        function(left, right)
            return getTimestamp(left)
                > getTimestamp(right)
        end
    )

    local result = {}

    for _, entry in ipairs(entries) do
        local distribution =
            entry.distribution

        local winner =
            distribution:GetWinner()

        local item =
            distribution:GetItem()

        local boss =
            distribution:GetBoss()

        table.insert(
            result,
            {
                sessionId =
                    entry.session:GetId(),

                item =
                    item:GetName(),

                boss =
                    boss:GetName(),

                recipient =
                    winner:GetName(),

                awardedAt =
                    distribution:GetAwardedAt(),

                distribution =
                    distribution,
            }
        )
    end

    return result
end

function HistoryManager:GetPage(
    offset,
    limit
)
    offset = offset or 0
    limit = limit or 10

    assert(
        offset >= 0,
        "History offset cannot be negative"
    )

    assert(
        limit > 0,
        "History limit must be positive"
    )

    local all =
        self:GetAll()

    local result = {}

    local startIndex =
        offset + 1

    local endIndex =
        math.min(
            startIndex + limit - 1,
            #all
        )

    for index = startIndex, endIndex do
        table.insert(
            result,
            all[index]
        )
    end

    return result
end

function HistoryManager:GetRecent(
    limit
)
    return self:GetPage(
        0,
        limit or 10
    )
end

function HistoryManager:GetTotalCount()
    return #self:GetAll()
end

addon.Loot.History.HistoryManager =
    HistoryManager
