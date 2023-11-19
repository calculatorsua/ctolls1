script_name = ('CTOOLS')
script_author = ('artemich')
script_version = ('20.11.2023')

local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не можу провірити оновлення, спробуйте самі на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/calculatorsua/ctolls1/main/version.json" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/calculatorsua/ctolls1"
        end
    end
end


require"lib.moonloader"
require"lib.sampfuncs"

local sampev = require "lib.samp.events"
local playerId = -1 

local Matrix3X3 = require "matrix3x3"
local Vector3D = require "vector3d"

local inicfg = require 'inicfg'
local rkeys = require 'rkeys'
local state1 = false
local td = {2055}

local mem = require 'memory'
local keys = require "vkeys"
local imgui = require "imgui"
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8
local GK = require 'game.keys'
local ToScreen = convertGameScreenCoordsToWindowScreenCoords
local x, y = ToScreen(440, 0)
local w, h = ToScreen(640, 448)

local ffi = require 'ffi'
local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}

local tCarsTypeName = {"Автомобіль", "Мотоцикл", "Гелікоптер", "Літак", "Прицеп", "Човен", "Інше", "Потяг", "Велосипед"}

local tCarsType = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1,
3, 1, 1, 1, 1, 6, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 6, 3, 2, 8, 5, 1, 6, 6, 6, 1,
1, 1, 1, 1, 4, 2, 2, 2, 7, 7, 1, 1, 2, 3, 1, 7, 6, 6, 1, 1, 4, 1, 1, 1, 1, 9, 1, 1, 6, 1,
1, 3, 3, 1, 1, 1, 1, 6, 1, 1, 1, 3, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 9, 9, 4, 4, 4, 1, 1, 1,
1, 1, 4, 4, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 1, 1,
1, 3, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 4,
1, 1, 1, 2, 1, 1, 5, 1, 2, 1, 1, 1, 7, 5, 4, 4, 7, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 1, 5, 5
}
local cmd1 = [[
 /alogin
/rules
/a
/pm
/mute
/unmute
/admins
/alock
/ram
/tp
/re
/getskills
/gm
/sp
/m
/gg
/ainfo
/hp
/flipveh
/gspawn
/vipchat
]]
local cmd2 = [[
/jail
/unjail
/prisoners
/kick
/jp
/weap
/offmute
/offunmute
/atipster
/astats
/aimcheck
/cweap
/delgun
/gettime
/delfences
/uncuff
/getid
/checkfences
]]
local cmd3 = [[
/warn
/fv
/spcar
/g
/getip
/agetip
/getname
/offjail
/offunjail
/hid
/bizz
/gethere
/setnick
/freeze
/unfreeze
/offstats
/slap
/mark
/gotomark
/sethp
/setarm
/last
/awarehouse
/respv
/gotocat
/getherecar
/gsinfo
/offgettime
/skick
]]
local cmd4 = [[
/delveh
/ban
/checkip
/int
/setfuel
/ao
/fin
/veh
/alldelveh
/unwarn
/offunwarn
/uval
/ears
/hpall
/spall
/gettax
/settime
/infoips
/inforegips
/gomp
/amusic
/captfreeze
/spcars
/offban
]]
local cmd5 = [[
/paint
/sban
/race
/iban
/golod
/weather
/tempzone
/getdonate
/admstats
/makegs
/makedj
/tskin
/iofffban
/offwarn
/onantiproxy
/unban
/unablock
]]
local pravila = [[
  ДМ - [Jail 60-180 хвилин | Warn]
  МАСС ДМ - [Jail 180 хвилин | Warn]
  ДМ ЗЗ - [Jail 60-180 хвилин | Warn]
  МАСС ДМ ЗЗ - warn
  ДБ - [Jail 30-60 хвилин]
  МАСС ДБ - [Jail 60-180 хвилин | Warn]
  МАСС ДБ В ЗЗ - [Jail 180 | Варн]
  РК - [Jail 60-180 хвилин | Warn]
  МАСС СК - [Jail 180 хвилин | Warn]
  СК - [Jail 60-180 хвилин | Warn]
  ПГ - [Jail 60-180 хвилин | Warn]
  нонРП дії -  [Jail 60-180 хвилин | Warn]
  нонРП коп - [Jail 120-180 | Warn]
  вихід під час арешту/рп ситуації -  [ Jail 60-180 хвилин | Warn]
  тримання зброї в зз - kick
  будь-які спроби обману гравців - NOUNBAN
  трансліт - [Мут на 30 хвилин]
  дужки в ІС чат - [Мут 10 хвилин]
  флуд - мут 20
  капс - мут 10
  нец.лексика - мут 20-60
  розпал міжнац.ворожнечі - [Мут 180 хвилин/Бан 7]
  образа рідні - бан 30
  образа адм - бан 30
  згадка рідних - мут 180
  купівля/продаж/обмін будь-якого майна у чатах фракцій/робіт/віп чаті. - | [Мут 30 хвилин]
  Заборонено провокувати адміністрацію. | [Мут 30-180 хвилин]
  Релігійні провокації та образи, пов'язані з релігійною приналежністю гравця. | [Бан на 30 днів]
  Прояв ненависті щодо політики будь-якого уряду, політичні провокації у будь-яких проявах, образа влади та уряду. | [Бан на 30 днів]
]]

local fa = require "faIcons"
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range})

local tag = "[CTOOLS]"
local label = 0
local main_color = 0xFF4444
local main_color_text = "{00FF00}"
local white_color = "{FFFFFF}"
local arr = os.date("*t")
local imadd = require 'imgui_addons'
local sw, sh = getScreenResolution()

local main_window = imgui.ImBool(false)
local two_window = imgui.ImBool(false)
local three_window = imgui.ImBool(false)
local four_window = imgui.ImBool(false)
local five_window = imgui.ImBool(false)
local six_window = imgui.ImBool(false)
local seven_window = imgui.ImBool(false)
local test_window = imgui.ImBool(false)
local helper_window = imgui.ImBool(false)
local info_window = imgui.ImBool(false)
local china_window = imgui.ImBool(true)
local Buffer = imgui.ImBuffer(256)
local dial, but1, but2, tt = '', '', '', ''



