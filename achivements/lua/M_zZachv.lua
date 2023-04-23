fontcolors['E'] = 'FF808080'
fontcolors['I'] = 'FFC80000'

zZachOpt = {
	{ -403, 'Achievements', 'Achievements', 0, function (val) zZachShowAchivements = val end },
	{ -404, 'Achievements', 'Achievements Active', 0, function (val) zZachShowAchivementsActive = val end },
	{ -405, 'Achievements', 'Achievements No Done', 0, function (val) zZachShowAchivementsNodone = val end },
}
function zZsetAchINI(avar)
	for k, v in pairs(zZachOpt) do
		if v[1] == avar then
			Infinity_SetINIValue(v[2], v[3], v[4])
			break
		end
	end
end
function zZgetAchINI(avar)
	local ret = 0
	for k, v in pairs(zZachOpt) do
		if v[1] == avar then
			ret = Infinity_GetINIValue(v[2], v[3], 0)
			v[4] = ret
			v[5](ret)
			break
		end
	end
	return ret
end
function zZupdAchValCheck(avar)
	if avar == -403 then
		if zZachShowAchivements == 0 then
			zZachOpt[2][4] = 0
			zZachOpt[3][4] = 0
			zZachOpt[2][5](zZachOpt[2][4])
			zZachOpt[3][5](zZachOpt[3][4])
		end
	elseif avar == -404 then
		if zZachShowAchivements == 0 then
			zZachOpt[2][4] = 0
			zZachOpt[3][4] = 0
			zZachOpt[2][5](zZachOpt[2][4])
			zZachOpt[3][5](zZachOpt[3][4])
		elseif zZachShowAchivementsActive == 0 then
			zZachOpt[3][4] = 0
			zZachOpt[3][5](zZachOpt[3][4])
		end
	elseif avar == -405 then
		if (zZachShowAchivements == 0) or (zZachShowAchivementsActive == 0) then
			zZachOpt[3][4] = 0
			zZachOpt[3][5](zZachOpt[3][4])
		end
	end
end
function zZupdatetoggleTitles()
	for i=1, #toggleTitles do
		for k2, v2 in pairs(zZachOpt) do
			if toggleTitles[i][3] == v2[1] then
				toggleTitles[i][5] = v2[4]
				if toggleTitles[i][5] == 0 then
					toggleTitles[i][4] = 0
				else
					toggleTitles[i][4] = 2
				end
				break
			end
		end
	end
end
function zZupdAchVal(avar)
	for k, v in pairs(zZachOpt) do
		if v[1] == toggleTitles[avar][3] then
			v[4] = toggleTitles[avar][5]
			v[5](v[4])
			zZupdAchValCheck(v[1])
			break
		end
	end
	zZupdatetoggleTitles()
end
zZgetAchINI(-403)
zZgetAchINI(-404)
zZgetAchINI(-405)

zzShowAchs = 0
zZachCheck = -1
zZachActiveTab = 1
zZrestartAchievem = 0

zZshowAch = 0
zZachSort = 2

zZachDone = {}
zZachActive = {}
zZachNotDone = {}

zZachDoneEpilogue = {}
zZachDEpil = 0
zZepilBtnSeq = 0
zZepilBtnBam = ''
zZachEpilTime = 0
zZepilBtnSet = 0
zZachFromAll = ''

zztextflashes = {}
zztextflashidx = 1

zZachievemTable = {}
%generate_ach_table%

%month_table%

function zZgetBit(num, bit)
	local ret = 0
	local numc = num
	local tab = {}
	if (bit > 15) or (bit < 0) then return ret end
	for i = 15, 0, -1 do
		local bitc = 2^i
		if numc >= bitc then
			tab[i] = 1
			numc = numc - bitc
		else
			tab[i] = 0
		end
	end
	ret = tab[bit]
	return ret
end
function zZachTime()
	return math.floor(Infinity_GetClockTicks() / 1000)
