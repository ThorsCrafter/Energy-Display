-- Energiy display --
-- by Thor_s_Crafter --
-- Version 1.1 --

--Global variables
local mon
local c
local en
local enMax
local enPer
local inOut
local ioCol
local ioPre
local x,y
local x2
local timerVar = 0
local ioTmp1
local ioTmp2
local inOut5 = 0
local ioPre5
local ioCol5

--Finds Monitor & energy storage
function initPeripherals()

  --Table for all peripherals
  local per = peripheral.getNames()
  
  --Checks all attached peripherals
  for i=1,#per do
  
    --Monitor
    if peripheral.getType(per[i]) == "monitor" then
      mon = peripheral.wrap(per[i])

      --Some global settings for the monitor
      x,y = mon.getSize()
      x2 = x/2
      mon.setBackgroundColor(colors.gray)
      
    --Energy storage
    elseif peripheral.getType(per[i]) == "draconic_rf_storage" then
      c = peripheral.wrap(per[i])
    elseif peripheral.getType(per[i]) == "tile_blockcapacitorbank_name" then
      c = peripheral.wrap(per[i])
    elseif peripheral.getType(per[i]) == "capacitor_bank" then
      c = peripheral.wrap(per[i])
    end
  end
end

--Returns the current local time (formatted, 24h format)
function getTime()
  local time = os.time()
  return textutils.formatTime(time, true)
end

--Clears the entire screen and the terminal
function clearAll()
  term.clear()
  term.setCursorPos(1,1)
  mon.clear()
end

--Formats big numbers into a string (e.g. 1000 -> 1.000)
function format(value)

  --Values smaller 1000 doesn't need to be formatted
  if value < 1000 then return value end
  
  --Some calculation variables
  local array = {}
  local vStr = tostring(value)
  local len = string.len(vStr)
  local modulo = math.fmod(len,3)
  
  --Saves digits into a table (array)
  for i=1,len do array[i] = string.sub(vStr,i,i) end
  
  --Moves additional digits into a second table (array)
  local array2 = {}
  if modulo ~= 0 then
    for i=1,modulo do
      array2[i] = array[i]
      table.remove(array,i)
    end
  end
  
  --Adds the dots into the first array
  for i=1,#array+1,4 do
    table.insert(array,i,".")
  end
  
  --Merges both arrays
  for i=#array2,1,-1 do table.insert(array,1,array2[i]) end
  if modulo == 0 then table.remove(array,1) end --Removes front dots
  
  --Converts everything into a string and returns it
  local final = ""
  for k,v in pairs(array) do final = final..v end
  return final
end

--Getts the current energy values
function getEnergy()
  en = c.getEnergyStored()
  enMax = c.getMaxEnergyStored()
  enPer = math.floor(en/enMax*100)

  --Debug prints
  term.setCursorPos(1,1)
  print("En: "..en)
  print("EnMax: "..enMax)
  print("EnPer: "..enPer)
end

--Calculates energy changes (interval: 1s)
function getInOut()

  --First value
  getEnergy()
  local tmp1 = en
  sleep(0.5)
  
  --Second value
  getEnergy()
  local tmp2 = en
  
  --Calculates the difference of both values
  local inOutTmp = math.floor((tmp2-tmp1)/10)

  --Sets inOut (finally)
  inOut = inOutTmp

  --Debug prints
  term.setCursorPos(1,4)
  print("tmp1: "..tmp1)
  print("tmp2: "..tmp2)
  print("inOutTmp: "..inOutTmp)
  print("inOut: "..inOut)

  --Sets the text color & the prefix
  if inOut > 0 then ioCol = colors.green ioPre = "+"
  elseif inOutTmp < 0 then ioCol = colors.red ioPre = "-"
  elseif inOutTmp == 0 then ioCol = colors.white ioPre = "+/-" end
end

--Calculates energy changes (interval: 5s)
function getInOut5()
  getEnergy() --Gets the current energy

  --Gets the first value at time code 0
  if timerVar == 0 then
    ioTmp1 = en
    timerVar = timerVar + 1

  --Gets the second value at time code 10 (= 5s)
  elseif timerVar == 10 then
    timerVar = 0
    ioTmp2 = en

    --Sets inOut5
    inOut5 = math.floor((ioTmp2 - ioTmp1)/100)
  
  --Increments timer
  else
    timerVar = timerVar + 1
  end

  --Debug print
  term.setCursorPos(1,8)
  print("inOut5: "..inOut5)

  --Sets the text color and the prefix
  if inOut5 > 0 then ioCol5 = colors.green ioPre5 = "+"
  elseif inOut5 < 0 then ioCol5 = colors.red ioPre5 = "-"
  elseif inOut5 == 0 then ioCol5 = colors.white ioPre5 = "+/-" end
end


--Draws the energy bar
function printBar()
  local part1 = enPer/5
  mon.setCursorPos(x2-10,5)
  mon.setTextColor(colors.white)
  mon.write("|--------------------|")
  mon.setTextColor(colors.green)
  mon.setCursorPos(x2-9,5)
  for i=1,part1 do
    mon.write("=")
  end
  mon.setTextColor(colors.white)
end

--Prints all data onto the screen
function printStats()

  --Caption
  mon.setCursorPos(1,1)
  mon.write("Energieanzeige")
  local time = getTime()
  mon.setCursorPos((x-string.len(time)-1),1)
  mon.write(" "..time.."h")

  mon.setCursorPos(1,2)
  for i=1,x do
    mon.write("-")
  end
 
  --Energy (in % + the energy bar)
  mon.setCursorPos(x2-2,4)
  mon.write(enPer.."%  ")
  printBar()
  
  --Energy (current)
  mon.setCursorPos(1,7)
  mon.write("Total: "..format(en).."RF         ")
  
  --Energy (max)
  mon.setCursorPos(1,8)
  mon.write("Gesamt: "..format(enMax).."RF   ")
  
  --Energy (In/Out)
  mon.setCursorPos(1,10)
  mon.write("In/Out: ")
  mon.setTextColor(ioCol)
  mon.write(ioPre..format(math.abs(inOut)).."RF/t      ")
  mon.setTextColor(colors.white)

   --Energy (In/Out)(5s)
  mon.setCursorPos(1,11)
  mon.write("In/Out (5s): ")
  mon.setTextColor(ioCol5)
  mon.write(ioPre5..format(math.abs(inOut5)).."RF/t      ")
  mon.setTextColor(colors.white)
end

--Start
initPeripherals()
clearAll()

--Main loop
while true do
  getEnergy()
  getInOut()
  getInOut5()
  printStats()
end

