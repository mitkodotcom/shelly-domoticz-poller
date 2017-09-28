-- Domoticz HTTP/HTTPS Poller command script
-- Autor: www.mitko.com
-- Version: 0.1 / 20170928
-- Source: https://github.com/mitkodotcom/shelly-domoticz-poller
-- state = stop means roller is not moving right now, it does not show the roller's status (closed or open)
-- last_direction shows in which direction the roller is or was moving, so this is the eventual state (closed or open)
--	currently the script does not check if the roller is still moving or not
-- rollers/blinds state is inverted: Off means Open (window is clear, door is open), On means Closed (window is covered, door is closed)
-- If you are using Blinds Inverted device in domotics, you have to modify the script below (TODO: make it configurable)

-- define domoticz devices: switches by name, power meters by index
local switch_name = {}
local power_index = {}

-- reasonable defaults ('' or 0 = do not update this index). Don't change'em, use the devices section below.
switch_name[0] = ''
switch_name[1] = ''
switch_name[2] = ''
switch_name[3] = ''
power_index[0] = 0
power_index[1] = 0
power_index[2] = 0
power_index[3] = 0

local num_meters = 0
local num_outputs = 0
local num_rollers = 0


s = request['content'];
local device_id = domoticz_applyJsonPath(s,'.wifi_sta.ip')

-- add your Shelly devices here

if (device_id == "192.168.1.52") then
	-- Shelly2 in roller mode
	-- TODO: num_* da se wzimat ot /settings
	num_meters = 1
	num_outputs = 0
	num_rollers = 1
	switch_name[0] = 'Screen'
	power_index[0] = 125
end

if (device_id == "192.168.1.54") then
	-- Shelly4 Pro
	num_outputs = 4
	num_meters = 4
	num_rollers = 0
	switch_name[0] = 'Shelly4-1 R1'
	power_index[0] = 125
	switch_name[1] = ''
	power_index[1] = 0
	switch_name[2] = ''
	power_index[2] = 0
	switch_name[3] = ''
	power_index[3] = 0
end

-- do not edit below this line

local index = 0
local my_name = ''
local my_status = ''
local my_counter = ''
-- local file = io.open("/tmp/debug.log", "w")

if (num_meters > 0) then
	for index = 0,num_meters-1,1 do
		if (power_index[index] > 0) then
			my_status = domoticz_applyJsonPath(s,'.meters[' .. tostring(index) ..'].power')
			my_counter = domoticz_applyJsonPath(s,'.meters[' .. tostring(index) .. '].counter')
			domoticz_updateDevice(power_index[index],0,my_status .. ";" .. my_counter)
		end
	end
end

-- domoticz json library does not support binary values (returns nil)
s = s:gsub('true','"true"')
s = s:gsub('false','"false"')

-- do not update relays if in roller mode
if (num_outputs > 0 and num_rollers == 0) then
	for index = 0,num_outputs-1,1 do
		my_name = switch_name[index]
		if my_name then
			my_status = domoticz_applyJsonPath(s,'.relays[' .. tostring(index) .. '].ison')
-- file:write("My status is " .. my_status .. "\n")
			if (otherdevices[my_name] ~= 'On' and my_status == 'true') then
				domoticz_updateDevice(otherdevices_idx[my_name],1,"On")
			end
			if (otherdevices[my_name] ~= 'Off' and my_status == 'false') then
				domoticz_updateDevice(otherdevices_idx[my_name],0,"Off")
			end
		end
	end
end


if (num_rollers > 0) then
	for index = 0,num_rollers-1,1 do
		my_name = switch_name[index]
		if my_name then
			my_status = domoticz_applyJsonPath(s,'.rollers[' .. tostring(index) .. '].last_direction')
			-- may be "Stopped"
			if (otherdevices[my_name] ~= 'Closed' and my_status == 'close') then
				domoticz_updateDevice(otherdevices_idx[my_name],1,"On")
			end
			if (otherdevices[my_name] ~= 'Open' and my_status == 'open') then
				domoticz_updateDevice(otherdevices_idx[my_name],0,"Off")
			end
		end
	end
end

-- file:close()	
