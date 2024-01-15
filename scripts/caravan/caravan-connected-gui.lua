require 'caravan-gui-shared'
--local Table = require('__stdlib__/stdlib/utils/table')

local function guess(event)
    local name = event.entity.name
    if name == 'aerial-outpost' or name == 'outpost' then
        return defines.relative_gui_type.container_gui
    end
    if name == 'transport-belt' then
        return defines.relative_gui_type.transport_belt_gui
    end
    --game.print('Using fallback for ' .. name)
    -- there are other types needed as well, but i am lazy
    return defines.relative_gui_type.container_gui
end

--anchor is optional
local function instantiate_main_frame(gui, anchor)
    if anchor then
        return gui.relative.add {
            type = 'frame',
            name = 'connected_caravan_gui',
            caption = { 'caravan-global-gui.caption' },
            direction = 'vertical',
            anchor = anchor
        }
    else
        if not gui.relative.caravan_flow then
            return
        end
        return gui.relative.caravan_flow.add {
            type = 'frame',
            name = 'connected_caravan_gui',
            caption = { 'caravan-global-gui.caption' },
            direction = 'vertical',
        }
    end
end

--anchor is optional
Caravan.build_gui_connected = function(player, entity, anchor)
    if not entity then
        return
    end
    if not Caravan.has_any_caravan(entity) then
        return
    end
    local main_frame = instantiate_main_frame(player.gui, anchor)
    if not main_frame then
        return
    end
    main_frame.style.width = 436
    main_frame.style.minimal_height = 710
    main_frame.tags = { unit_number = entity.unit_number }

    local content_frame = main_frame.add { type = 'frame', direction = 'vertical',
                                           style = 'inside_shallow_frame_with_padding' }
    content_frame.style.vertically_stretchable = true
    local content_flow = content_frame.add { type = 'flow', direction = 'vertical' }
    content_flow.style.vertical_spacing = 8
    content_flow.style.margin = { -4, 0, -4, 0 }
    content_flow.style.vertical_align = 'center'
    local scroll_pane = content_flow.add {
        type = 'scroll-pane',
        name = 'connected-caravan-pane'
    }
    local table = scroll_pane.add {
        type = 'table',
        name = 'my_table',
        column_count = 3
    }
    table.add { type = 'label', caption = 'Key' }
    table.add { type = 'label', caption = 'Value' }
    table.add { type = 'label', caption = 'Value' }
    for key, caravan_data in pairs(global.caravans) do
        if has_schedule(caravan_data, entity) then
            Caravan.add_gui_row(caravan_data, key, table)
        end
    end

end

Caravan.events.on_gui_opened_connected = function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    if not entity then
        return
    end
    Caravan.events.on_close_connected_gui(event)
    local anchor = {
        gui = guess(event),
        position = defines.relative_gui_position.right
    }
    Caravan.build_gui_connected(player, entity, anchor)

end

Caravan.events.on_close_connected_gui = function(event)
    local player = game.get_player(event.player_index)
    if not player.gui.relative.connected_caravan_gui then
        return
    end
    player.gui.relative.connected_caravan_gui.destroy()
    return true
end