end
function zZachEpilogue()
	local zzshow = Infinity_GetINIValue('Game Options','Journal Popups','0')
	Infinity_SetINIValue('Game Options','Journal Popups','0')
	zZachCheck = 0
	zZshowAchTextFlash()
	zZachGenerateTables()
	local nnn = #zZachDone + #zZachActive + #zZachNotDone
	zZachFromAll = #zZachDone .. ' / ' .. #zZachActive  .. ' ( ^Z' .. nnn .. '^- )'
	zZachDoneEpilogue = {}
	zZachSortTbl(1, 3)
	for k, v in pairs(zZachDone) do
		table.insert(zZachDoneEpilogue, {v[4], v[5], v[2], v[3], v[8]})
	end
	zZepilBtnBam = zZachDoneEpilogue[1][1]
	zZepilBtnSeq = zZachDoneEpilogue[1][2]
	zZepilBtnSet = 1
	Infinity_SetINIValue('Game Options','Journal Popups',zzshow)
	zZachDone = {}
	zZachActive = {}
	zZachNotDone = {}
end
function zZepilBtnBamX()
	zZachEpilTime = zZachEpilTime + 1
	if zZachEpilTime == 60 then
		zZepilBtnBam = zZachDoneEpilogue[zZepilBtnSet][1]
		zZepilBtnSeq = zZachDoneEpilogue[zZepilBtnSet][2]
		zZachEpilTime = 0
		if zZepilBtnSet < #zZachDoneEpilogue then
			zZepilBtnSet = zZepilBtnSet + 1
		else
			zZepilBtnSet = 1
		end
	end
end

function zZachInit()
	local avar, aexists = 0, 0
	Infinity_PushMenu('zztextflash')
	for k, v in pairs(zZachievemTable) do
		avar = Infinity_GetScriptVarInt(v.var_name)
		if avar == nil then avar = 0 end
		local varname = v.var_name .. '_SHOW'
		if string.len(varname) > 32 then
			varname = string.sub(varname, 1, 32)
		end
		aexists = Infinity_GetScriptVarInt(varname)
		if aexists == nil then aexists = 0 end
		v.var_value = avar
		v.var_exists = aexists
	end
	zZachCheck = zZachTime()
end
function zZshowAchTextFlash()
	if zZachTime() < zZachCheck then return end
	if #textflashes > 0 then return end
	if zzShowAchs ~= 0 then return end
	local zzshow = Infinity_GetINIValue('Game Options','Journal Popups','0')
	local avar = 0
	local var_name = ''
	local ddate = 0
	local str = ''
	for k, v in pairs(zZachievemTable) do
		str = ''
		if v.var_value == 1 then
			if v.var_exists == 0 then
				var_name = v.var_name .. "_SHOW"
				if string.len(var_name) > 32 then
					var_name = string.sub(var_name, 1, 32)
				end
				ddate = zZtimstampToDaysAch(Infinity_GetTimeString())
				if tonumber(ddate) == nil then v.var_exists = 1 else v.var_exists = tonumber(ddate) end
				C:Eval('SetGlobal("' .. var_name .. '","GLOBAL",' .. v.var_exists .. ')')
				if zZachShowAchivements == 1 then
					if v.var_exists > 1 then str = '^A' .. zZachGetDateStringFromVar(zZachGetDateFromVar(v.var_exists)) .. '^-' end
					Infinity_DisplayString('^C' .. zZachText.achievs .. '^-^D' .. v.ach_label .. '^-')
					if zzshow ~= 0 then
						showTextFlashEx(zZachText.achievs, v.ach_label .. '\n' .. v.ach_desc, str, 3000, v.ach_bam, v.ach_icon_frame)
					end
				end
			end
		else
			avar = Infinity_GetScriptVarInt(v.var_name)
			if avar == 1 then
				var_name = v.var_name .. "_SHOW"
				if string.len(var_name) > 32 then
					var_name = string.sub(var_name, 1, 32)
				end
				ddate = zZtimstampToDaysAch(Infinity_GetTimeString())
				if tonumber(ddate) == nil then v.var_exists = 1 else v.var_exists = tonumber(ddate) end
				C:Eval('SetGlobal("' .. var_name .. '","GLOBAL",' .. v.var_exists .. ')')
				v.var_value = 1
				if zZachShowAchivements == 1 then
					if v.var_exists > 1 then str = '^A' .. zZachGetDateStringFromVar(zZachGetDateFromVar(v.var_exists)) .. '^-' end
					Infinity_DisplayString('^C' .. zZachText.achievs .. '^-^D' .. v.ach_label .. '^-')
					if zzshow ~= 0 then
						showTextFlashEx(zZachText.achievs, v.ach_label .. '\n' .. v.ach_desc, str, 3000, v.ach_bam, v.ach_icon_frame)
					end
				end
			end
		end
	end
	zZachCheck = zZachTime() + 30
