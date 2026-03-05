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

-- Interface / Menu checks to hide addons
local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, "8B480C85C974??8B510885D274??3B05", 16, 0);
local pEventSystem = ashita.memory.find('FFXiMain.dll', 0, "A0????????84C0741AA1????????85C0741166A1????????663B05????????0F94C0C3", 0, 0);
local pInterfaceHidden = ashita.memory.find('FFXiMain.dll', 0, "8B4424046A016A0050B9????????E8????????F6D81BC040C3", 0, 0);
local function GetMenuName()
    local subPointer = ashita.memory.read_uint32(pGameMenu);
    local subValue = ashita.memory.read_uint32(subPointer);
    if (subValue == 0) then
        return '';
    end
    local menuHeader = ashita.memory.read_uint32(subValue + 4);
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16);
    return string.gsub(menuName, '\x00', '');
end

local function GetEventSystemActive()
    if (pEventSystem == 0) then
        return false;
    end
    local ptr = ashita.memory.read_uint32(pEventSystem + 1);
    if (ptr == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(ptr) == 1);

end

local function GetInterfaceHidden()
    if (pEventSystem == 0) then
        return false;
    end
    local ptr = ashita.memory.read_uint32(pInterfaceHidden + 10);
    if (ptr == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(ptr + 0xB4) == 1);
end

local hideMenus = T{
    ['menu    map0    '] = true,
    ['menu    mapv2   '] = true,
    ['menu    mapv3   '] = true,
    ['menu    mapframe'] = true,
    ['menu    scanlist'] = true,
    ['menu    maplist '] = true,
    ['menu    pupequip'] = true,
    ['menu    equip   '] = true,
    ['menu    automato'] = true,
    ['menu    inventor'] = true,
    ['menu    itemctrl'] = true,
    ['menu    magic   '] = true,
    ['menu    magselec'] = true,
    ['menu    abiselec'] = true,
    ['menu    ability '] = true,
    ['menu    mount   '] = true,
    ['menu    menuwind'] = true,
    ['menu    cmbmenu '] = true,
    ['menu    cmbhlst '] = true,
    ['menu    mgcmenu '] = true,
    ['menu    link5   '] = true,
    ['menu    cnqfram '] = true,
    ['menu    socialme'] = true,
    ['menu    missionm'] = true,
    ['menu    miss00  '] = true,
    ['menu    quest00 '] = true,
    ['menu    evitem  '] = true,
    ['menu    mogcont '] = true,
    ['menu    bank    '] = true,
    ['menu    itmsortw'] = true,
    ['menu    itmsort2'] = true,
    ['menu    bazaar  '] = true,
    ['menu    shop    '] = true,
    ['menu    shopbuy '] = true,
    ['menu    shopsell'] = true,
    ['menu    comment '] = true,
    ['menu    mcrmenu '] = true,
    ['menu    mcrselec'] = true,
    ['menu    mcrselop'] = true,
    ['menu    mcres20 '] = true,
    ['menu    mcresmn '] = true,
    ['menu    statcom2'] = true,
    ['menu    inspect '] = true,
    ['menu    fulllog '] = true,
    ['menu    loot    '] = true,
    ['menu    lootope '] = true,
    ['menu    mogdoor '] = true,
    ['menu    myroom  '] = true,
    ['menu    mogext  '] = true,
    ['menu    storage '] = true,
    ['menu    storage2'] = true,
    ['menu    mogpost '] = true,
    ['menu    jobchang'] = true,
    ['menu    jobcselu'] = true,
    ['menu    post1   '] = true,
    ['menu    stringdl'] = true,
    ['menu    auc1    '] = true,
    ['menu    auc2    '] = true,
    ['menu    auc3    '] = true,
    ['menu    auchisto'] = true,
    ['menu    moneyctr'] = true,
    ['menu    aucweapo'] = true,
    ['menu    aucarmor'] = true,
    ['menu    aucmagic'] = true,
    ['menu    aucmater'] = true,
    ['menu    aucfood '] = true,
    ['menu    aucmeals'] = true,
    ['menu    auclist '] = true,
    ['menu    aucitem '] = true,
    ['menu    aucammo '] = true,
    ['menu    comyn   '] = true,
    ['menu    trade   '] = true,
    ['menu    handover'] = true,
    ['menu    iuse    '] = true,
    ['menu    sortyn  '] = true,
    ['menu    scresult'] = true,
    ['menu    scoption'] = true,
    ['menu    party3  '] = true,
    ['menu    partywin'] = true,
    ['menu    fulllog' ] = true,
    ['menu    cnqframe'] = true,
    ['menu    configwi'] = true,
    ['menu    conf2win'] = true,
    ['menu    cfilter'] = true,
    ['menu    conftxtc'] = true,
    ['menu    cconf5m'] = true,
    ['menu    conf3win'] = true,
    ['menu    conf6win'] = true,
    ['menu    conf12wi'] = true,
    ['menu    conf13wi'] = true,
    ['menu    fxfilter'] = true,
    ['menu    conf7   '] = true,
    ['menu    conf4   '] = true,
    ['menu    merit1  '] = true,
    ['menu    merit2  '] = true,
    ['menu    meritcat'] = true,
    ['menu    merit2ca'] = true,
    ['menu    jbpcat  '] = true,
    ['menu    inline  '] = true,
    -- Spaces after name then before ] where the ' is is intended. PAY ATTENTION! i.e. ['menu    inline  ']
};

isZoning = (AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0) == 0);

ashita.events.register('packet_in', 'zoning_packet_cb', function (e)
   if e.id == 0x00B then
       isZoning = true;
   elseif e.id == 0x00A then
       isZoning = false;
   end
end);

function ShouldHideUI()
    -- Not logged in
    if (AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0) == 0) then
        return true;
    end

    if (GetEventSystemActive()) then
        return true;
    end

    if hideMenus[GetMenuName()] then
        return true;
    end

    if (GetInterfaceHidden()) then
        return true;
    end

    if (isZoning) then
        return true
    end

    return false;
end

ashita.events.register('load', 'load_cb', function ()
    inventorycounter.font = fonts.new(inventorycounter.settings.font);
    settings.register('settings', 'settingchange', UpdateSettings);
end);


ashita.events.register('d3d_present', 'present_cb', function ()
    local fontObject = inventorycounter.font;

    if ShouldHideUI() then
        fontObject.visible = false
        return
    else
        fontObject.visible = true
    end

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