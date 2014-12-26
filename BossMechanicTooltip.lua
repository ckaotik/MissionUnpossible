
local myname, ns = ...


local tip = GarrisonMissionMechanicTooltip
local f = CreateFrame("Frame", nil, tip)


local function ResizeTooltip()
	local height = tip.Icon:GetHeight() + 28
	height = height + tip.Description:GetHeight()
	tip:SetHeight(height)
end


local function SortFollowers(a, b)
	if not a then return false end
	if not b then return true end

	if a.level == 100 and b.level == 100 then
		return a.iLevel > b.iLevel
	else
		return a.level > b.level
	end
end


local followers
local function RefreshFollowers()
	followers = C_Garrison.GetFollowers()
	table.sort(followers, SortFollowers)
end


local function FollowerCanCounter(follower, mechanic)
	if not follower.isCollected then return false end

	local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
	for i,ability in pairs(abilities) do
		for counterID,counterInfo in pairs(ability.counters) do
			if counterInfo.name == mechanic then return true end
		end
	end

	return false
end


local ilvlcolors = {
	[600] = ITEM_QUALITY_COLORS[1].hex,
	[615] = ITEM_QUALITY_COLORS[2].hex,
	[630] = ITEM_QUALITY_COLORS[3].hex,
	[645] = ITEM_QUALITY_COLORS[4].hex,
}
local function FollowerToString(follower)
	local level = follower.level
	if level == 100 then
		local colorlvl = math.floor(follower.iLevel / 15) * 15
		level = ilvlcolors[colorlvl].. follower.iLevel
	else
		level = "|cffffffff".. level
	end

	if ns.IsFollowerAvailable(follower.followerID) then
		return level.. "|cffffffff - ".. follower.name
	else
		local namestr = level.. ITEM_QUALITY_COLORS[0].hex.. " - ".. follower.name
		local status = C_Garrison.GetFollowerStatus(follower.followerID)

		if status == GARRISON_FOLLOWER_ON_MISSION then
			local timeleft = ns.GetFollowerTimeLeft(follower.followerID)
			if timeleft then
				return namestr.. " (".. timeleft.. ")|r"
			end
		end

		return namestr.. " (".. status.. ")|r"
	end
end


local function GetFollowerListForMechanic(mechanic)
	local str = ""
	for i,follower in pairs(followers) do
		if FollowerCanCounter(follower, mechanic) then
			str = str.. "\n".. FollowerToString(follower)
		end
	end
	return str
end


f:SetScript("OnShow", function(self)
	RefreshFollowers()
	ns.RefreshInProgress()

	local mechanic = tip.Name:GetText()


	local desc = tip.Description:GetText()
	desc = desc.. "|cffffffff\n".. GetFollowerListForMechanic(mechanic)
	tip.Description:SetText(desc)

	ResizeTooltip()
end)
