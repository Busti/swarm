-- Constants
local SOURCES = "/disk/swarm/"
local CHANNEL = 0
local ID      = "server"

-- Open the modem
local modem = peripheral.find("modem")
modem.open(CHANNEL)

-- The available commands
local cmd = {
  update = function (from, args)
    -- Send program to bootloader
    print("Broadcasting program...")
    function recursion(path)
      for _,v in pairs(fs.list(path)) do
        v = path .. v
        if (fs.isDir(v)) then
          v = v .. "/"
          print("Scanning " .. v)
          recursion(v)
        else
          p = string.sub(v, #SOURCES)
          print("Sending " .. v .. " as " .. p)
          local file = fs.open(v, "r")
          local data = file.readAll()
          send(from, "save", p, data)
          file.close()
        end
      end
    end
    recursion(SOURCES)
    send(from, "end")
  end
}

-- Send a number of arguments over the specified channel
function send(...)
  local msg = ID
  for _,v in ipairs(arg) do
    msg = msg .. "\n" .. v
  end
  modem.transmit(CHANNEL, CHANNEL, msg)
end

-- Main loop
function main()
  while true do
    local event, side, ch_s, ch_r, msg, dist = os.pullEvent("modem_message")

    lines = {}
    for s in msg:gmatch("[^\r\n]+") do
      table.insert(lines, s)
    end

    local from    = lines[1]
    local to      = lines[2]
    local command = lines[3]

    table.remove(lines, 1)
    table.remove(lines, 1)
    table.remove(lines, 1)

    if to == ID and cmd[command] ~= nil then
      cmd[command](from, lines)
    end
  end
end

-- Exit loop
function exit()
  repeat
    local evt, key = os.pullEvent("key")
  until key == keys.backspace
end

print("Starting server")
print("Press backspace to exit")

parallel.waitForAny(main, exit)
