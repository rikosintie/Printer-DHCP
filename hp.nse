local stdnse = require "stdnse"
function portrule(host, port)
  if port.state == "open" then
    cmd = "echo " .. host.ip .. " >> targets.txt"
    os.execute(cmd)
  end
-- On linux sudo is required to get the mac address
-- if sudo is left off skip the mac address output
  if (host.mac_addr ~= nil) then
    cmd = "echo " .. stdnse.format_mac(host.mac_addr) .. " >> targets.txt"
    os.execute(cmd)
  else
  end
end

function hostrule(host)
end

function action()
end
