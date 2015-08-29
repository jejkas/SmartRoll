SmartRoll_WaitingForRoll = false;
SmartRoll_versionNumber = "1.0.0";

SmartRoll_LastUpdate = GetTime();
function SmartRoll_OnUpdate()
	if SmartRoll_LastUpdate + 0.1 <= GetTime()
	then
		SmartRoll_LastUpdate = GetTime();
	end;
end


SLASH_SmartRoll1 = "/SmartRoll";

SmartRoll_rollList = {};
SmartRoll_rollNameList = {};

-- /smartroll NOPE 33 Coalition 18 NinjaRabbits 12
-- /smartroll a 1 b 2 c 3 d 4
SlashCmdList["SmartRoll"] = function(args)
	local inc = 0;
	if args == nil or args == ""
	then
		--SmartRoll_("/SmartRoll name number[ name number[ ...]]");
	else
		-- Split string to find who we roll for.
		local d = __strsplit(" ", args);

		-- Clear the current roll list so we don't have old data in there.
		SmartRoll_rollList = {};
		SmartRoll_rollNameList = {};

		-- how high our max roll will be.
		local totalRollNumber = 0;

		-- This is our string to send to raid/party.
		local announcementString = "[SmartRoll] ";

		-- Validate the data inputed.
		--SmartRoll_(d);
		for i=1,table.getn(d),2
		do
			-- Check if we have anumber also.
			if d[i+1] == nil or d[i+1] == ""
			then
				break;
			end
			--SmartRoll_rollList[d[i]] = tonumber(d[i+1]);
			inc = inc + 1;
			SmartRoll_rollList[inc] = tonumber(d[i+1]);
			SmartRoll_rollNameList[inc] = d[i];
			local oldTotalRollNumber = totalRollNumber;
			if totalRollNumber == 0
			then
				oldTotalRollNumber = 1;
			else
				-- Increase it by 1 every time but the first time.
				oldTotalRollNumber = oldTotalRollNumber + 1;
			end
			totalRollNumber = totalRollNumber + tonumber(d[i+1]);
			announcementString = announcementString .. " [" .. d[i] .. ": " .. oldTotalRollNumber .. " -> " .. totalRollNumber .. "("..tonumber(d[i+1])..")] ";
		end

		--SmartRoll_(announcementString);
		if UnitInRaid("player") == 1
		then
			SendChatMessage(announcementString, "RAID");
		else
			SendChatMessage(announcementString, "PARTY");
		end

		--SmartRoll_(SmartRoll_rollList);

		-- Update our bool that tracks if we are waiting for a roll to happen.
		SmartRoll_WaitingForRoll = true;

		-- Perform roll
		RandomRoll(1, totalRollNumber);
	end
end;

function SmartRoll_OnEvent()
	if event == "ADDON_LOADED" and arg1 == "SmartRoll"
	then

	end
	if event == "CHAT_MSG_SYSTEM" and SmartRoll_WaitingForRoll
	then
		if string.find(arg1, UnitName("player") .. " rolls (%d+)") ~= nil
		then
			local start, stop = string.find(arg1, "%d+");
			local rollNumber = string.sub(arg1, start, stop);
			--SmartRoll_(rollNumber);

			local winnerName = SmartRoll_GetWinnerFromNumber(rollNumber);

			--SmartRoll_("[SmartRoll] Winner: " .. winnerName);
			if UnitInRaid("player") == 1
			then
				SendChatMessage("[SmartRoll] Winner: " .. winnerName .. " (SmartRoll Version: "..SmartRoll_versionNumber..")", "RAID");
			else
				SendChatMessage("[SmartRoll] Winner: " .. winnerName .. " (SmartRoll Version: "..SmartRoll_versionNumber..")", "PARTY");
			end

			SmartRoll_WaitingForRoll = false;
		end
	end
	if true
	then
		return;
	end
	--SmartRoll_(event);
	--SmartRoll_(arg1);
	--SmartRoll_(arg2);
	--SmartRoll_(arg3);
	--SmartRoll_(arg4);
end

function SmartRoll_GetWinnerFromNumber(nr)
	nr = tonumber(nr);
	local lastNumber = 1;
	--SmartRoll_("GetWinnerFromNumber: ".. nr);
	--SmartRoll_(SmartRoll_rollList);
	for i, nameNr in pairs(SmartRoll_rollList)
	do
		--SmartRoll_("lastNumber : ".. lastNumber .. " nameNr: " .. nameNr .. " (".. i ..")");
		if nr >= lastNumber and nr <= nameNr + lastNumber 
		then
			return SmartRoll_rollNameList[i];
		end

		if lastNumber == 1
		then
			lastNumber = lastNumber + nameNr;
		else
			-- Increase it by 1 every time but the first time.
			lastNumber = lastNumber + nameNr + 1;
		end
	end
end

function SmartRoll_(str)
	local c = ChatFrame1;
	
	if str == nil
	then
		c:AddMessage('SmartRoll: NIL'); --ChatFrame1
	elseif type(str) == "boolean"
	then
		if str == true
		then
			c:AddMessage('SmartRoll: true');
		else
			c:AddMessage('SmartRoll: false');
		end;
	elseif type(str) == "table"
	then
		c:AddMessage('SmartRoll: array');
		SmartRoll_printArray(str);
	else
		c:AddMessage('SmartRoll: '..str);
	end;
end;

function SmartRoll_printArray(arr, n)
	if n == nil
	then
		 n = "arr";
	end
	for key,value in pairs(arr)
	do
		if type(arr[key]) == "table"
		then
			SmartRoll_printArray(arr[key], n .. "[\"" .. key .. "\"]");
		else
			if type(arr[key]) == "string"
			then
				--SmartRoll_(n .. "[\"" .. key .. "\"] = \"" .. arr[key] .."\"");
			elseif type(arr[key]) == "number" 
			then
				--SmartRoll_(n .. "[\"" .. key .. "\"] = " .. arr[key]);
			elseif type(arr[key]) == "boolean" 
			then
				if arr[key]
				then
					--SmartRoll_(n .. "[\"" .. key .. "\"] = true");
				else
					--SmartRoll_(n .. "[\"" .. key .. "\"] = false");
				end;
			else
				--SmartRoll_(n .. "[\"" .. key .. "\"] = " .. type(arr[key]));
				
			end;
		end;
	end
end;

function __strsplit(sep, str)
	if str == nil
	then
		return false;
	end;
	local arr = {}
	local tmp = "";
	
	--printDebug(string.len(str));
	local chr;
	for i = 1, string.len(str)
	do
		chr = string.sub(str, i, i);
		if chr == sep
		then
			table.insert(arr,tmp);
			tmp = "";
		else
			tmp = tmp..chr;
		end;
	end
	table.insert(arr,tmp);
	
	return arr
end

SmartRoll_Frame = CreateFrame("FRAME", "SmartRoll_Frame");
SmartRoll_Frame:RegisterEvent("ADDON_LOADED");
SmartRoll_Frame:RegisterEvent("PLAYER_LOGIN");
SmartRoll_Frame:RegisterEvent("CHAT_MSG_SYSTEM");
SmartRoll_Frame:RegisterEvent("CHAT_MSG_ADDON");
SmartRoll_Frame:SetScript("OnUpdate", SmartRoll_OnUpdate);
SmartRoll_Frame:SetScript("OnEvent", SmartRoll_OnEvent);