local Checkbox = imgui.ImBool(false)
local Checkbox2 = imgui.ImBool(false)
local Checkbox3 = imgui.ImBool(false)
local Checkbox4 = imgui.ImBool(false)
local Checkbox5 = imgui.ImBool(false)
local Checkbox6 = imgui.ImBool(false)
local Checkbox7 = imgui.ImBool(false)
local Checkbox8 = imgui.ImBool(false)

local collision_car = imgui.ImBool(false)
local collision_objects =  imgui.ImBool(false)
local collision_players =  imgui.ImBool(false)
local players = nil
local objects = nil
local vehicles = nil

local HLcfg = inicfg.load({
    config = {
      active = true
    }
  }, "Ctools.ini")
  inicfg.save(HLcfg, "Ctools.ini")

local active = imgui.ImBool(HLcfg.config.active)

--- Config
keyToggle = VK_MBUTTON
keyApply = VK_LBUTTON





local helloText = [[
Дякую за те, що використовуєте даний Ctools.
В цьому меню буде показана вся інформація щодо подальших оновлень.
Даний скріпт був створений для полегшення роботи адміністрації Samp Ukraine.
Він є не багатофункціональним, але компактним.
Якщо у вас є ідеї щодо оновлень, ви можете описати їх в адмін конференції.
Автором скріпта є Artemich_Calculator
Останні оновлення:
- 1. Добавлена рекон - панель, якщо пропадає то нажміть Пробіл
- 2. Добавлено інформацію про перса в реконі
- 3. Добавлено МП меню, найти можна в функціях
- 4. Добавив інвіз
- 5. Рекон панель активується на кнопку L
- 6. Авто-відповіді репорт, менюшка відкривається сама при /reps
- 7. Добавив телепорт по мітці - /ctp
- 8. Добавив колізію, найти можна в функціях
Плани:
- Зробити автоматичне прийняття форм
- Добавити показ трейсерів пуль.
]]




function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then
    return
end
while not isSampAvailable() do
    wait(100)
end
if autoupdate_loaded and enable_autoupdate and Update then
  pcall(Update.check, Update.json_url, Update.prefix, Update.url)
