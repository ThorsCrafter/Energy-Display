-- Energieanzeige --
-- von Thor_s_Crafter --
-- Version 1.1 --

--Globale Variablen
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

--Finde Monitor & Energiespeicher
function initPeripherals()
  --Table fuer alle Peripherals
  local per = peripheral.getNames()
  
  --Iteriert ueber die gefundenen Geraete
  for i=1,#per do
  
    --Monitor
    if peripheral.getType(per[i]) == "monitor" then
      mon = peripheral.wrap(per[i])
      x,y = mon.getSize()
      x2 = x/2
      mon.setBackgroundColor(colors.gray)
      
    --Energiespeicher
    elseif peripheral.getType(per[i]) == "draconic_rf_storage" then
      c = peripheral.wrap(per[i])
    elseif peripheral.getType(per[i]) == "tile_blockcapacitorbank_name" then
      c = peripheral.wrap(per[i])
    elseif peripheral.getType(per[i]) == "capacitor_bank" then
      c = peripheral.wrap(per[i])
    end
  end
end

function getTime()
  local time = os.time()
  return textutils.formatTime(time, true)
end

--Loescht den gesamten Bildschirm
function clearAll()
  term.clear()
  term.setCursorPos(1,1)
  mon.clear()
end

--Formatiert grosse Zahlenwerte in String (z.B. 1.000)
function format(value)
  --Werte kleiner 1000 muessen nicht formatiert werden
  if value < 1000 then return value end
  
  --Legt Berechnungsvariablen fest
  local array = {}
  local vStr = tostring(value)
  local len = string.len(vStr)
  local modulo = math.fmod(len,3)
  
  --Speichert einzelne Ziffern in einem Array ab
  for i=1,len do array[i] = string.sub(vStr,i,i) end
  
  --Legt (max. 2) Ziffern am Anfang in ein extra Array und entfernt
  --Diese aus dem alten Array
  local array2 = {}
  if modulo ~= 0 then
    for i=1,modulo do
      array2[i] = array[i]
      table.remove(array,i)
    end
  end
  
  --Fuegt die Punkte als Feld im ersten Array ein
  for i=1,#array+1,4 do
    table.insert(array,i,".")
  end
  
  --Fuegt beide Arrays zusammen
  for i=#array2,1,-1 do table.insert(array,1,array2[i]) end
  if modulo == 0 then table.remove(array,1) end --Entfernt ggf. Punkt am Anfang
  
  --Wandelt alles in einen String zurueck und gibt diesen zurueck
  local final = ""
  for k,v in pairs(array) do final = final..v end
  return final
end

--Liest die aktullen Energiewerte aus
function getEnergy()
  en = c.getEnergyStored()
  enMax = c.getMaxEnergyStored()
  enPer = math.floor(en/enMax*100)

  --Debug
  term.setCursorPos(1,1)
  print("En: "..en)
  print("EnMax: "..enMax)
  print("EnPer: "..enPer)
end

--Berechnet Energieveraenderungen (Intervall: 1s)
function getInOut()
  --Erster Wert
  getEnergy()
  local tmp1 = en
  sleep(0.5)
  
  --Zweiter Wert
  getEnergy()
  local tmp2 = en
  
  --Differenz beider Werte
  local inOutTmp = math.floor((tmp2-tmp1)/10)

  --Setzt inOut (final)
  inOut = inOutTmp

  --Debug
  term.setCursorPos(1,4)
  print("tmp1: "..tmp1)
  print("tmp2: "..tmp2)
  print("inOutTmp: "..inOutTmp)
  print("inOut: "..inOut)

  --Setzt die Textfarbe
  if inOut > 0 then ioCol = colors.green ioPre = "+"
  elseif inOutTmp < 0 then ioCol = colors.red ioPre = "-"
  elseif inOutTmp == 0 then ioCol = colors.white ioPre = "+/-" end
end

--Berechnet Energieveraenderungen (Intervall: 5s)
function getInOut5()
  getEnergy()
  if timerVar == 0 then
    ioTmp1 = en
    timerVar = timerVar + 1
  elseif timerVar == 10 then
    timerVar = 0
    ioTmp2 = en
    inOut5 = math.floor((ioTmp2 - ioTmp1)/100)
  else
    timerVar = timerVar + 1
  end
  term.setCursorPos(1,8)
  print("inOut5: "..inOut5)
  if inOut5 > 0 then ioCol5 = colors.green ioPre5 = "+"
  elseif inOut5 < 0 then ioCol5 = colors.red ioPre5 = "-"
  elseif inOut5 == 0 then ioCol5 = colors.white ioPre5 = "+/-" end
end


--Zeichnet eine Energieleiste
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

--Gibt saemtliche Daten auf dem Bildschirm aus
function printStats()
  --Ueberschrift
  mon.setCursorPos(1,1)
  mon.write("Energieanzeige")
  local time = getTime()
  mon.setCursorPos((x-string.len(time)-1),1)
  mon.write(time.."h")

  mon.setCursorPos(1,2)
  for i=1,x do
    mon.write("-")
  end
 
  --Energie (in % + Energieleiste)
  mon.setCursorPos(x2-2,4)
  mon.write(enPer.."%  ")
  printBar()
  
  --Energie (total)
  mon.setCursorPos(1,7)
  mon.write("Total: "..format(en).."RF         ")
  
  --Energie (max.)
  mon.setCursorPos(1,8)
  mon.write("Gesamt: "..format(enMax).."RF   ")
  
  --Energie (In/Out)
  mon.setCursorPos(1,10)
  mon.write("In/Out: ")
  mon.setTextColor(ioCol)
  mon.write(ioPre..format(math.abs(inOut)).."RF/t      ")
  mon.setTextColor(colors.white)

   --Energie (In/Out)(5s.)
  mon.setCursorPos(1,11)
  mon.write("In/Out (5s): ")
  mon.setTextColor(ioCol5)
  mon.write(ioPre5..format(math.abs(inOut5)).."RF/t      ")
  mon.setTextColor(colors.white)
end

--Programmstart
initPeripherals()
clearAll()
--Hauptschleife
while true do
  getEnergy()
  getInOut()
  getInOut5()
  printStats()
end