end
function zZachGetDateStringFromVar(y, m, d)
	local str = ''
	for k, v in pairs(zzMonths) do
		if m == Infinity_FetchString(v[3]) then
			if v[2] == 1 then
				str = ''
			else
				str = d .. ' '
			end
			break
		end
	end
	return str .. m .. ' ' .. y
end
function zZgetAchDateString(num, typ)
	local str = ''
	local x, z = '', ''
	if typ == nil then
		x = ' (^I'
		z = '^-)'
	end
	if num > 1 then
		str = x .. zZachGetDateStringFromVar(zZachGetDateFromVar(num)) .. z
	end
	return str
end
function zZachGenerateTables()
	local idx, idxa = 0, 0
	local reason = ''
	local vargame = Infinity_GetScriptVarInt('FC_ACHIEVEM_VAR')
	zZachDone = {}
	zZachActive = {}
	zZachNotDone = {}
	for k, v in pairs(zZachievemTable) do
		reason = ''
		local num = 0
		local done = 0
		local vval = 0
		if v.var_value == 1 then
			table.insert(zZachDone, {v.number, v.ach_label, v.ach_desc, v.ach_bam, v.ach_icon_frame, reason, num, v.var_exists})
		else
			local donetwo = 0
			local types = v.connected[1]
			if types == 9 then donetwo = 1
			elseif types == 8 then
				donetwo = zZgetBit(vargame, 3)
				if donetwo == 0 then donetwo = zZgetBit(vargame, 6) end
			else
				donetwo = zZgetBit(vargame, types)
			end
			if donetwo == 1 then
				types = v.connected[2]
				if types ~= -1 and done == 0 then
					if zZachievemTable[types].var_value ~= 0 then
						reason = '^C' .. zZachText.achieveDone .. '^-' .. zZachievemTable[types].ach_label
						table.insert(zZachNotDone, {v.number, v.ach_label, v.ach_desc, v.ach_bam, v.ach_icon_frame, reason, num, v.var_exists})
						done = 1
					end
				end				
				types = v.connected[3]
				if types ~= -1 and done == 0 then
					if types >= 1001 and types <= 1100 and done == 0 then
						vval = Infinity_GetScriptVarInt(v.var_name .. '_CHECK')
						if vval ~= 0 then
							reason = zZachText.noNPC
							table.insert(zZachNotDone, {v.number, v.ach_label, v.ach_desc, v.ach_bam, v.ach_icon_frame, reason, num, v.var_exists})
							done = 1
						end
					end
					if types >= 1101 and types <= 1200 and done == 0 then
						vval = Infinity_GetScriptVarInt(v.var_name .. '_CHECK')
						if vval ~= 0 then
							reason = zZachText.noClassKit
							if vval == 2 and ( types >= 1103 and types <= 1110 ) then
								reason = zZachText.otherStronghold
							end
							if types >  1180 then reason = zZachText.achNoOne     end
							if types == 1122 then reason = zZachText.achNoBard    end
							if types == 1125 then reason = zZachText.achNoSixChar end
							if types == 1126 then reason = zZachText.achNoSorc    end
							if types == 1127 then reason = zZachText.achNoMonk    end
							table.insert(zZachNotDone, {v.number, v.ach_label, v.ach_desc, v.ach_bam, v.ach_icon_frame, reason, num, v.var_exists})
							done = 1
						end
					end
					if types >= 1201 and types <= 1300 and done == 0 then
						if types == 1205 then done = 1 end
						vval = Infinity_GetScriptVarInt(v.var_name .. '_CHECK')
						if vval ~= 0 then
							if types == 1201 and done == 0 then
								if vval == 1 then reason = zZachText.tombGorion end
								if vval == 2 then reason = zZachText.achDiffChange .. t("LOB_LABEL") end
							end
							if types == 1202 then reason = zZachText.achDiffCheck .. t("LOB_LABEL") .. zZachText.onGameStart end
							if types == 1203 then reason = zZachText.achOnlyBG  end
							if types == 1204 then reason = zZachText.achOnlyHoW end
							table.insert(zZachNotDone, {v.number, v.ach_label, v.ach_desc, v.ach_bam, v.ach_icon_frame, reason, num, v.var_exists})
							done = 1
						end
					end
				end				
				for i = 4, 8 do
					types = v.connected[i]
					if types ~= -1 and done == 0 then
						if zZachievemTable[types].var_value ~= 0 then
							reason = '^C' .. zZachText.achieveDone .. '^-' .. zZachievemTable[types].ach_label
							table.insert(zZachNotDone, {v.number, v.ach_label, v.ach_desc, v.ach_bam, v.ach_icon_frame, reason, num, v.var_exists})
							done = 1
							break
						end
					end
				end				
				if done == 0 then
					table.insert(zZachActive, {v.number, v.ach_label, v.ach_desc, v.ach_bam, v.ach_icon_frame, reason, num, v.var_exists})
				end
			end
		end
	end
