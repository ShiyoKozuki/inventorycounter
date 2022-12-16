addon.name      = 'InventoryCounter';
addon.author    = 'Shiyo';
addon.version   = '0.1';
addon.desc      = 'Shows inventory space';
addon.link      = 'https://github.com/ShiyoKozuki';

require('common');
local chat = require('chat');
local fonts = require('fonts');
local settings = require('settings');

local windowWidth = AshitaCore:GetConfigurationManager():GetFloat('boot', 'ffxi.registry', '0001', 1024);
local windowHeight = AshitaCore:GetConfigurationManager():GetFloat('boot', 'ffxi.registry', '0002', 768);

local default_settings = T{
	font = T{
        visible = true,
        font_family = 'Arial',
        font_height = 18,
        color = 0xFFFFFFFF,
        position_y = 1055,
        position_x = 1856,
		background = T{
			visible = true,
			color = 0x80000000,
		}
    }
};


local inventorycounter = T{
	settings = settings.load(default_settings)
};

local UpdateSettings = function(settings)
    inventorycounter.settings = settings;
    if (inventorycounter.font ~= nil) then
        inventorycounter.font:apply(inventorycounter.settings.font)
    end
end


ashita.events.register('load', 'load_cb', function ()
    inventorycounter.font = fonts.new(inventorycounter.settings.font);
    settings.register('settings', 'settingchange', UpdateSettings);
end);


ashita.events.register('d3d_present', 'present_cb', function ()

    local fontObject = inventorycounter.font;
    if (fontObject.position_x > windowWidth) then
      fontObject.position_x = 0;
    end
    if (fontObject.position_y > windowHeight) then
      fontObject.position_y = 0;
    end
    if (fontObject.position_x ~= inventorycounter.settings.font.position_x) or (fontObject.position_y ~= inventorycounter.settings.font.position_y) then
        inventorycounter.settings.font.position_x = fontObject.position_x;
        inventorycounter.settings.font.position_y = fontObject.position_y;
        settings.save()
    end

local invCurrent = AshitaCore:GetMemoryManager():GetInventory():GetContainerCount(0)
local invMax = AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(0)
  
  inventorycounter.font.text = (('%u/%u'):fmt(invCurrent, invMax));  
end);

ashita.events.register('unload', 'unload_cb', function ()
    if (inventorycounter.font ~= nil) then
        inventorycounter.font:destroy();
    end
settings.save();
end);