end
    initializeRender()
    sampAddChatMessage("[CTOOLS] {FFFFFF}by artemich loaded! Use /ctools or F3  ", 0x00FF00)
    sampAddChatMessage("[CTOOLS] {FFFFFF}пеніс  ", 0x00FF00)
    sampRegisterChatCommand('ctools', cmd_ctools)
    sampRegisterChatCommand('ctools2', cmd_ctools2)
    sampRegisterChatCommand('ctools3', cmd_ctools3)
    sampRegisterChatCommand('ctools4', cmd_ctools4)
    sampRegisterChatCommand('ctools5', cmd_ctools5)
    sampRegisterChatCommand('ctools6', cmd_ctools6)
    sampRegisterChatCommand('ctools7', cmd_ctools7)
    sampRegisterChatCommand('test', cmd_test)
    sampRegisterChatCommand('info', cmd_info)
    sampRegisterChatCommand('carif', cmd_carif)
    sampRegisterChatCommand("invisasdhalskdjhkazsdj", invisasdhalskdjhkazsdj)
    sampRegisterChatCommand('helper', cmd_helper)
    sampRegisterChatCommand('rtest', function() sampAddChatMessage('Адмін Nick_Name[34] >> Nick_Name[58]: 123',-1) end)
    sampRegisterChatCommand('china', cmd_china)
    sampRegisterChatCommand("ctp", ctp)
    r,i = sampGetPlayerIdByCharHandle(ped)

    _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)


    while true do
        wait(0)

        if tpres then
          coords, posX, posY, posZ = getTargetBlipCoordinates()
          z = getGroundZFor3dCoord(posX, posY, posZ)
          car = storeCarCharIsInNoSave(playerPed)
          if coords and  isCharInCar(playerPed, car) then
            setCharCoordinates(playerPed, posX, posY, posZ)
            wait(200)
            tpres = false
          elseif coords then
            setCharCoordinates(playerPed, posX, posY, z+2.5)
            tpres = false
          else sampAddChatMessage('[CTOOLS] {FFFFFF}Поставте маркер на карті для телепорту.', 0x00FF00)
            tpres = false
          end
        end
        if isCharInAnyCar(PLAYER_PED) then
          if collision_car.v then
              local vehHandle = nil
              vehHandle = getNearestVehicle(300)
              if vehHandle ~= nil then
                  setCarCollision(vehHandle, false)
                  currentVehicle = vehHandle   
              end                                                                                                                   
          else
              local vehHandle = nil
              vehHandle = getNearestVehicle(300)
              if vehHandle ~= nil then
                  setCarCollision(vehHandle, true)
                  currentVehicle = vehHandle   
              end   
          end

          
      end
      if collision_objects.v then
          objectToCol()
          setObjectCollision(objects, false)
      else
          objectToCol()
          setObjectCollision(objects, true)
      end

      if collision_players.v then
          playerToCol()
          setCharCollision(players, false)
          
      else
          playerToCol()
          setCharCollision(players, true)
      end

        if wasKeyPressed(keys.VK_F3) then
          main_window.v = not main_window.v
          imgui.Process = main_window.v
        end
        if sampIsChatInputActive() or sampIsDialogActive() then
        else
          if wasKeyPressed(keys.VK_L) then
            test_window.v = not test_window.v
            imgui.Process = test_window.v
            info_window.v = not info_window.v
            imgui.Process = info_window.v
          end
        end


        
        while isPauseMenuActive() do
            if cursorEnabled then
                showCursor(false)
            end
            wait(100)
        end
        if active.v then
            if isKeyDown(keyToggle) then
            cursorEnabled = not cursorEnabled
            showCursor(cursorEnabled)
            while isKeyDown(keyToggle) do wait(80) end
            end

        if cursorEnabled and not three_window.v then
            local mode = sampGetCursorMode()
            if mode == 0 then
              showCursor(true)
            end
            local sx, sy = getCursorPos()
            local sw, sh = getScreenResolution()
            -- is cursor in game window bounds?
            if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
              local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
              local camX, camY, camZ = getActiveCameraCoordinates()
              -- search for the collision point
              local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
              if result and colpoint.entity ~= 0 then
                local normal = colpoint.normal
                local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                local zOffset = 300
                if normal[3] >= 0.5 then zOffset = 1 end
                -- search for the ground position vertically down
                local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
                  true, true, false, true, false, false, false)
                if result then
                  pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)
    
                  local curX, curY, curZ  = getCharCoordinates(playerPed)
                  local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                  local hoffs             = renderGetFontDrawHeight(font)
    
                  sy = sy - 2
                  sx = sx - 2
                  renderFontDrawText(font, string.format("%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)
    
                  local tpIntoCar = nil
                  if colpoint.entityType == 2 then
                    local car = getVehiclePointerHandle(colpoint.entity)
                    if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                      displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                      local color = 0xAAFFFFFF
                      if isKeyDown(VK_RBUTTON) then
                        tpIntoCar = car
                        color = 0xFFFFFFFF
                      end
                      renderFontDrawText(font2, "Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
                    end
                  end
    
                  createPointMarker(pos.x, pos.y, pos.z)
    
                  -- teleport!
                  if isKeyDown(keyApply) then
                    if tpIntoCar then
                      if not jumpIntoCar(tpIntoCar) then
                        -- teleport to the car if there is no free seats
                        teleportPlayer(pos.x, pos.y, pos.z)
                      end
                    else
                      if isCharInAnyCar(playerPed) then
                        local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                        local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                        rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                        pos = pos - norm * 1.8
                        pos.z = pos.z - 0.8
                      end
                      teleportPlayer(pos.x, pos.y, pos.z)
                    end
                    removePointMarker()
    
                    while isKeyDown(keyApply) do wait(0) end
                    showCursor(false)
                  end
                end
              end
            end
          end
          removePointMarker()
        if isKeyDown(18) and isKeyJustPressed(114) then -- ALT+F3
			nameTagOn()
			--sampAddChatMessage("on", 0xFFFF00)
			repeat
			wait(0)
			if isKeyDown(119) then
				nameTagOff()
				wait(1000)
				nameTagOn()
			end
			until isKeyDown(18) and isKeyJustPressed(114)
			while isKeyDown(18) or isKeyDown(114) do
			wait(10)
			end
			nameTagOff()
			--sampAddChatMessage("off", 0xFFFF00)
		end
        imgui.Process = main_window.v or two_window.v or three_window.v or four_window.v or five_window.v or six_window.v or seven_window.v or  helper_window.v or test_window.v or info_window.v or china_window.v 
        end
    end
end
function sampev.onTogglePlayerSpectating(playerSpectating)
end
function getNick(id)
  local nick = sampGetPlayerNickname(id)
  return nick
end

function sampev.onSpectatePlayer(id, type)
  if test_window.v then
      playerId = id
  end
end
function sampev.onSendPlayerSync(data)
	if state1 then
		local px, py, pz = getCharCoordinates(PLAYER_PED)
		data.position.x = px+5
		data.position.y = py+5
		data.position.z = pz-15
	end
end
function invisasdhalskdjhkazsdj(arg)
	if state1 then
		sampAddChatMessage('[CTOOLS] {FFFFFF}Інвіз увімкнено.', 0x00FF00)
		state1 = false
	else
		sampAddChatMessage('[CTOOLS] {FFFFFF}Інвіз вимкнено.', 0x00FF00)
		state1 = true
	end
end

function vehiclesToCol()
  for k, v in ipairs(getAllVehicles()) do
      local res, car = sampGetCarHandleBySampVehicleId(v)
      if res then
          vehicles = v
      end
  end
end

function playerToCol()
  for k, v in ipairs(getAllChars()) do
      local res, id = sampGetPlayerIdByCharHandle(v)
      if res then
          players = v
      end
  end
end

function objectToCol()
  for k, v in ipairs(getAllObjects()) do
      local res, id = sampGetObjectHandleBySampId(v) 
      if res then
          objects = v
      end
  end
end




function cmd_ctools(arg)
    main_window.v = not main_window.v
    imgui.Process = main_window.v
end
function cmd_ctools2(arg)
    two_window.v = not two_window.v
    imgui.Process = two_window.v
end
function cmd_ctools3(arg)
    three_window.v = not three_window.v
    imgui.Process = three_window.v
end
function cmd_ctools4(arg)
  four_window.v = not four_window.v
  imgui.Process = four_window.v
end
function cmd_ctools5(arg)
  five_window.v = not five_window.v
  imgui.Process = five_window.v
end
function cmd_ctools6(arg)
  six_window.v = not six_window.v
  imgui.Process = six_window.v
end
function cmd_ctools7(arg)
  seven_window.v = not seven_window.v
  imgui.Process = seven_window.v
end
function cmd_test(arg)
  test_window.v = not test_window.v
  imgui.Process = test_window.v
end
function cmd_helper(arg)
  helper_window.v = not  helper_window.v
  imgui.Process =  helper_window.v
end
function cmd_info(arg)
  info_window.v = not  info_window.v
  imgui.Process =  info_window.v
end
function cmd_china(arg)
  china_window.v = not  china_window.v
  imgui.Process =  china_window.v
end
function nameTagOn()
	local pStSet = sampGetServerSettingsPtr()
	NTdist = mem.getfloat(pStSet + 39) -- РґР°Р»СЊРЅРѕСЃС‚СЊ
	NTwalls = mem.getint8(pStSet + 47) -- РІРёРґРёРјРѕСЃС‚СЊ С‡РµСЂРµР· СЃС‚РµРЅС‹
	NTshow = mem.getint8(pStSet + 56) -- РІРёРґРёРјРѕСЃС‚СЊ С‚РµРіРѕРІ
	mem.setfloat(pStSet + 39, 1488.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end

function nameTagOff()
	local pStSet = sampGetServerSettingsPtr()
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
end
function onExitScript()
	if NTdist then
		nameTagOff()
	end
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end


function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF("moonloader/resource/fonts/fontawesome-webfont.ttf", 14.0, font_config, fa_glyph_ranges)
    end
end

function imgui.OnDrawFrame()
    imgui.ShowCursor = main_window.v or two_window.v or three_window.v or four_window.v or five_window.v or six_window.v or seven_window.v or test_window.v or helper_window.v or china_window.v 
    if china_window.v  and tt ~= nil and tt ~= '' then
      imgui.SetNextWindowSize(imgui.ImVec2(550, 250), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowPos(imgui.ImVec2(380,280), imgui.Cond.FirstUseEver)
      
        imgui.Begin(u8'Відповідь на скаргу ', china_window, imgui.WindowFlags.NoResize)
                imgui.CenterText(u8(tt))

                imgui.PushItemWidth(230)
                imgui.InputText(' ', Buffer)
                imgui.PopItemWidth()
               
                if imgui.Button(u8(but1),imgui.ImVec2(112, 20)) and Buffer.v ~= nil and Buffer.v ~= '' then
                    sampSendDialogResponse(dial,1, _,u8:decode(Buffer.v))
                    sampCloseCurrentDialogWithButton(0)
                    china_window.v = false
                end
                    imgui.SameLine()
                if imgui.Button(u8(but2),imgui.ImVec2(113, 20)) then
                    sampCloseCurrentDialogWithButton(0)
                    china_window.v = false
                end
                imgui.Separator()
                if imgui.Button(u8('Працюю'),imgui.ImVec2(112, 20)) then
                  sampSendDialogResponse(462,1,0,'Працюю по вашій скарзі.')
                  china_window.v = false
                  sampCloseCurrentDialogWithButton(0)
                end
                imgui.SameLine()
                if imgui.Button(u8('Не знаю'),imgui.ImVec2(112, 20)) then
                  sampSendDialogResponse(462,1,0,'Не володіємо даною інформацією.')
                  china_window.v = false
                  sampCloseCurrentDialogWithButton(0)
                end
                if imgui.Button(u8('скаргу форум'),imgui.ImVec2(112, 20)) then
                  sampSendDialogResponse(462,1,0,'Залиште скаргу на форумі.')
                  china_window.v = false
                  sampCloseCurrentDialogWithButton(0)
                end
                imgui.SameLine()
                if imgui.Button(u8('оффтоп'),imgui.ImVec2(112, 20)) then
                  sampSendDialogResponse(462,1,0,'Прошу не оффтопити.')
                  china_window.v = false
                  sampCloseCurrentDialogWithButton(0)
                end

        imgui.End()
    end
    if main_window.v then
        imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('CTOOLS', main_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        img = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\img.png")
        imgui.Image(img, imgui.ImVec2(1000,310))
        imgui.Separator()
        imgui.CenterText(u8'Точний час: '..os.date('%H:%M:%S'), imgui.ImVec2(150,50))
        imgui.CenterText(u8'Точна дата: '..arr.day..'.'.. arr.month..'.'..arr.year, imgui.ImVec2(150,50))
        imgui.Separator()
        if imgui.Button(fa.ICON_USER  ..  u8' Ваш Аккаунт',  imgui.ImVec2(150,70)) then
            two_window.v = not two_window.v
            imgui.Process = two_window.v
        end
        imgui.SameLine()
        if imgui.Button(fa.ICON_KEY .. u8' Функції', imgui.ImVec2(150,70)) then
            three_window.v = not three_window.v
            imgui.Process = three_window.v
        end
        imgui.SameLine()
        if imgui.Button(fa.ICON_SHIELD .. u8' Команди', imgui.ImVec2(150,70)) then
            four_window.v = not four_window.v
            imgui.Process = four_window.v
         end
        imgui.SameLine()
        if imgui.Button(fa.ICON_PUZZLE_PIECE .. u8' Інше', imgui.ImVec2(150,70)) then
          five_window.v = not five_window.v
          imgui.Process = five_window.v

        end
        imgui.SameLine()
        if imgui.Button(fa.ICON_GAMEPAD .. u8' Налаштування', imgui.ImVec2(150,70)) then
          six_window.v = not six_window.v
          imgui.Process = six_window.v

        end
        imgui.SameLine()
        if imgui.Button(fa.ICON_USER_SECRET .. u8' Інформація', imgui.ImVec2(150,70)) then
          seven_window.v = not seven_window.v
          imgui.Process = seven_window.v
        end
        imgui.End()
    end
    if  two_window.v then
        main_window.v = false
        local nick = sampGetPlayerNickname(id)
        imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('Ctools', two_window)
        imgui.CenterText(u8'Ваш ID: '..id)
        imgui.CenterText(u8'Ваш Нік: '..nick)
        imgui.CenterText(u8'Ваш рівень: ' ..sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
        imgui.End()
    end
    if  three_window.v then
        main_window.v = false
        imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin('CTOOLS', three_window)
        lua_thread.create(function ()
            if imgui.Button(fa.ICON_TELEGRAM .. u8' Піар /report в /ao', imgui.ImVec2(150,70)) then
                sampSendChat('/ao [INFO] Доброго дня, шановні гравці, якщо у вас виникли питання...')
                wait(1000)
                sampSendChat('/ao [INFO] ...Ви можете задати їх в /ask чи /report')
                wait(1000) 
                sampSendChat('/ao [INFO] Точний час: '..os.date('%H:%M:%S'))
                wait(1000) 
                sampSendChat('/ao [INFO] Точна дата: '..arr.day..'.'.. arr.month..'.'..arr.year)
            end
        end)
        imgui.SameLine()
        if imgui.Button(fa.ICON_TELEGRAM ..u8' Хелпер для МП', imgui.ImVec2(150,70)) then
          helper_window.v = not helper_window.v
          imgui.Process = helper_window.v
        end
        imgui.SameLine()
        if imgui.Button(fa.ICON_TELEGRAM .. u8' Респ карів 30 сек', imgui.ImVec2(150,70)) then
            lua_thread.create(function ()
                sampSendChat('/ao [INFO] Доброго дня, шановні гравці, за 30 секунд відбудеться...')
                wait(1000)
                sampSendChat('/ao [INFO] Респавн незайнятих транспортних засобів...')
                wait(1000)
                sampSendChat('/ao [INFO] Якщо вам потрібен ваш автомобіль, сядьте в нього та чекайте')
                wait(1000)
                sampSendChat('/spcars 30')
                wait(30000)
                sampSendChat('/ao [INFO] Респавн незайнятих автомобілів пройшов успішно')
                wait(1000)
                sampSendChat('/ao [INFO] Приємної гри на Samp Ukraine!')
            end)
        end
        imgui.SameLine()
        if imgui.Button(fa.ICON_SHIELD .. u8' Вибрати лідерку', imgui.ImVec2(150,70)) then
          sampSendChat('/templeader')
          three_window.v = false
        end
               imgui.SameLine()
        if imgui.Button(fa.ICON_TELEGRAM .. u8'Заклик /reps', imgui.ImVec2(150,70)) then
          lua_thread.create(function()
          sampSendChat('/a [ALARM!!!] Не стоїмо без діла, беремо /reps')
          wait(1000)
          sampSendChat('/a [ALARM!!!] Якщо встаєте в АФК, не забувайте про ESC')
          wait(1000)
          sampSendChat('/a [ALARM!!!] Слідкуючі за фракціями слідкуйте за лідерами!')
          wait(1000)
          sampSendChat('/a [ALARM!!!] Хелпери чистимо /reps')
          end)
        end
        imgui.Separator()
        if imgui.Checkbox(u8'WallHack', Checkbox) then
             act = not act
            if act then
                nameTagOn()
                sampAddChatMessage("[CTOOLS] {FFFFFF}WH увімкнено! ", 0x00FF00)
                else
                nameTagOff()
                sampAddChatMessage("[CTOOLS] {FFFFFF}WH вимкнено! ", 0x00FF00)
                end
        end
        if imgui.Checkbox("ClickWarp", active) then
            HLcfg.config.active = active.v
            inicfg.save(HLcfg, "Ctools.ini")
          end
        if imgui.Checkbox(u8'AirBrake[Q+E]', Checkbox2) then
            sampAddChatMessage('[CTOOLS] {FFFFFF}Написано ж Q+E :)', 0x00FF00)
	      end
        if imgui.Checkbox(u8'Invisible', Checkbox3) then
          if state1 then
            sampAddChatMessage('[CTOOLS] {FFFFFF}Інвіз вимкнено.', 0x00FF00)
            state1 = false
          else
            sampAddChatMessage('[CTOOLS] {FFFFFF}Інвіз увімкнено.', 0x00FF00)
            state1 = true
          end
        end
        if imgui.Checkbox(u8("Колізія на авто"), collision_car) then 
          if collision_car.v then
              if not isCharInAnyCar(PLAYER_PED) then
                sampAddChatMessage('[CTOOLS] {FFFFFF} Ви повинні знаходитись у автомобілі', 0x00FF00)
                  collision_car.v = false
              else
                sampAddChatMessage('[CTOOLS] {FFFFFF} Колізія на автомобілі увімкнена', 0x00FF00)
              end
          else
                sampAddChatMessage('[CTOOLS] {FFFFFF} Колізія на автомобілі вимкнена', 0x00FF00)
          end
      end       
      if imgui.Checkbox(u8("Колізія на objects"), collision_objects) then 
          if collision_objects.v then
              sampAddChatMessage('[CTOOLS] {FFFFFF} Колізія на objects увімкнена', 0x00FF00)
          else
              sampAddChatMessage('[CTOOLS] {FFFFFF} Колізія на objects вимкнена', 0x00FF00)
          end
      end 
      if imgui.Checkbox(u8("Колізія на гравців"), collision_players) then 
          if collision_players.v then
            sampAddChatMessage('[CTOOLS] {FFFFFF} Колізія на гравців увмікнена', 0x00FF00)
          else
            sampAddChatMessage('[CTOOLS] {FFFFFF} Колізія на гравців викмкнена', 0x00FF00)
          end
      end 
        imgui.End()
    end
    if four_window.v then
      main_window.v = false
      imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('CTOOLS', four_window)
      if imgui.CollapsingHeader(u8'Команди 1 рівня') then
        imgui.Text(u8(cmd1))
      end
      if imgui.CollapsingHeader(u8'Команди 2 рівня') then
        imgui.Text(u8(cmd2))
      end
      if imgui.CollapsingHeader(u8'Команди 3 рівня') then
        imgui.Text(u8(cmd3))
      end
      if imgui.CollapsingHeader(u8'Команди 4 рівня') then
        imgui.Text(u8(cmd4))
      end
      if imgui.CollapsingHeader(u8'Команди 5 рівня') then
        imgui.Text(u8(cmd5))
      end
      imgui.End()
    end
    if five_window.v then
      main_window.v = false
      imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('CTOOLS', five_window)
      if imgui.CollapsingHeader(u8'Правила для покарань') then
        imgui.Text(u8(pravila))
      end
      imgui.End()
    end
    if six_window.v then
      main_window.v = false
      imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('CTOOLS', six_window)
      imgui.End()
    end
    if seven_window.v then
      main_window.v = false
      imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('CTOOLS', seven_window)
      imgui.CenterText(u8'Актуальна версія: '..script_version)  
      imgui.Separator()
      if imgui.CollapsingHeader(u8'Детальніше про тулс: ') then
        imgui.CenterText(u8(helloText))
      end
      imgui.Separator()
      imgui.CenterText(u8'Вирішення проблем - t.me/artemichtt') 
      imgui.End()
    end
    if test_window.v then
      if imgui.IsMouseClicked(1) then
        imgui.ShowCursor = not imgui.ShowCursor
    end
    local m, a = ToScreen(200, 410)
    imgui.SetNextWindowPos(imgui.ImVec2(m, a), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(537, 60), imgui.Cond.FirstUseEver)
    imgui.Begin(u8"China", test_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    local bet = imgui.ImVec2(70, 0)
    if imgui.Button(u8'<< BACK', bet) then
      if playerId == 0 then
        local onMaxId = sampGetMaxPlayerId(false)
        if not sampIsPlayerConnected(onMaxId) or sampGetPlayerScore(onMaxId) == 0 or sampGetPlayerColor(onMaxId) == 16510045 then 
            for i = sampGetMaxPlayerId(false), 0, -1 do
                if sampIsPlayerConnected(i) and not sampIsPlayerNpc(i) and sampGetPlayerScore(i) > 0 and i ~= playerId then
                    playerId = i
                    sampSendChat('/re '..playerId)
                    break
                end
            end
        else 
            sampSendChat('/re '..sampGetMaxPlayerId(false))
        end
    else 
        for i = playerId, 0, -1 do
  if sampIsPlayerConnected(i) and sampGetPlayerScore(i) ~= 0 and sampGetPlayerColor(i) ~= 16510045 and i ~= playerId and not sampIsPlayerNpc(i) then
    sampSendChat('/re '..i)
    break
  end
end
    end
      
    end imgui.SameLine()
        if imgui.Button(u8'/getstats', bet) then
          sampSendChat('/check '..playerId)
        end imgui.SameLine()
        if imgui.Button(u8'/getoffstats', bet) then
          sampSendChat('/offstats '..getNick(playerId))
        end 
        imgui.SameLine()
        if imgui.Button(u8'/slap', bet) then
          sampSendChat('/slap '..playerId)
        end 
        imgui.SameLine()
        if imgui.Button(u8'/freeze', bet) then
          sampSendChat('/freeze '..playerId)
        end 
        imgui.SameLine()
        if imgui.Button(u8'/unfreeze', bet) then
          sampSendChat('/unfreeze '..playerId)
        end 
        imgui.SameLine()
        if imgui.Button(u8'NEXT >>', bet) then
          if playerId == sampGetMaxPlayerId(false) then
            if not sampIsPlayerConnected(0) or sampGetPlayerScore(0) == 0 or sampGetPlayerColor(0) == 16510045 then
                for i = playerId, sampGetMaxPlayerId(false) do 
                    if sampIsPlayerConnected(i) and sampGetPlayerScore(i) > 0 and i ~= playerId and not sampIsPlayerNpc(i) then
                        playerId = i
                        sampSendChat('/re '..i)
                        break
                    end
                end
            else
                sampSendChat('/re 0')
            end 
        else 
            for i = playerId, sampGetMaxPlayerId(false) do 
                if sampIsPlayerConnected(i) and sampGetPlayerScore(i) > 0 and i ~= playerId and not sampIsPlayerNpc(i) then
                    playerId = i
                    sampSendChat('/re '..i)
                    break
                end
            end
        end
        end
        if imgui.Button(u8'/goto', bet) then
          lua_thread.create(function()
            sampSendChat('/reoff')
            wait(1000)
            sampSendChat('/goto '..playerId)
        end)
      end	
      imgui.SameLine()
      if imgui.Button(u8'AZ', bet) then
        lua_thread.create(function()
          AzId = playerId
          sampSendChat('/reoff')
          wait(1000)
          sampSendChat('/az')
          wait(10000)
          sampSendChat('/gethere '..AzId)
      end)
      end 
      imgui.SameLine()
      if imgui.Button(u8'/gethere', bet) then
        lua_thread.create(function()
          gethereId = playerId
          sampSendChat('/reoff')
          wait(1000)
          sampSendChat('/gethere '..gethereId)
      end)
      end 
      imgui.SameLine()
      if imgui.Button(u8'Дати життя', bet) then
        sampSendChat('/sethp '..playerId.. ' 100')
      end imgui.SameLine()
      if imgui.Button(u8'/gg', bet) then
        sampSendChat('/gg '..playerId)
      end 
      imgui.SameLine()
      if imgui.Button(u8'/uval', bet) then
        sampSendChat('/uval '..playerId.. ' 1')
      end 
      imgui.SameLine()
      if imgui.Button(u8'Вийти з /re', bet) then
        sampSendChat('/reoff')
        test_window.v = false
      end
    imgui.SetNextWindowPos(imgui.ImVec2(1100,400), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(690-500, 220), imgui.Cond.FirstUseEver)
    imgui.Begin(u8"InfoPanel", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings)
    local isPed, pPed = sampGetCharHandleBySampPlayerId(playerId)
    local score, ping = sampGetPlayerScore(playerId), sampGetPlayerPing(playerId)
    local health, armor, ammo, orgActive = sampGetPlayerHealth(playerId), sampGetPlayerArmor(playerId), getAmmoRecon(), getActiveOrganization(playerId)
    if ammo == 0 then
        ammo = u8'Немає'
    else
        ammo = getAmmoRecon()
    end
    if armor == 0 then
        armor = u8'Немає'
    else
        armor = sampGetPlayerArmor(playerId)
    end
        if isPed and doesCharExist(pPed) then
            local speed, model, interior = getCharSpeed(pPed), getCharModel(pPed), getCharActiveInterior(playerPed)
            imgui.Text(u8(getNick(playerId)..'['..playerId..']'))
            imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1.0, 2.5))
            imgui.Text(u8'Життя: '..health)
            imgui.Text(u8'Броня: '..armor)
            imgui.Text(u8'Рівень: '..score)
            imgui.Text(u8'Пінг: '..ping)
            if isCharInAnyCar(pPed) then
                imgui.Text(u8('Швидкість: В машині'))
            else
                imgui.Text(u8('Швидкість: '..math.floor(speed)))
            end
            imgui.Text(u8'Скін: '..model)
            if orgActive ~= nil then
              imgui.Text(u8'Організація: '..orgActive)
            elseif orgActive == nil then
                imgui.Text(u8'Організація: Немає')
           end
            imgui.Text(u8"Інтер'єр: "..interior)
            imgui.Text(u8"Кулі: "..ammo)
            imgui.PopStyleVar()
            local y = y + 196
          end
          imgui.End()
          imgui.End()
      end
  if helper_window.v then
    three_window.v = false
    imgui.SetNextWindowSize(imgui.ImVec2(930,460), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('CTOOLS', helper_window)
    lua_thread.create(function ()
        if imgui.Button(fa.ICON_TELEGRAM .. u8' Суть гри в /m - DERBI', imgui.ImVec2(150,70)) then
            sampSendChat('/m Озвучую суть гри для МП - ДЕРБІ!')
            wait(1000)
            sampSendChat('/m Ви повинні таранити друг друга...')
            wait(1000) 
            sampSendChat('/m ...До поки не останеться 1 виживший')
            wait(1000) 
            sampSendChat('/m Використовувати чіти заборонено.')
            wait(1000)
            sampSendChat('/m Починаємо на рахунок 3')
            wait(1000)
            sampSendChat('/m 1...')
            wait(2000)
            sampSendChat('/m 2...')
            wait(3000)
            sampSendChat('/m 3!!! Погнали!')
        end
    end)
    imgui.SameLine()
    lua_thread.create(function ()
        if imgui.Button(fa.ICON_TELEGRAM .. u8' Оповістити в /ao - DERBI', imgui.ImVec2(150,70)) then
            sampSendChat('/ao [ЗАХІД] Шановні гравці, зараз пройде захід - Дербі')
            wait(1000)
            sampSendChat('/ao [ЗАХІД] Спонсорси заходу - Я')
            wait(1000) 
            sampSendChat('/ao [ЗАХІД] Через 30 секунд відрию телепорт')
            wait(1000) 
            sampSendChat('/ao [ЗАХІД] Готуйте /mp')
        end
    end)
       lua_thread.create(function ()
        if imgui.Button(fa.ICON_TELEGRAM .. u8' Суть гри в /m - Хованки', imgui.ImVec2(150,70)) then
            sampSendChat('/m Озвучую суть гри для МП - Хованки!')
            wait(1000)
            sampSendChat('/m Ви повинні заховатись від адміністрації...')
            wait(1000) 
            sampSendChat('/m ...До поки не останеться 1 виживший')
            wait(1000) 
            sampSendChat('/m Використовувати чіти, анімки, баги заборонено.')
            wait(1000)
            sampSendChat('/m Починаємо на рахунок 3')
            wait(1000)
            sampSendChat('/m 1...')
            wait(2000)
            sampSendChat('/m 2...')
            wait(3000)
            sampSendChat('/m 3!!! Ховайтесь!')
        end
    end)
    imgui.SameLine()
        lua_thread.create(function ()
        if imgui.Button(fa.ICON_TELEGRAM .. u8' Оповістити в /ao - Хованки', imgui.ImVec2(150,70)) then
            sampSendChat('/ao [ЗАХІД] Шановні гравці, зараз пройде захід - Хованки')
            wait(1000)
            sampSendChat('/ao [ЗАХІД] Спонсорси заходу - Я. Приз: 50.000$')
            wait(1000) 
            sampSendChat('/ao [ЗАХІД] Через 30 секунд відкрию телепорт')
            wait(1000) 
            sampSendChat('/ao [ЗАХІД] Готуйте /mp')
        end
    end)
    imgui.End()
  end
end
function getAmmoRecon()
	local result, recon_handle = sampGetCharHandleBySampPlayerId(playerId)
	if result then
		local weapon = getCurrentCharWeapon(recon_handle)
		local struct = getCharPointer(recon_handle) + 0x5A0 + getWeapontypeSlot(weapon) * 0x1C
		return getStructElement(struct, 0x8, 4)
	end
end
function sampev.onShowTextDraw(id, data)
  for i, e in ipairs(td) do
      if e == id then
          return false
      end
  end
end
function sampev.onShowDialog(did, style, title, b1, b2, text)
  if did == 462 and text:find('Скарга від (%w+_%w+)%[(%d+)%]') then
      dial, but1, but2, tt = did, b1, b2, text:gsub('{%P+}','')
      imgui.Process =  china_window.v
  end
end

function getNearestVehicle(radius) 
  if not sampIsLocalPlayerSpawned() then return end
  local pVehicle = getLocalVehicle()
  local pCoords = {getCharCoordinates(PLAYER_PED)}
  local vehicles = getAllVehicles()
  table.sort(vehicles, function(a, b)
      local aX, aY, aZ = getCarCoordinates(a)
      local bX, bY, bZ = getCarCoordinates(b)
      return getDistanceBetweenCoords3d(aX, aY, aZ, unpack(pCoords)) < getDistanceBetweenCoords3d(bX, bY, bZ, unpack(pCoords))
  end)
  for i = #vehicles, 1, -1 do
      if vehicles[i] == pVehicle then
          table.remove(vehicles, i)
      elseif radius ~= nil then
          local x, y, z = getCarCoordinates(vehicles[i])
          if getDistanceBetweenCoords3d(x, y, z, unpack(pCoords)) > radius then
              table.remove(vehicles, i)
          end
      end
  end
  return vehicles[1]
end

function getLocalVehicle()
  return isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or nil
end

function initializeRender()
    font = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
    font2 = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
  end
  function getActiveOrganization(id)
    local color = sampGetPlayerColor(id)
    if color == 553648127 then
      organization = u8'Немає'
    elseif color == 2854633982 then
      organization = u8'LSPD'
    elseif color == 2855350577 then
      organization = u8'FBI'
    elseif color == 2855512627 then
      organization = u8'Армія'
    elseif color == 4289014314 then
      organization = u8'Лікарня'
    elseif color == 4292716289 then
      organization = u8'Італійська мафія'
    elseif color == 2868838400 then
      organization = u8'Якудза'
    elseif color == 4279324017 then
      organization = u8'Уряд'
    elseif color == 2854633982 then
      organization = u8'SFPD['
    elseif color == 4279475180 then
      organization = u8'Ліцензери['
    elseif color == 4287108071 then
      organization = u8'Баллас'
    elseif color == 2866533892 then
      organization = u8'Вагос'
    elseif color == 4290033079 then
      organization = u8'Мафія'
    elseif color == 2852167424 then
      organization = u8'Грув'
    elseif color == 2856354955 then
      organization = u8'Sa News'
    elseif color == 3355573503 then
      organization = u8'Ацтеки'
    elseif color == 2860761023 then
      organization = u8'Ріфа'
    elseif color == 2854633982 then
      organization = u8'LVPD'
    elseif color == 2859499664 then
      organization = u8'Уряд'
    elseif color == 8025703 then
      organization = u8'В масці'
    end
    return organization
  end

  
function onSendPacket(id)
	if id == PACKET_VEHICLE_SYNC and tpres then
		return false
  end
end


function ctp()
  tpres = true
end


  
  --- Functions
  function rotateCarAroundUpAxis(car, vec)
    local mat = Matrix3X3(getVehicleRotationMatrix(car))
    local rotAxis = Vector3D(mat.up:get())
    vec:normalize()
    rotAxis:normalize()
    local theta = math.acos(rotAxis:dotProduct(vec))
    if theta ~= 0 then
      rotAxis:crossProduct(vec)
      rotAxis:normalize()
      rotAxis:zeroNearZero()
      mat = mat:rotate(rotAxis, -theta)
    end
    setVehicleRotationMatrix(car, mat:get())
  end
  
  function readFloatArray(ptr, idx)
    return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
  end
  function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end
  
  function writeFloatArray(ptr, idx, value)
    writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
  end
  
  function getVehicleRotationMatrix(car)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
      local mat = readMemory(entityPtr + 0x14, 4, false)
      if mat ~= 0 then
        local rx, ry, rz, fx, fy, fz, ux, uy, uz
        rx = readFloatArray(mat, 0)
        ry = readFloatArray(mat, 1)
        rz = readFloatArray(mat, 2)
  
        fx = readFloatArray(mat, 4)
        fy = readFloatArray(mat, 5)
        fz = readFloatArray(mat, 6)
  
        ux = readFloatArray(mat, 8)
        uy = readFloatArray(mat, 9)
        uz = readFloatArray(mat, 10)
        return rx, ry, rz, fx, fy, fz, ux, uy, uz
      end
    end
  end
  
  function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
      local mat = readMemory(entityPtr + 0x14, 4, false)
      if mat ~= 0 then
        writeFloatArray(mat, 0, rx)
        writeFloatArray(mat, 1, ry)
        writeFloatArray(mat, 2, rz)
  
        writeFloatArray(mat, 4, fx)
        writeFloatArray(mat, 5, fy)
        writeFloatArray(mat, 6, fz)
  
        writeFloatArray(mat, 8, ux)
        writeFloatArray(mat, 9, uy)
        writeFloatArray(mat, 10, uz)
      end
    end
  end
  
  function displayVehicleName(x, y, gxt)
    x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
    useRenderCommands(true)
    setTextWrapx(640.0)
    setTextProportional(true)
    setTextJustify(false)
    setTextScale(0.33, 0.8)
    setTextDropshadow(0, 0, 0, 0, 0)
    setTextColour(255, 255, 255, 230)
    setTextEdge(1, 0, 0, 0, 100)
    setTextFont(1)
    displayText(x, y, gxt)
  end
  
  function createPointMarker(x, y, z)
    pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
  end
  
  function removePointMarker()
    if pointMarker then
      removeUser3dMarker(pointMarker)
      pointMarker = nil
    end
  end
  
  function getCarFreeSeat(car)
    if doesCharExist(getDriverOfCar(car)) then
      local maxPassengers = getMaximumNumberOfPassengers(car)
      for i = 0, maxPassengers do
        if isCarPassengerSeatFree(car, i) then
          return i + 1
        end
      end
      return nil -- no free seats
    else
      return 0 -- driver seat
    end
  end
  
  function jumpIntoCar(car)
    local seat = getCarFreeSeat(car)
    if not seat then return false end                         -- no free seats
    if seat == 0 then warpCharIntoCar(playerPed, car)         -- driver seat
    else warpCharIntoCarAsPassenger(playerPed, car, seat - 1) -- passenger seat
    end
    restoreCameraJumpcut()
    return true
  end
  
  function teleportPlayer(x, y, z)
    if isCharInAnyCar(playerPed) then
      setCharCoordinates(playerPed, x, y, z)
    end
    setCharCoordinatesDontResetAnim(playerPed, x, y, z)
  end
  
  function setCharCoordinatesDontResetAnim(char, x, y, z)
    if doesCharExist(char) then
      local ptr = getCharPointer(char)
      setEntityCoordinates(ptr, x, y, z)
    end
  end
  
  function setEntityCoordinates(entityPtr, x, y, z)
    if entityPtr ~= 0 then
      local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
      if matrixPtr ~= 0 then
        local posPtr = matrixPtr + 0x30
        writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
        writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
        writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
      end
    end
  end
  
  function showCursor(toggle)
    if toggle then
      sampSetCursorMode(CMODE_LOCKCAM)
    else
      sampToggleCursor(false)
    end
    cursorEnabled = toggle
  end


function darkgreentheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 6
    style.ChildWindowRounding = 5
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 8
    style.GrabRounding = 1
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
    colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
    colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
    colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
    colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
    colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
    colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
    colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
    colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
    colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
    colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
end
darkgreentheme()