end
function zZachSortTbl(tab, typ)
	local function zzfsortA(s1, s2) return s1[1] < s2[1] end
	local function zzfsortB(s1, s2) return string.lower(s1[2]) < string.lower(s2[2]) end
	local function zzfsortC(s1, s2) return s1[8] < s2[8] end
	if tab == 2 then
		if typ == 1 then table.sort(zZachActive, zzfsortA)
		elseif typ == 2 then table.sort(zZachActive, zzfsortB)
		else table.sort(zZachActive, zzfsortC)
		end
	elseif tab == 3 then
		if typ == 1 then table.sort(zZachNotDone, zzfsortA)
		elseif typ == 2 then table.sort(zZachNotDone, zzfsortB)
		else table.sort(zZachNotDone, zzfsortC)
		end
	else
		if typ == 1 then table.sort(zZachDone, zzfsortA)
		elseif typ == 2 then table.sort(zZachDone, zzfsortB)
		else table.sort(zZachDone, zzfsortC)
		end
	end
end
function showTextFlashEx(title, str, date, displayTime, xbam, xbsq)
	if #zztextflashes == 0 then
		zztextflashidx = 1
	end
	local fullStr = str
	local splitLines = string.gmatch(fullStr, "[^\r\n]+")
	local line1 = splitLines()
	local line2 = splitLines()
	if(line2 == nil) then return end
	zztextflashes[zztextflashidx] = {title, line1, line2, displayTime, str, nil, xbam, xbsq, date}
	zztextflashidx = zztextflashidx + 1
end
function zZgetOpacityForInfoBlock(rampTime)
	local tf = next(zztextflashes)

	if tf then
		local time = Infinity_GetGameTicks()
		local v = zztextflashes[tf]
		if v[6] == nil then
			v[6] = time
		end
		local t = fadeInOut(time, v[6], rampTime, v[4])
		if time > v[6] + v[4] + rampTime*2 then
			zztextflashes[tf] = nil
		end
		return t
	else
		return 0
	end
end
function zZgetTFString(z)
	local tf = next(zztextflashes)

	if tf then
		return zztextflashes[tf][z]
	else
		return ''
	end
end
function zZgetTFFrame()
	local tf = next(zztextflashes)

	if tf then
		return zztextflashes[tf][8]
	else
		return 0
	end
end
function zZgetReason(ach)
	local str = ''
	if reason ~= '' then
		str = '^M' .. zZachText.achReason .. '^-' .. ach[6]
	end
	return str
end
function zZgetActiveFrame(nm, atb)
	local ret = 0
	if nm == atb then
		ret = 2
	end
	return ret
