-- wget -f 'https://raw.githubusercontent.com/Pozitrone/Arolib/master/AroLib.lua' /home/arolib.lua

-- import these functions using
-- arolib = require("arolib")

-- run using
-- arolib.function()

---------------------------------------

-- Imports

local sides = require("sides")
local colors = require("colors")
local event = require("event")

-- Colors
clrRed = 0xFF0000
clrBlue = 0x0000FF
clrGreen = 0x0FF00
clrWhite = 0xFFFFFF
clrBlack = 0x000000
clrYellow = 0xFFFF00
clrOrange = 0xFFAA00

-- Functions

function tempBar(temp,x,y,maxtemp)
    local bg = require("component").gpu.getBackground();
    tempStage = math.floor(temp/(maxtemp/40));
    for i = 0, tempStage, 1 do
        if i <= 5 then
            require("component").gpu.setBackground(0x0000FF)
        elseif i <= 10 then
            require("component").gpu.setBackground(0x3300FF)
        elseif i <= 15 then
            require("component").gpu.setBackground(0x6600FF)
        elseif i <= 20 then
            require("component").gpu.setBackground(0x9900FF)
        elseif i <= 25 then
            require("component").gpu.setBackground(0xCC00C0)
        elseif i <= 30 then
            require("component").gpu.setBackground(0xFF0080)
        elseif i <= 35 then
            require("component").gpu.setBackground(0xFF0040)
        else
            require("component").gpu.setBackground(0xFF0000)
        end
        require("component").gpu.fill(x,y+40-i,20,1," ")
    end
    require("component").gpu.setBackground(bg)
end

-- Library

local arolib = {}

function arolib.help()
    print("tps(): number - calculates TPS")
    print("farmsControl(): void - outputs redstone in the front if TPS > 15")
    print("colortps(tps: number): void - prints out tps in a color")
    print("draconicCore(): void - constant status of Draconic storage core")
    print("reset(): void - resets the resolution")
    print("extremeReactorStats(reactorName: string): void - controls for extremeReactors")
    print("help() - shows this list")
end


function arolib.tps() -- TPS function by Nex4rius
    if not pcall(
        function()
            local function time()
                local f = io.open("/tmp/TPS","w")
                f:write("Woof!")
                f:close()
                return(require("filesystem").lastModified("/tmp/TPS"))
            end

            local realTimeOld = time()
            os.sleep(1)
            ticks = 20000 / (time() - realTimeOld)
            if ticks > 20 then
                return 20
            else
                return ticks
            end
        end
    ) then
        print("An Error ocurred. Your harddrive might not have enough capacity.")
    end
end


function arolib.farmsControl() -- Outputs redstone from the back, when tps > 15, else stops the signal. Checks every 10 seconds.
    if not pcall(
        function()
            while true do
                local tps = tps()
                if tps > 15 then
                    print("TPS status nominal, farms running.")
                    colortps(tps)
                    require("component").redstone.setOutput(sides.back, 15)
                else
                    print("TPS are too low, farm are not running!")
                    colortps(tps)
                    require("component").redstone.setOutput(sides.back, 0)
                end
                os.sleep(10)
            end
        end
    ) then
        print("An Error occured. Check, if a redstone card is present.")
    end
end


function arolib.colortps() -- Prints out TPS in according color
    if not pcall(
        function()
            tps = arolib.tps()
            if tps > 15 then
                require("component").gpu.setForeground(clrGreen)
            elseif tps > 5 then
                require("component").gpu.setForeground(clrOrange)
            else
                require("component").gpu.setForeground(clrRed)
            end
            print(tps)
            require("component").gpu.setForeground(clrWhite)
        end
    ) then
        print("An error occured.")
    end
end


function arolib.draconicCore()
    if not pcall(
        function()
            local core = require("component").draconic_rf_storage
            print("use arolib.reset(), or reboot, to reset the Resolution back.");
            os.sleep(4)
            require("component").gpu.setResolution(40,7);
            require("term").clear()
            while true do
                print("Energy stored: ")
                print(core.getEnergyStored())
                print("Maximum energy: ")
                print(core.getMaxEnergyStored())
                print("Transfering: ")
                local rate = core.getTransferPerTick()
                if rate > 0 then 
                    require("component").gpu.setForeground(clrGreen)
                else
                    require("component").gpu.setForeground(clrRed)
                end
                print(rate)
                require("component").gpu.setForeground(clrWhite)
                os.sleep(1)
            end
        end
    ) then
        print("An error occured. Please, make sure a draconic energy storage core is connected.")
    end
