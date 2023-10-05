--[[
    A simple ComputerCraft:Tweaked BIOS program.
    Copyright (C) 2023  Dusk

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local finalFunction = "shutdown" --shutdown and reboot do the appropriate things down by lines 162 to 166

local function e(s) --empty check
    return s == nil or s == ""
end

local onBoardPath

local function cls() --clear
    term.clear()
    term.setCursorPos(1,1)
end

cls()

local bootPaths = {}

print("dubios is trying to find all available and compatible boot paths on all drives.")

--Local boot path file check.

if not fs.exists("/boot/db/boot.db") then --If not found, fail.
    printError("No local file to read could be found.")
else
    local handle = fs.open("/boot/db/boot.db","r")
    onBoardPath = handle.readLine()
    handle.close()

        if e(onBoardPath) then --If it gets a returned nil or blank, fail.
            printError("Local read file is a bad path: e(onBoardPath) check returned nil or blank.")
        else
            if not fs.exists(onBoardPath) then --If it returns true, fail.
                printError("Local onBoardPath is bad: 'not fs.exists(onBoardPath)' returned true.")
            else
                if not fs.isDir(onBoardPath) then --If it returns true, success.
                    print("Local path '"..onBoardPath.."' is perfectly valid path to execute.")
                    table.insert(bootPaths,onBoardPath)
                else --If it returns false, fail.
                    printError("Local path '"..onBoardPath.."' is a bad path: is dir or something outside of an e(onBoardPath) check.")
                end
            end
        end
end

local per = peripheral.getNames()

for k,v in pairs(per) do --disk file path check.
    local diskPath
    if disk.isPresent(v) then
        local mnt = disk.getMountPath(v)
        if not fs.exists("/"..mnt.."/boot/db/boot.db") then --If not found, fail.
            printError("No file to read could be found on /"..mnt.."/")
        else
            local handle = fs.open("/"..mnt.."/boot/db/boot.db","r")
            diskPath = handle.readLine()
            handle.close()
        
                if e("/"..mnt.."/"..diskPath) then --If it gets a returned nil or blank, fail.
                    printError("read file is a bad path: e(diskPath) check returned nil or blank.")
                else
                    if not fs.exists("/"..mnt.."/"..diskPath) then --If it returns true, fail.
                        printError("diskPath is bad: 'not fs.exists(/"..mnt.."/diskPath)' returned true.")
                    else
                        if not fs.isDir("/"..mnt.."/"..diskPath) then --If it returns true, success.
                            print("Local path '".."/"..mnt.."/"..diskPath.."' is perfectly valid path to execute.")
                            table.insert(bootPaths,"/"..mnt.."/"..diskPath)
                        else --If it returns false, fail.
                            printError("Local path '".."/"..mnt.."/"..diskPath.."' is a bad path: is dir or something outside of an e(diskPath) check.")
                        end
                    end
                end
        end
    end
end

local bootPathsAmount = 0

for k,v in pairs(bootPaths) do
    bootPathsAmount = bootPathsAmount + 1
end

if bootPathsAmount < 2 then
    print("Could only find one boot path.")
    shell.run(bootPaths[1])
else
    print("+===============================+")
    print("dubios found multiple boot paths.")
    print("In 3 seconds, you will be able to choose what to boot off of.")
    sleep(3)
    cls()

    local allowedPaths = 9
    local detectedPaths = 0
    print("Press the corresponding number key.")
    for k,v in pairs(bootPaths) do
        detectedPaths = detectedPaths + 1
        if detectedPaths >= allowedPaths then
            print(k,v)
            print("Note: max paths is nine.")
            break
        else
            print(k,v)
        end
    end

    while true do
        local event = {os.pullEvent()}
        local eventD = event[1]
    
        if eventD == "key" then
            local ck = event[2]
            if ck == keys.one then --This is bad code. I am aware. Do I care? No. Why? It hasn't broken yet. If it ain't broke, don't fix it.
                ck = 1
            elseif ck == keys.two then
                ck = 2
            elseif ck == keys.three then
                ck = 3
            elseif ck == keys.four then --This is bad code. I am aware. Do I care? No. Why? It hasn't broken yet. If it ain't broke, don't fix it.
                ck = 4
            elseif ck == keys.five then
                ck = 5
            elseif ck == keys.six then
                ck = 6
            elseif ck == keys.seven then
                ck = 7
            elseif ck == keys.eight then
                ck = 8
            elseif ck == keys.nine then
                ck = 9
            end

            for k,v in pairs(bootPaths) do
                if ck == k then
                    shell.run(v)
                end
            end
        end
    break
    end
end

print("dubios has run, and assuming that the selection has run its course.")
sleep(5)
if finalFunction == "shutdown" then
    os.shutdown()
elseif finalFunction == "reboot" then
    os.reboot()
end