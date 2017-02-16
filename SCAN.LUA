-----Functions Scannings for HBs,ISOs and PS1
boots = {}
index={EG=1,UG=1,MG=2,ME=3}

function fill_install(ruta,nombre,zip)
	games[4][#games[4]].title = nombre
	games[4][#games[4]].name = string.gsub(files.nopath(files.nofile(ruta)),"/","")
	games[4][#games[4]].cat = "ZIP"
	games[4][#games[4]].path = ruta
	if zip then
		games[4][#games[4]].icono = image.copy(zip)
	else
		games[4][#games[4]].icono = image.copy(default_icon)
	end

	if (games[4][#games[4]].icono:getw() > 80) then 
        games[4][#games[4]].icono:resize(100,68)
    else 
        games[4][#games[4]].icono:resize(68,68)
    end
end

function fill_scan(var, path, name, ind, temp)
	if not ind then
		table.insert(games[var],{})
		ind=#games[var]
	end

	if temp then
		if temp.DISC_ID then games[var][ind].discid = temp.DISC_ID end
		title=temp.TITLE
		category=temp.CATEGORY
	else
		title=name
		category="UG"
	end

	games[var][ind].title =  title
	games[var][ind].name = name	
	games[var][ind].cat =  category
	games[var][ind].path = path
	games[var][ind].pcat = var

	games[var][ind].icono = game.geticon0(path)
	if (not games[var][ind].icono) and default_icon then
		games[var][ind].icono = image.copy(default_icon)
	end

	if (games[var][ind].icono:getw() > 80) then 
        games[var][ind].icono:resize(100,68)
    else 
        games[var][ind].icono:resize(68,68)
    end

	--boots
	if config[11]==path then boots[path] = 0 		--square
	elseif config[12]==path then boots[path] = 1 	--triangle
	elseif config[13]==path then boots[path] = 2 	--circle
	elseif config[14]==path then boots[path] = 3 	--cross 
	end
end

--Scanning ms0:/PSP/SAVEDATA
function scanning_saves()
	local tmp = files.listdirs("ms0:/PSP/SAVEDATA/")
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			local ls=files.listfiles(tmp[i].path)
			if ls and #ls > 0 then
				for j=1, #ls do
					if ls[j].ext and ls[j].ext:upper() == "ZIP" then
						zip=game.geticon0zip(ls[j].path)
						if not zip then
							if files.exists(tmp[i].path.."/ICON0.PNG") then
								zip=image.load(tmp[i].path.."/ICON0.PNG")
							end
						end
						table.insert(games[4],{})
						fill_install(ls[j].path,ls[j].name,zip)
						zip=nil

					elseif ls[j].ext and (ls[j].ext:upper() == "ISO" or ls[j].ext:upper() == "CSO") and cfw!="VHBL" then
						if debug_mode then init_msg(ls[j].path) end--Debug
						local tmp0 = game.info(ls[j].path)
						if tmp0 then
							if #config[15]>0 and string.find(config[15],ls[j].name,1,true) then--List Hbs Hiddens
								if config[6] then fill_scan(5,ls[j].path,ls[j].name,nil,tmp0) end
							else
								fill_scan(1,ls[j].path,ls[j].name,nil,tmp0)
							end
							tmp0=nil
						end--tmp0

					elseif ls[j].ext and (ls[j].ext:upper() == "DAX" and _CFWME==1) then--DAX only en CFW ME/LME
						if debug_mode then init_msg(ls[j].path) end--Debug
						if #config[15]>0 and string.find(config[15],ls[j].name,1,true) then--List Hbs Hiddens
							if config[6] then fill_scan(5,ls[j].path,ls[j].name) end
						else
							fill_scan(1,ls[j].path,ls[j].name)
						end
					end--if ZIP
				end
			end
		end--for
	end--tmp
end

--scanning ms0:/ISO
function scanning_isos(_path)
	tmp = files.list(_path)	
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory and config[4] then				--subcategories
				local ls=files.listfiles(tmp[i].path)
				if ls and #ls > 0 then
					for j=1, #ls do
						if ls[j].ext and (ls[j].ext:upper() == "ISO" or ls[j].ext:upper() == "CSO") then
							if debug_mode then init_msg(ls[j].path) end--Debug
							local tmp0 = game.info(ls[j].path)
							if tmp0 and tmp0.CATEGORY == "UG" then
								if #config[15]>0 and string.find(config[15],ls[j].name,1,true) then--List Hbs Hiddens
									if config[6] then fill_scan(5,ls[j].path,ls[j].name,nil,tmp0) end
								else
									fill_scan(1,ls[j].path,ls[j].name,nil,tmp0)
								end
								tmp0=nil
							end--tmp0
							
						elseif ls[j].ext and (ls[j].ext:upper() == "DAX" and _CFWME==1) then--DAX only en CFW ME/LME
							if debug_mode then init_msg(ls[j].path) end--Debug
							if #config[15]>0 and string.find(config[15],ls[j].name,1,true) then--List Hbs Hiddens
								if config[6] then fill_scan(5,ls[j].path,ls[j].name) end
							else
								fill_scan(1,ls[j].path,ls[j].name)
							end
						end--ISO,CSO
					end--for
				end--ls
	
			elseif tmp[i].ext and (tmp[i].ext:upper() == "ISO" or tmp[i].ext:upper() == "CSO" or tmp[i].ext:upper() == "DAX") then
				if (tmp[i].ext:upper() == "DAX" and _CFWME==1) then						--DAX only en CFW ME/LME
					if debug_mode then init_msg(tmp[i].path) end--Debug
					if #config[15]>0 and string.find(config[15],tmp[i].name,1,true) then--List Hbs Hiddens
						if config[6] then fill_scan(5,tmp[i].path,tmp[i].name) end
					else
						fill_scan(1,tmp[i].path,tmp[i].name)
					end
				else
					if debug_mode then init_msg(tmp[i].path) end--Debug
					local tmp0 = game.info(tmp[i].path)
					if tmp0 and tmp0.CATEGORY == "UG" then
						if #config[15]>0 and string.find(config[15],tmp[i].name,1,true) then--List Hbs Hiddens
							if config[6] then fill_scan(5,tmp[i].path,tmp[i].name,nil,tmp0)	end
						else
							fill_scan(1,tmp[i].path,tmp[i].name,nil,tmp0)
						end
						tmp0=nil
					end--tmp0
				end
			end
		end
	else
		files.mkdir(_path)
	end
end

--scanning ms0:/PSP/GAME or ms0:/PSP/VHBL

function finds_pbps(ruta)
	if config[2] then--VHBL
		if files.exists(ruta.."/WMENU.BIN") then pbp="/WMENU.BIN" end
	end
	if files.exists(ruta.."/EBOOT.PBP") then pbp="/EBOOT.PBP"
	elseif files.exists(ruta.."/FBOOT.PBP") then pbp="/FBOOT.PBP"
	elseif files.exists(ruta.."/VBOOT.PBP") then pbp="/VBOOT.PBP"
	end
end

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
function scanning_pbps(path)
	tmp = files.listdirs(path)
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			pbp=nil
			finds_pbps(tmp[i].path)
			if pbp then
				if debug_mode then init_msg(tmp[i].path..pbp) end--Debug
				local tmp0 = game.info(tmp[i].path..pbp)
				if tmp0 then
					if (cfw=="VHBL" and tmp0.CATEGORY =="ME") then _CFWME=0
					else
						if #config[15]>0 and string.find(config[15],tmp[i].name,1,true) then--List Hbs Hiddens
							if config[6] then fill_scan(5,tmp[i].path..pbp,tmp[i].name,nil,tmp0) end
						else
							fill_scan(index[tmp0.CATEGORY] or 2,tmp[i].path..pbp,tmp[i].name,nil,tmp0)
						end
					end
					tmp0=nil
				end--tmp0
			else
				if config[4] then													--subcategories
					local subc = files.listdirs(tmp[i].path)
					if subc and #subc > 0 then
						for j=1, #subc do
							finds_pbps(subc[j].path)
							if pbp then
								if debug_mode then init_msg(subc[j].path..pbp) end--Debug
								local tmp0 = game.info(subc[j].path..pbp)
								if tmp0 then
									if (cfw=="VHBL" and tmp0.CATEGORY =="ME") then _CFWME=0
									else
										if #config[15]>0 and string.find(config[15],subc[j].name,1,true) then--List Hbs Hiddens
											if config[6] then fill_scan(5,subc[j].path..pbp,subc[j].name,nil,tmp0) end
										else
											fill_scan(index[tmp0.CATEGORY] or 2,subc[j].path..pbp,subc[j].name,nil,tmp0)
										end
									end
									tmp0=nil
								end--tmp0
							end
						end--for subc
					end
				end--if config[3]
			end
		end--for tmp
	end
end
