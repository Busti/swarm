-- Constants
local SOURCES = "/swarm/"
local CHANNEL = 0
local ID      = os.getComputerID()

-- The available tasks
local tsk = {
  goto = function (x, y, z)
  
	end
}

-- The available commands
local cmd = {
  home = function (from, args)
    -- Return home
    print("Returning home")
  end
}

-- Task loop
function task()
  while true do
    print("Foo")
		end
end

-- Send a number of arguments over the specified channel
function send(...)
  local msg = ID
  for _,v in ipairs(arg) do
    msg = msg .. "\n" .. v
  end
  modem.transmit(CHANNEL, CHANNEL, msg)
end

-- Command loop
function command()
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

print("Starting client")
print("Press backspace to exit")

parallel.waitForAny(task, command, exit)
