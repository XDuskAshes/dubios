--dubios install

local args = {...}

local verhandle = assert(http.get("https://raw.githubusercontent.com/XDuskAshes/dubios/main/ver"))
local ver = verhandle.readLine()
verhandle.close()

local dirs = {
    "/dubios/",
    "/dubios/res/"
}

local files = {
    "/startup.lua",
    "/dubios/dubios.lua",
    "/dubios/res/dubios.cfg",
    "/dubios/res/icon.nfp"
}

term.clear()
term.setCursorPos(1,1)
print("DuBios Version",ver,"installer")
for k,v in pairs(dirs) do
    fs.makeDir(v)
end

for k,v in pairs(files) do
    local toWrite = {}
    local handle = assert(http.get("https://raw.githubusercontent.com/XDuskAshes/dubios/main"..v))
    repeat
        local a = handle.readLine()
        table.insert(toWrite,a)
    until a == nil
    handle.close()

    handle = fs.open(v,"w")
    for k,v in pairs(files) do
        handle.writeLine(v)
    end
    handle.close()
end

if args[1] == "--manual-config" then
    print("Install finished. Post-install configuration is expected to be done manually or by the OS.")
else
    write("Perform post-install configuration? [Y/n]")
    local ynae = read()
    if ynae == "y" or ynae == "Y" then
        write("Default boot file location: ")
        local bootfile = read()
        if fs.exists(bootfile) ~= true then
            error("Boot file location does not exist. Bailing.")
        else
            local handle = fs.open("/dubios/res/dubios.cfg","w")
            handle.writeLine("[BOOT]")
            handle.writeLine(bootfile)
            handle.close()
            while true do
                print("Enter any further configs for startup.")
                print("Type 'done' when finished.")
                print("Note: Configs are CC configs, please familiarize yourself with CC configs.")
                local tx, ty = term.getCursorPos()
                write("Config: ")
                local cfgs = {}
                local input = read()
                if input == "done" then
                    break
                else
                    table.insert(cfgs,input)
                    term.clearLine(term.getCursorPos())
                    term.setCursorPos(tx,ty)
                end
            end
        end
    elseif ynae == "n" or ynae == "N" then
        print("Install finished. Post-install configuration is expected to be done manually.")
    else
        write("Default boot file location: ")
        local bootfile = read()
        if fs.exists(bootfile) ~= true then
            error("Boot file location does not exist. Bailing.")
        else
            local handle = fs.open("/dubios/res/dubios.cfg","w")
            handle.write(bootfile)
            handle.close()
            print("Post-install configuration finished.")
        end
    end
end