---- ##########################################################################################################
---- #                                                                                                        #
---- # FLVSS ETHOS                                                                                            #
---- #                                                                                                        #
---- # Widget to show Lipo information                                                                        #
---- #                                                                                                        #
---- # Compatible with lipo sources like MLVSS and FLVSS Sensors                                              #
---- # Gives a aproximate percentage of a Lipo battery pack left.                                             #
---- #                                                                                                        #
---- #                                                                                                        #
---- # License GPLv3: http://www.gnu.org/licenses/gpl-3.0.html                                                #
---- #                                                                                                        #
---- # This program is free software; you can redistribute it and/or modify                                   #
---- # it under the terms of the GNU General Public License version 3 as                                      #
---- # published by the Free Software Foundation.                                                             #
---- #                                                                                                        #
---- # Version: 1.0.2                                                                                         #
---- # William Mayvis (c) 2022                                                                                #
---- #                                                                                                        #
---- ##########################################################################################################
 
 
local translations = {en="iOs style FLVSS"}
local voltageFiltered  = 0   
local Time_Temp = 0
local version

local hapticPatterns = {
      {"-", 0},
      {"--", 1},
      {"---", 2},
      {"------", 3},
      {".", 4},
      {"..", 5},
      {"...", 6},
      {".....", 7},
      {".-", 8},
      {"..-", 9},
      {".-.", 10},
      {"-.-", 11}
}

local function playHaptic(value) 
  for i, v in ipairs(hapticPatterns) do
    if v[2] == value then
         system.playHaptic(v[1])
       break
    end
  end
end
    

local function calculatePercentage(voltageSource, cellCount)
    
    voltageSource = tonumber(voltageSource)
    
     -- the following table of percentages has 121 percentage values ,
     -- starting from 3.0 V to 4.2 V , in steps of 0.01 V 
    voltageFiltered = voltageFiltered * 0.9  +  voltageSource * 0.1
 
    local percentTable = 
    {0  , 1  , 1  ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 ,  1 , 
     2  , 2  , 2  ,  2 ,  2 ,  2 ,  2 ,  2 ,  2 ,  2 ,  3 ,  3 ,  3 ,  3 ,  3 ,  3 ,  3 ,  3 ,  3 ,  3 , 
     4  , 4  , 4  ,  4 ,  4 ,  4 ,  4 ,  4 ,  5 ,  5 ,  5 ,  5 ,  5 ,  5 ,  6 ,  6 ,  6 ,  6 ,  6 ,  6 , 
     7  , 7  , 7  ,  7 ,  8 ,  8 ,  9 ,  9 , 10 , 12 , 13 , 14 , 17 , 19 , 20 , 22 , 23 , 26 , 28 , 30 , 
     33 , 36 , 39 , 42 , 45 , 48 , 51 , 54 , 57 , 58 , 60 , 62 , 64 , 66 , 67 , 69 , 70 , 72 , 74 , 75 , 
     77 , 78 , 80 , 81 , 82 , 84 , 85 , 86 , 86 , 87 , 88 , 89 , 91 , 92 , 94 , 95 , 96 , 97 , 97 , 99 , 100  }
   
    cellCount = tonumber(cellCount) 
    if cellCount > 0 then 

      local voltageCell    = 3
      local batteryPercent = 0
      local i = 1
      
      voltageSource = voltageSource * 100
      voltageCell = voltageSource / cellCount
      i = math.floor(voltageCell - 298)
      
      if i > 120 then
        i = 120
      end
      
      if i < 1 then
        i = 1
      end
      
      return percentTable[i]
    end
end

local function setColor(percent)
       g = math.floor(0xDF * percent / 100)
       r = 0xDF - g
       lcd.color(lcd.RGB(r, g, 0))
 end

local function drawCircledProgress(xPos, yPos, radius, startAngle, endAngle, percentage, showPercentage, sensorValue)
  lcd.color(lcd.RGB(40, 40, 40))
  
  lcd.drawCircle(
      xPos,
      yPos,
      radius --35
    )
    
    local extRadius = radius + 5
    setColor(percentage)
    lcd.drawAnnulusSector(
      xPos,
      yPos,
      0,
      extRadius,
      startAngle,
      endAngle
    )
    
    lcd.color(lcd.RGB(255,255,255))
    lcd.drawCircle(
    xPos,
    yPos,
    radius - 5)
    
    lcd.color(lcd.RGB(40, 40, 40))
    lcd.drawFilledCircle(
      xPos,
      yPos,
      radius - 6
    )
    
    lcd.font(FONT_XS_BOLD)
    lcd.color(lcd.RGB(255,255,255))
    if showPercentage then
      lcd.drawText(
          xPos + 3,
          yPos - 7,
          percentage .. "%",
          CENTERED)
    else
      lcd.drawText(
          xPos + 3,
          yPos - 7,
          sensorValue,
          CENTERED)
    end 