end
function zZgetNumAchivemDone()
	local final = ''
	local done, active, nodone = #zZachDone, #zZachActive, #zZachNotDone
	local all = done + active
	local allz = done + active + nodone
	if zZachActiveTab == 1 then
		final = zZachText.achAchDone .. '^A' .. done .. '^-'
		if zZachShowAchivementsActive == 1 then final = final .. zZachText.achIz .. '^A' .. all .. '^-' end
		if zZachShowAchivementsNodone == 1 then final = final .. ' (^A'  .. allz .. '^-)' end
	end
	if zZachActiveTab == 2 then
		final = zZachText.achAchAcnive .. '^A' .. active .. '^-' .. zZachText.achIz .. '^A' .. all .. '^-'
		if zZachShowAchivementsNodone == 1 then final = final .. ' (^A'  .. allz .. '^-)' end
	end
	if zZachActiveTab == 3 then
		final = zZachText.achAchNoDone .. '^A' .. nodone .. '^-' .. zZachText.achIz .. '^A' .. allz .. '^-'
	end
	return final
end
function zZgreyLuaText(s, bool)
	if bool then return '^E' .. s .. '^-' else return s end
end
--filter
zZachFilterDoneText = ''
zZachDateFilt = 0
zZshowAchFilter = 0
zZachFiltTbl = {}
function zZachFilterDone(row)
	if zZachFilterDoneText == nil or zZachFilterDoneText == '' then return true end
	local textone = zZachDone[row][2]
	local texttwo = zZachDone[row][3]
	if string.find(string.lower(textone), string.lower(zZachFilterDoneText)) or
	   string.find(string.lower(texttwo), string.lower(zZachFilterDoneText)) then
		return true
	else
		return false
	end
end
function zZachFilterActive(row)
	if zZachFilterDoneText == nil or zZachFilterDoneText == '' then return true end
	local textone = zZachActive[row][2]
	local texttwo = zZachActive[row][3]
	if string.find(string.lower(textone), string.lower(zZachFilterDoneText)) or
	   string.find(string.lower(texttwo), string.lower(zZachFilterDoneText)) then
		return true
	else
		return false
	end
end
function zZachFilterNotDone(row)
	if zZachFilterDoneText == nil or zZachFilterDoneText == '' then return true end
	local textone = zZachNotDone[row][2]
	local texttwo = zZachNotDone[row][3]
	if string.find(string.lower(textone), string.lower(zZachFilterDoneText)) or
	   string.find(string.lower(texttwo), string.lower(zZachFilterDoneText)) then
		return true
	else
		return false
	end
