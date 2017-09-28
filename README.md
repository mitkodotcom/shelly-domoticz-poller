Domoticz HTTP/HTTPS Poller command script for Shelly devices

Download https://raw.githubusercontent.com/mitkodotcom/shelly-domoticz-poller/master/shelly.lua and save it to domoticz/scripts/lua_parsers/


Add a HTTP/HTTPS poller in Hardware. Give it a name.  
URL: http://192.168.1.123/status (where 192.168.1.123 is the IP address of your Shelly)  
Command: shelly.lua  
Rerresh: 10

Click on "Create Virtual Sensors" next to the just added poller and add Electric (Instant + Counter) device. Find it's index number in Devices. Enter this number as power_index[0] in shelly.lua. Repeat, if your device has more than one power meter.

Add a Dummy hardware device and create another Virtual Sensor of type Switch. DO NOT (I repeat: DO NOT) create the virtual Switch under the poller hardware, use the Dummy device instead or you will not be able to control the On/Off function (see below). Repeat if you have more than one relay.

Find the switch in Switches tab and click Edit. Give it a name. Enter this name as switch_name[0] in shelly.lua

If the switch is in Relay mode:  
  
   Switch Type: On/Off  
   On Action: http://192.168.1.123/relay/0?turn=on  
   Off Action: http://192.168.1.123/relay/0?turn=off  
   Set num_rollers = 0 in shelly.lua  

If the switch is in Roller mode:  
  
   Switch Type: Blinds  
   On Action: http://192.168.1.123/roller/0?go=close&duration=40  
   Off Action: http://192.168.1.123/roller/0?go=open&duration=40  
   Set num_rollers = 1 (or whatever number of rollers you have) in shelly.lua  
     
   The duratuion is in seconds - use whatever is suitable for your roller.  
   Note that the Blinds reaction is inverted: "close" for "On" and "open" for Off  
   
Repeat if you have more than one relay / roller to control (note that Shelly2 has two relays if in switch mode but only one roller). Do not forget to replace the "0" after relay/ and roller/ with 1,2,3, etc.

Update the corresponding values of num_meters and num_outputs in shelly.lua

Disclaimer: This is my first Lua script ever and I had only 24 hours of experience with this language. I'm not responsible if this piece of software puts your house in fire.

What is Domoticz: https://www.domoticz.com/  
What is Shelly: https://shelly.cloud/
