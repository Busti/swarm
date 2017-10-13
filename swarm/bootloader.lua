print("Running Bootloader")

local CHANNEL = 0
local ID = tostring(os.getComputerID())

local modem = peripheral.find("modem")
modem.open(CHANNEL)

modem.transmit(CHANNEL, CHANNEL, ID .. "\nserver\nupdate")

repeat
  local event, side, ch_s, ch_r, msg, dist = os.pullEvent("modem_message")

  lines = {}
  for s in msg:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end

  from    = lines[1]
  to      = lines[2]
  command = lines[3]

  table.remove(lines, 1)
  table.remove(lines, 1)
  table.remove(lines, 1)

  if to == ID and command == "save" then
    local path = lines[1]
    table.remove(lines, 1)

    local data = table.concat(lines, "\n")

    print(path)

    local file = fs.open(path, "w")
    file.write(data)
    file.close()
  end
until command == "end"
