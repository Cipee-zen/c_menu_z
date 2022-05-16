CZ = nil
local openMenus = {}
local openMenuId = nil
local openMenuIndex = nil
local display = false
local mouseMove = false
local disableControls = {25,24}

TriggerEvent("InitializeCipeZenFrameWork",function(cz)
    CZ = cz
    CZ.CreateThread(1,function(pause,reasume,delete)
        if display then
            if IsDisabledControlJustPressed(0, 25) then
                mouseMove = not mouseMove
                if mouseMove then
                    table.insert(disableControls,1)
                    table.insert(disableControls,2)
                else
                    table.remove(disableControls,#disableControls)
                    table.remove(disableControls,#disableControls)
                end
            end
            for k,v in pairs(disableControls) do
                DisableControlAction(0,v,true)
                DisableControlAction(1,v,true)
                DisableControlAction(2,v,true)
            end
        end
    end)
    CZ.ControlPressed(194,function ()
        if display then
            if openMenuId ~= nil then
                local menuId = openMenuId
                function Close()
                    for k,v in pairs(openMenus) do
                        if v.id == menuId then
                            if openMenuId == menuId then
                                if k == 1 then
                                    openMenuId = nil
                                    openMenuIndex = nil
                                    display = false
                                    SetNuiFocus(display,display)
                                    SetNuiFocusKeepInput(display)
                                    SendNUIMessage({
                                        action = "close"
                                    })
                                    if mouseMove then
                                        table.remove(disableControls,#disableControls)
                                        table.remove(disableControls,#disableControls)
                                        mouseMove = false
                                    end
                                else
                                    openMenuId = openMenus[k-1].id
                                    openMenuIndex = k-1
                                    SendNUIMessage({
                                        action = "open",
                                        Buttons = openMenus[k-1].data.Buttons,
                                        Title = openMenus[k-1].data.Title,
                                    })
                                end
                            end
                            table.remove(openMenus,k)
                            break
                        end
                    end
                end
                openMenus[openMenuIndex].cb1(Close)
            end
        end
    end)
end)

RegisterNetEvent("cz_menu:closeAllMenu")
AddEventHandler("cz_menu:closeAllMenu",function ()
    openMenus = {}
    openMenuId = nil
    openMenuIndex = nil
    display = false
    SetNuiFocus(display,display)
    SetNuiFocusKeepInput(display)
    SendNUIMessage({
        action = "close"
    })
    if mouseMove then
        table.remove(disableControls,#disableControls)
        table.remove(disableControls,#disableControls)
        mouseMove = false
    end
end)

RegisterNetEvent("cz_menu:openMenu")
AddEventHandler("cz_menu:openMenu",function(id,data,cb,cb1,cb2)
    --local randomint = math.random(0,100)..math.random(0,100)..math.random(0,100)..math.random(0,100)..math.random(0,100)..math.random(0,100)..math.random(0,100)
    local find = false
    for k,v in pairs(openMenus) do
        if v.id == id then
            find = true
            print("this menu is already open \'"..id.."\'")
            break
        end
    end
    if not find then
        table.insert(openMenus,{
            id = id,
            data = data,
            cb = cb,
            cb1 = cb1,
            cb2 = cb2,
        })
        display = true
        SetNuiFocus(display,display)
        SetNuiFocusKeepInput(display)
        openMenuId = id
        openMenuIndex = #openMenus
        SendNUIMessage({
            action = "open",
            Buttons = data.Buttons,
            Title = data.Title,
        })
    end
end)

RegisterNUICallback("pressButton",function(data)
    local buttonIndex = data.Index
    local menuId = openMenuId
    function Close()
        for k,v in pairs(openMenus) do
            if v.id == menuId then
                if openMenuId == menuId then
                    if k == 1 then
                        openMenuId = nil
                        openMenuIndex = nil
                        display = false
                        SetNuiFocus(display,display)
                        SetNuiFocusKeepInput(display)
                        SendNUIMessage({
                            action = "close"
                        })
                        if mouseMove then
                            table.remove(disableControls,#disableControls)
                            table.remove(disableControls,#disableControls)
                            mouseMove = false
                        end
                    else
                        openMenuId = openMenus[k-1].id
                        openMenuIndex = k-1
                        SendNUIMessage({
                            action = "open",
                            Buttons = openMenus[k-1].data.Buttons,
                            Title = openMenus[k-1].data.Title,
                        })
                    end
                end
                table.remove(openMenus,k)
                break
            end
        end
    end
    openMenus[openMenuIndex].cb(openMenus[openMenuIndex].data.Buttons[buttonIndex].value,Close)
end)