addon.name      = 'InventoryCounter';
addon.author    = 'Shiyo';
addon.version   = '0.1';
addon.desc      = 'Shows inventory space';
addon.link      = 'https://github.com/ShiyoKozuki';

require('common');
local chat = require('chat');
local fonts = require('fonts');
local settings = require('settings');

local default_settings = T{
	font = T{
        visible = true,
        font_family = 'Arial',
        font_height = 18,
        color = 0xFFFFFFFF,
        position_x = 1,
        position_y = 1,
		background = T{
			visible = true,
			color = 0x80000000,
		}
    }
};


local inventorycounter = T{
	settings = settings.load(default_settings)
};


ashita.events.register('load', 'load_cb', function ()
    inventorycounter.font = fonts.new(inventorycounter.settings.font);
end);


ashita.events.register('d3d_present', 'present_cb', function ()
local invCurrent = AshitaCore:GetMemoryManager():GetInventory():GetContainerCount(0)
local invMax = AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(0)
  
  inventorycounter.font.text = (('%u/%u'):fmt(invCurrent, invMax));  
  inventorycounter.settings.font.position_x = inventorycounter.font:GetPositionX();
  inventorycounter.settings.font.position_y = inventorycounter.font:GetPositionY();
end);

ashita.events.register('unload', 'unload_cb', function ()
    if (inventorycounter.font ~= nil) then
        inventorycounter.font:destroy();
    end
settings.save();
end);