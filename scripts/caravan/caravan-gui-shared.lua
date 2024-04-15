local prototypes = require 'caravan-prototypes'

function has_schedule(caravan_data, entity)
    if not Caravan.validity_check(caravan_data) then return end
    if not caravan_data.schedule then return end
    for _, schedule in pairs(caravan_data.schedule) do
        if schedule.entity == entity then return true end
    end
    return false
end

function Caravan.status_img(caravan_data)
    local entity = caravan_data.entity
    if caravan_data.is_aerial then
        return {'entity-status.working'}, 'utility/status_working'
    elseif caravan_data.fuel_bar == 0 and caravan_data.fuel_inventory.is_empty() then
        return {'entity-status.starved'}, 'utility/status_not_working'
    elseif entity.health ~= entity.prototype.max_health then
        return {'entity-status.wounded'}, 'utility/status_yellow'
    elseif not Caravan.is_automated(caravan_data) then
        return {'entity-status.idle'}, 'utility/status_yellow'
    else
        return {'entity-status.healthy'}, 'utility/status_working'
    end
end

local function convert_to_tooltip_row(name, count)
    return {'', '\n[item=' .. name .. '] ', game.item_prototypes[name].localised_name, ' ×', count}
end

function Caravan.get_inventory_tooltip(caravan_data)
    local has_anything = false
    local entity = caravan_data.entity

    local schedule = caravan_data.schedule[caravan_data.schedule_id]
    local current_action = ''
    if schedule then
        has_anything = true
        local action_id = caravan_data.action_id
        local action = schedule.actions[action_id]
        current_action = {'', {'caravan-shared.current-action', action and action.localised_name or {'caravan-actions.traveling'}}, '\n'}

        local destination = schedule.position
        local localised_destination_name
        if destination then
            localised_destination_name = {'caravan-gui.map-position', math.floor(destination.x), math.floor(destination.y)}
        else
            local destination_entity = schedule.entity
            if destination_entity and destination_entity.valid then
                destination = destination_entity.position
                localised_destination_name = {
                    'caravan-gui.entity-position',
                    destination_entity.prototype.localised_name,
                    math.floor(destination.x),
                    math.floor(destination.y)
                }
            end
        end
        
        if localised_destination_name then
            local distance = math.sqrt((entity.position.x - destination.x) ^ 2 + (entity.position.y - destination.y) ^ 2)
            distance = math.floor(distance * 10) / 10
            current_action[#current_action + 1] = {'caravan-shared.current-destination', distance, localised_destination_name}
        end
    end

    local fuel_inventory = caravan_data.fuel_inventory
    local fuel_inventory_contents = {''}
    if fuel_inventory and fuel_inventory.valid then
        local i = 0
        for name, count in pairs(fuel_inventory.get_contents()) do
            has_anything = true
            if i == 0 then fuel_inventory_contents[#fuel_inventory_contents + 1] = '\n' end
            fuel_inventory_contents[#fuel_inventory_contents + 1] = convert_to_tooltip_row(name, count)
            i = i + 1
            if i == 10 then break end
        end
    end

    local inventory = caravan_data.inventory
    local inventory_contents = {''}
    if inventory and inventory.valid then
        local sorted_contents = {}
        for name, count in pairs(inventory.get_contents()) do
            has_anything = true
            sorted_contents[#sorted_contents + 1] = {name = name, count = count}
        end
        table.sort(sorted_contents, function(a, b) return a.count > b.count end)
        
        local i = 0
        for _, item in pairs(sorted_contents) do
            if i == 0 then inventory_contents[#inventory_contents + 1] = '\n' end
            local name, count = item.name, item.count
            inventory_contents[#inventory_contents + 1] = convert_to_tooltip_row(name, count)
            i = i + 1
            if i == 10 then
                if #sorted_contents > 10 then
                    inventory_contents[#inventory_contents + 1] = {'', '\n [font=default-semibold]...[/font]'}
                end
                break
            end
        end
    end

    return has_anything, {'', current_action, fuel_inventory_contents, inventory_contents}
end

function Caravan.name_fallback(caravan_data)
    local name = caravan_data.name
    if name and name ~= '' then return name end
    local entity = caravan_data.entity
    if entity and entity.valid then return entity.prototype.localised_name end
    return ''
end

function Caravan.add_gui_row(caravan_data, key, table)
    local entity = caravan_data.entity
    local prototype = prototypes[entity.name]

    table = table.add{type = 'frame', style = 'inside_shallow_frame_with_padding'}
    table.style.maximal_width = 300

    local right_flow = table.add{type = 'flow', direction = 'vertical'}

    local status_flow = right_flow.add{type = 'flow', direction = 'horizontal'}
    status_flow.style.vertical_align = 'top'

    local caption_flow = status_flow.add{type = 'flow', direction = 'horizontal'}

    local title = caption_flow.add{
        name = 'title',
        type = 'label',
        caption = Caravan.name_fallback(caravan_data),
        style = 'frame_title',
        ignored_by_interaction = true
    }
    title.style.maximal_width = 120

    local rename_button = caption_flow.add{
        type = 'sprite-button',
        name = 'py_rename_caravan_button',
        style = 'frame_action_button',
        sprite = 'utility/rename_icon_small_white',
        hovered_sprite = 'utility/rename_icon_small_black',
        clicked_sprite = 'utility/rename_icon_small_black',
        tags = {unit_number = key}
    }

    status_flow.add{type = 'empty-widget'}.style.horizontally_stretchable = true

    local status_sprite = status_flow.add{type = 'sprite'}
    status_sprite.resize_to_sprite = false
    status_sprite.style.size = {16, 16}
    local status_text = status_flow.add{type = 'label'}
    local state, img = Caravan.status_img(caravan_data)
    status_text.caption = state
    status_sprite.sprite = img
    status_text.style.right_margin = 4

    local has_anything, tooltip = Caravan.get_inventory_tooltip(caravan_data)
    local view_inventory_button = status_flow.add{
        type = 'sprite-button',
        name = 'py_view_inventory_button',
        style = 'frame_action_button',
        sprite = 'utility/expand_dots_white',
        hovered_sprite = 'utility/expand_dots',
        clicked_sprite = 'utility/expand_dots',
        tooltip = tooltip,
        tags = {unit_number = caravan_data.unit_number}
    }
    view_inventory_button.visible = has_anything

    local open_caravan_button = status_flow.add{
        type = 'sprite-button',
        name = 'py_click_caravan',
        style = 'frame_action_button',
        sprite = 'utility/logistic_network_panel_white',
        hovered_sprite = 'utility/logistic_network_panel_black',
        clicked_sprite = 'utility/logistic_network_panel_black',
        tooltip = {'caravan-shared.open', {'entity-name.' .. entity.name}},
        tags = {unit_number = caravan_data.unit_number}
    }

    local open_map_button = status_flow.add{
        type = 'sprite-button',
        name = 'py_open_map_button',
        style = 'frame_action_button',
        sprite = 'utility/search_white',
        hovered_sprite = 'utility/search_black',
        clicked_sprite = 'utility/search_black',
        tooltip = {'caravan-shared.view-on-map'},
        tags = {unit_number = caravan_data.unit_number}
    }

    for _, button in pairs{rename_button, open_caravan_button, view_inventory_button, open_map_button} do
        button.style.size = {26, 26}
        button.style.top_margin = -2
        button.style.bottom_margin = -4
    end

    local camera_frame = right_flow.add{type = 'frame', name = 'camera_frame', style = 'py_nice_frame'}
	local camera = camera_frame.add{type = 'camera', name = 'camera', style = 'py_caravan_camera', position = entity.position, surface_index = entity.surface.index}
	camera.entity = entity
	camera.visible = true
	camera.style.height = 155
	camera.zoom = prototype.camera_zoom or 1
end

gui_events[defines.events.on_gui_click]['py_click_caravan'] = function(event)
    local player = game.get_player(event.player_index)
    local element = event.element
    local tags = element.tags
    local caravan_data = global.caravans[tags.unit_number]
    if Caravan.validity_check(caravan_data) then
        Caravan.build_gui(player, caravan_data.entity, true)
    end
end

gui_events[defines.events.on_gui_click]['py_view_inventory_button'] = function(event)
    local element = event.element
    local tags = element.tags
    local caravan_data = global.caravans[tags.unit_number]
    local has_anything, tooltip = Caravan.get_inventory_tooltip(caravan_data)
    element.tooltip = tooltip
    element.visible = has_anything
end

gui_events[defines.events.on_gui_click]['py_open_map_button'] = function(event)
    local player = game.get_player(event.player_index)
    local element = event.element
    local tags = element.tags
    local caravan_data = global.caravans[tags.unit_number]
    local entity = caravan_data.entity

    player.opened = nil
    player.zoom_to_world(entity.position, 0.5, entity)
end

local function title_edit_mode(caption_flow, caravan_data)
    local title = caption_flow.title
    local index = title.get_index_in_parent()
    title.destroy()

    local textfield = caption_flow.add{
        type = 'textfield',
        name = 'py_rename_caravan_textfield',
        text = caravan_data.name or '',
        tags = {index = caravan_data.entity.unit_number},
        index = index
    }
    textfield.style.horizontally_stretchable = true
    textfield.focus()
    textfield.select_all()
    local button = caption_flow.py_rename_caravan_button
    button.style = 'item_and_count_select_confirm'
    button.sprite = 'utility/check_mark'
    button.hovered_sprite = 'utility/check_mark'
    button.clicked_sprite = 'utility/check_mark'
end

local function title_display_mode(caption_flow, caravan_data)
    local textfield = caption_flow.py_rename_caravan_textfield
    local index = textfield.get_index_in_parent()
    textfield.destroy()

    local title = caption_flow.add{
        type = 'label',
        name = 'title',
        caption = Caravan.name_fallback(caravan_data),
        style = 'frame_title',
        ignored_by_interaction = true,
        index = index
    }
    title.style.maximal_width = 120
    local button = caption_flow.py_rename_caravan_button
    button.style = 'frame_action_button'
    button.sprite = 'utility/rename_icon_small_white'
    button.hovered_sprite = 'utility/rename_icon_small_black'
    button.clicked_sprite = 'utility/rename_icon_small_black'
end

gui_events[defines.events.on_gui_click]['py_rename_caravan_button'] = function(event)
    local element = event.element
    local caravan_data = global.caravans[element.tags.unit_number]
    local caption_flow = element.parent
    if caption_flow.title then
        title_edit_mode(caption_flow, caravan_data)
    else
        title_display_mode(caption_flow, caravan_data)
    end
end

gui_events[defines.events.on_gui_text_changed]['py_rename_caravan_textfield'] = function(event)
    local element = event.element
    local caravan_data = global.caravans[element.tags.index]
    caravan_data.name = element.text
end

gui_events[defines.events.on_gui_confirmed]['py_rename_caravan_textfield'] = function(event)
    local element = event.element
    local caravan_data = global.caravans[element.tags.index]
    title_display_mode(element.parent, caravan_data)
end