end

function arolib.reset()
    if not pcall(
        function()
            require("component").gpu.setResolution(160,50);
            require("term").clear()
        end
    ) then
        print("An error occured.")
    end
end

function arolib.extremeReactorStats(reactorName)
    --if not pcall(
        --function()
            local term = require("term")
            local gpu = require("component").gpu
            local reactor = require("component").br_reactor
            local iteration = 0;

            while true do
                gpu.setBackground(0x000000)
                term.clear()
                gpu.setForeground(0x000000)

                gpu.setBackground(0xD2D2D2)

                gpu.fill(1,1,74,3," ") --reactor name
                gpu.set(7,2,reactorName) -- reactor name text

                gpu.fill(87,1,74,3," ") --reactor type
                if reactor.isActivelyCooled() then
                    reactorType = "Actively cooled"
                else
                    reactorType = "Passively cooled"
                end
                gpu.set(91,2,reactorType) -- reactor type text

                gpu.fill(60,5,90,3," ") -- General info field
                gpu.set(75,5,"General info") -- General info text

                gpu.fill(7,5,46,3," ") -- Temperatures
                gpu.set(8,6,"Core"); -- Core temp text
                gpu.set(34,6,"Casing"); -- Casing temp text

                gpu.fill(7,9,20,40," ") --Core temp bar
                gpu.fill(33,9,20,40," ") --Casing temp bar

                gpu.fill(60,36,40,13," ") --battery main
                gpu.fill(100,41,2,3," ") --battery bit

                --button
                gpu.fill(108,36,44,13," ") --button
                --end button

                -- Core temperature
                coreTemp = reactor.getFuelTemperature()
                tempBar(coreTemp,7,9,2000)

                -- Casing temperature
                casingTemp = reactor.getCasingTemperature()
                tempBar(casingTemp,33,9,2000)

                -- Battery overlay
                local bg = gpu.getBackground()
                energy = reactor.getEnergyStored()
                onePercent = 100000
                percent = energy/10000000*100
                if percent < 15 then
                    gpu.setBackground(0xFF0000)
                elseif percent < 40 then
                    gpu.setBackground(0xFFAA00)
                elseif percent < 70 then
                    gpu.setBackground(0xFFFF00)
                else
                    gpu.setBackground(0x00FF00)
                end

                for i = 0, 96, 2.4 do
                    if percent - i >= 1 then
                        gpu.fill(60+i/2.4,36,1,13," ")
                    end
                end

                if percent > 98 then
                    gpu.fill(100,41,1,3," ")
                end

                if percent == 100 then
                    gpu.fill(101,41,1,3," ")
                end
                gpu.setBackground(bg);

                gpu.setBackground(0x000000)
                gpu.setForeground(0xFFFFFF)

                -- General info
            
                gpu.set(60,10,"Reactor status")
                gpu.set(60,13,"Control rods")
                gpu.set(60,16,"Fuel status")
                gpu.set(60,19,"Reactivity")
                gpu.set(60,22,"Generating RF")
                gpu.set(60,25,"Fuel Consumption")
                gpu.set(60,28,"Waste produced")
                gpu.set(60,31,"Control rod insertion")

                -- General data
                if reactor.getActive() then
                    gpu.setForeground(0x00FF00)
                    reactorActive = "Active"
                else
                    gpu.setForeground(0xFF0000)
                    reactorActive = "Inactive"
                end
                gpu.set(108,10,reactorActive)
                gpu.setForeground(0xFFFFFF)    
                
                gpu.set(108,13,tostring(reactor.getNumberOfControlRods()))

                gpu.set(108,16,tostring(reactor.getFuelAmount()) .. " mB")

                gpu.set(108,19,tostring(reactor.getFuelReactivity()) .. " %")

                gpu.set(108,22,tostring(reactor.getEnergyProducedLastTick()) .. " RF/t")

                gpu.set(108,25,tostring(reactor.getFuelConsumedLastTick()) .. " mB/t")

                gpu.set(108,28,tostring(reactor.getWasteAmount()) .. " mB")

                gpu.set(108,31,tostring(reactor.getControlRodLevel(0)) .. " %")

                os.sleep(1)
            end
        --end
    --) then
       -- print("An error occured. Please, make sure your reactor is connected.")
    --end
end


return arolib
        