end

local function paintScreen(Me, widget)
  count = count + 1
  local y = 40
  local icon_height = 32
  
  local w, h = lcd.getWindowSize()
  
  local percentage = calculatePercentage(widget.LipoSensor:value(), widget.LipoSensor:stringValue(OPTION_CELL_COUNT))

  local angle = (percentage / 100) * 360
  local margin = 10
  local total_height = (icon_height + margin) * widget.LipoSensor:value(OPTION_CELL_COUNT)
  local cursor_y = 0

  x = w / 2
  y = h / 2

  local cellCount = tonumber(widget.LipoSensor:stringValue(OPTION_CELL_COUNT))

  drawCircledProgress(60, (total_height * 0.1) + 25 + cursor_y, 35, 0, angle, percentage, true, widget.LipoSensor:stringValue())

  lcd.font(FONT_S)
  lcd.drawText(110, (total_height * 0.1) + 10,  widget.LipoSensor:stringValue(OPTION_CELL_COUNT) .. " cells")

  lcd.font(FONT_L_BOLD)
  setColor(percentage)
  lcd.drawText(110, (total_height * 0.1) + 30,  widget.LipoSensor:stringValue())  

  x = 60
  y = (total_height * 0.1) + 110 + cursor_y
  for i = 1, widget.LipoSensor:value(OPTION_CELL_COUNT) do
    local cellPercentage = calculatePercentage(widget.LipoSensor:value(OPTION_CELL_INDEX(i)), 1)
    
    local cellAngle = (cellPercentage / 100) * 360
    lcd.font(FONT_XS)
    
    if x >= w then
      x = 60
      y = y + 70
    end
    
    drawCircledProgress(x, y, 30, 0, angle, percentage, false, widget.LipoSensor:stringValue(OPTION_CELL_INDEX(i)))
    x = x + 87
  end
  
  if count > lowBattCycleTime * 3.3 then
    if battAlertOnOff and (tonumber(lipoPackVoltage) < lowBattAlert / 10) then
      print ("Battery drained")
      system.playFile("/scripts/flvss/lowbat.wav")
      
      if widget.enableHaptic == true then
        playHaptic(widget.fieldPattern)
      end
    end
  end
end

local function writeNoSensor(Me)
    lcd.color(WHITE)
    local screen_width, screen_height = lcd.getWindowSize()
    lcd.drawText(screen_width*0.35,screen_height*0.30,"Please")
    lcd.drawText(screen_width*0.35,screen_height*0.45,"Setup")
    lcd.drawText(screen_width*0.35,screen_height*0.60,"LiPo sensor.")
end

local function showModal()
    local buttons = {
      {
        label="Close", action=function() end
      }
    }
    form.openDialog("About flvss", "Version " .. version .. "\n" 
      .. "iOS style flvss" .. "\n" 
      .. "(c) 2022 William Mayvis\n" 
      .. "For more information\n" 
      .. "https://github.com/wmayvis/FrSky-Lua", 
      buttons
    )
end

local function name(widget)
    local locale = system.getLocale()
    return translations[locale] or translations["en"]
end
 
local function create()
  return {r=255, g=255, b=255, OnOff=false, source=nil, min=-1024, max=1024, value=0,  LowBattCycleTime=5, BattAlertOnOff = true, LowBattAlert = 1000, LipoSensor = nil, enableHaptic = false}
end

local function menu(widget)
    return {
        {"FLVSS V"..version,
          function()
        end
        },
        {"About",
          function()
            showModal()
          end
        }
    }
end

local function paint(widget)
---------------------------------------------  
  if (Init == false) then
    Init = true
  end
