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

local function e(s)
    return s == nil or s == ""
end

local onBoardPath

term.clear()
term.setCursorPos(1,1)

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

for k,v in pairs(per) do
    print(k,v)
end