end
function zZachFiltTblCreate()
	zZachFiltTbl = {}
	zZachFiltTbl[1] = {0, 1, '^$' .. stringsAll.zzAll .. '^-'}
	zZachSortTbl(1, 3)
	local u = 1
	for k, v in pairs(zZachDone) do
		local x, y = '^$', '^-'
		local date = v[8]
		local done = true
		local ye, mo, da = zZachGetDateFromVar(date)
		local datestr = mo .. ' ' .. ye
		date = zzGetAllDays({1, mo, ye})
		for i = 1, #zZachFiltTbl do
			if date == zZachFiltTbl[i][1] then
				zZachFiltTbl[i][4] = zZachFiltTbl[i][4] + 1
				done = false
				break
			end
		end
		if done then
			if u % 2 == 0 then x, y = '', '' end
			zZachFiltTbl[#zZachFiltTbl+1] = {date, 0, x .. datestr .. y, 1}
			u = u + 1
		end
	end
end
function zZachCheckFilter(row)
	for k, v in pairs(zZachFiltTbl) do
		v[2] = 0
	end
	zZachFiltTbl[row][2] = 1
end
function zZachFilterDoneDate(date)
	if zZachFiltTbl[1][2] == 1 then return true end
	local ret = false
	local ye, mo, da = zZachGetDateFromVar(date)
	date = zzGetAllDays({1, mo, ye})
	for k, v in pairs(zZachFiltTbl) do
		if v[1] == date and v[2] == 1 then
			ret = true
			break
		end
	end
	return ret
end
function zZachFFilltDataLbl(row)
	local ret = ""
	if row == 1 then ret = zZachFiltTbl[row][3]
	else ret = zZachFiltTbl[row][3] .. ' (' .. zZachFiltTbl[row][4] .. ')' end
	return ret
end
------new
function zzGetDaysInYear()
	local days = 0
	for k, v in pairs(zzMonths) do
		days = days + v[2]
	end
	return days
end
zzDaysInYear = zzGetDaysInYear()
function zzGetDateFromString(strd)
	local x, y = string.find(strd, '%(')
	local ztr = ''
	if x ~= nil then
		ztr = string.sub(strd, y + 1)
		ztr = string.gsub(ztr, '%)', '')
		ztr = string.gsub(ztr, ',', '')
	end
	local tbl = {}
	local x, y, i = 0, 0, 0
	while x ~= nil do
		x, y = string.find(ztr, ' ', 1, true)
		if x ~= nil then
			i = i + 1
			tbl[i] = string.sub(ztr, 1, x - 1)
			if i == 1 and tonumber(tbl[i]) == nil then
				local nx = string.find(ztr, '%d')
				if nx ~= nil then
					tbl[1] = '1'
					local sus = string.sub(ztr, 1, nx - 1)
					local ln = string.len(sus)
					while ln > 0 do
						local u = string.sub(sus, ln)
						if u == ' ' then
							sus = string.sub(sus, 1, ln - 1)
							ln = ln - 1
						else
							ln = 0
						end
					end
					tbl[2] = sus
					tbl[3] = string.sub(ztr, nx)
					x = nil
				end
			end
			ztr = string.sub(ztr, y + 1)
		else
			i = i + 1
			tbl[i] = ztr
		end
	end
	return tbl
end
function zzGetAllDays(tbl)
	local d = tonumber(tbl[1])
	local m = tbl[2]
	local y = tonumber(tbl[3])
	local yd = y * zzDaysInYear
	local md = 0
	local all = 0
	for k, v in pairs(zzMonths) do
		if m == Infinity_FetchString(v[3]) then
			break
		end
		md = md + v[2]
	end
	all = yd + md + d
	return all
end
function zZgetHourFromString(str)
	local x, y = string.find(str, '%d+')
	if x ~= nil then
		local v, w = string.find(str, '%d+', y + 1)
		if v ~= nil then
			str = string.sub(str, v, w)
		end
	end
	return str
end
function zZtimstampToDays(str)
	local tbl = zzGetDateFromString(str)
	local days = zzGetAllDays(tbl)
	local hour = zZgetHourFromString(str)
	days = days * 100 + tonumber(hour)
	return days
end
function zZtimstampToDaysAch(str)
	local tbl = zzGetDateFromString(str)
	local days = zzGetAllDays(tbl)
	return days
end
function zZachGetDateFromVar(num)
	local year, days, month = math.floor(num / zzDaysInYear) , num % zzDaysInYear, ''
	for i = 1, #zzMonths do
		if days <= zzMonths[i][2] then
			month = Infinity_FetchString(zzMonths[i][3])
			break
		else
			days = days - zzMonths[i][2]
		end
	end
	return year, month, days
end
--LOB_LABEL - zamenit' na IWD variant
------new done
function CheckPauseJournalBegin()
	if worldScreen:CheckIfPaused() then
		zzPauseJournal = 1
	else
		zZeval("ActionOverride(Player%s, PauseGame())", zZgetSelectedCharacterIndex() or 1)
	end
end
function CheckPauseJournalEnd()
	if zzPauseJournal == 0 then
		worldScreen:TogglePauseGame(true)
	else
		zzPauseJournal = 0
	end
end
function zzLockScrolJournal(r)
	if r == 1 then
		zZeval("ActionOverride(Player%s, LockScroll())", zZgetSelectedCharacterIndex() or 1)
	else
		zZeval("ActionOverride(Player%s, UnlockScroll())", zZgetSelectedCharacterIndex() or 1)
	end
end
function zZeval(script, ...)
	C:Eval(script:format(...))
end
function zZgetSelectedCharacterIndex()
	local selected = Infinity_GetSelectedCharacterName()
	local n = Infinity_GetNumCharacters()
	for i = 1, n do
		if zZgetCharacterName(i - 1) == selected then
			return i
		end
	end
end
function zZgetCharacterName(index)
	local tt = Infinity_GetPortraitTooltip(index)
	return tt and tt:match("(.*)\n")
end