---------------------------------------------
  battAlertOnOff = widget.enableBattAlert
  lowBattAlert = widget.LowBattAlert
  lowBattCycleTime  = widget.LowBattCycleTime
  
  if widget.LipoSensor ~= nil then
    if widget.LipoSensor:name() ~= "---" then
      lipoSensor = widget.LipoSensor:name ()
      
      numberOffCells = widget.LipoSensor:stringValue(OPTION_CELL_COUNT)
      
      lipoSensorSource  = system.getSource(LipoSensor)
      lipoPackVoltage = lipoSensorSource:value()
      
      paintScreen(Me, widget)
    else 
       writeNoSensor(Me)
    end
  else
      writeNoSensor(Me)
  end
end

local function wakeup(widget)
  newValue = os.clock()
  if newValue > Time_Temp then
    Time_Temp = newValue
    lcd.invalidate()
  end
end

local function configure(widget)
  
  -- Low battery Warnring
  line = form.addLine("Low battery parameters:")
	line = form.addLine("Low battery warning")	
  local lowBattSlots = form.getFieldSlots(line, {0})
  
  widget.battAlertField = form.addBooleanField(line, form.getFieldSlots(line)[0], 
    function() 
      return widget.enableBattAlert 
    end, 
    function(value) 
      widget.enableBattAlert = value
      widget.field_alertVolt:enable(value)
      widget.field_AlertRate:enable(value)
    end
  );
  
	line = form.addLine("Batt Alert (x0.1V)")
	local slots = form.getFieldSlots(line, {0})
	widget.field_alertVolt = form.addNumberField(line, slots[1], 1, 252, 
    function() 
      return widget.LowBattAlert 
    end, 
    function(value) 
      widget.LowBattAlert = value 
      
    end
  );
 
  widget.field_alertVolt:enable(widget.enableBattAlert)
  
  line = form.addLine("Low battery cycle time (s)")
  slots = form.getFieldSlots(line, {0}) -- Batt Alert Rate
	widget.field_AlertRate = form.addNumberField(line, slots[1], 1, 10, 
    function() 
      return widget.LowBattCycleTime 
    end, 
    function(value) 
      widget.LowBattCycleTime = value 
    end);
  
  widget.field_AlertRate:enable(widget.enableBattAlert)
  
  -- Haptic Enable
  line = form.addLine("Haptic Selection:")
  line = form.addLine("Enable")
  local hapticSlots = form.getFieldSlots(line, {0})
  widget.field_haptic = form.addBooleanField(line, form.getFieldSlots(line)[0],
    function()
      return widget.enableHaptic 
    end,
    function(value)
      widget.enableHaptic = value
      widget.fieldPattern:enable(widget.enableHaptic)
    end)
  
  -- Haptic Pattern
  line = form.addLine("Pattern")
  local patternSlots = form.getFieldSlots(line, {0})
  widget.fieldPattern = form.addChoiceField(line, form.getFieldSlots(line)[0], hapticPatterns,
    function() 
      return widget.fieldPattern
    end,
    
    function(value)
      playHaptic(value)
      widget.fieldPattern = value
    end)
  widget.fieldPattern:enable(widget.enableHaptic)
  
	line = form.addLine("Sensor Selection:")
	-- Source choice
    line = form.addLine("Lipo Sensor")
    form.addSourceField(line, nil, 
      function() 
        return widget.LipoSensor 
      end, 
      function(value) 
        widget.LipoSensor = value 
      end)
  
  line = form.addLine("iOs style flvss")
  line = form.addLine("Version : V" .. version)
 end

local function read(widget)
	widget.enableBattAlert = storage.read("BattAlertOnOff")
	widget.LowBattAlert 	= storage.read("LowBattAlert")
	widget.LowBattCycleTime = storage.read("LowBattCycleTime")
	widget.LipoSensor		= storage.read("LipoSensor")
  widget.enableHaptic = storage.read("enableHaptic")
  widget.fieldPattern = storage.read("fieldPattern")

end

local function write(widget)
	storage.write("BattAlertOnOff", widget.enableBattAlert)
	storage.write("LowBattAlert" , widget.LowBattAlert)
	storage.write("LowBattCycleTime", widget.LowBattCycleTime)
	storage.write("LipoSensor", widget.LipoSensor)
  storage.write("enableHaptic", widget.enableHaptic)
  storage.write("fieldPattern", widget.fieldPattern)

end
 
local function init()
  cellsLowbatterySound = "/scripts/flvss/lowbat.wav"
  count = 0
  version = "1.0.2"
  system.registerWidget({key="flvss", name=name, create=create, paint=paint, wakeup=wakeup, menu=menu, configure=configure, read=read, write=write})
  Init = false
end

return {init=init}
 