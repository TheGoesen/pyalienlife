RECIPE {
    type = 'recipe',
    name = 'bioport',
    energy_required = 200,
    enabled = false,
    category = 'creature-chamber',
    ingredients = {
        {'megadar', 1},
        {'earth-generic-sample', 5},
        {'cdna', 5},
        {'resveratrol', 10},
        {'alien-sample-02', 5},
        {'bio-sample', 20},
        {type = 'fluid', name = 'water-saline', amount = 200},
        {type = 'fluid', name = 'fetal-serum', amount = 100},
        {type = 'fluid', name = 'coal-slurry', amount = 100},
    },
    results = {
        {'bioport', 1}
    }
}:add_unlock{'biofluid-mk01'}

ITEM {
    type = 'item',
    name = 'bioport',
    icon = '__pyalienlifegraphics2__/graphics/icons/o-roboport.png',
    icon_size = 64,
    flags = {},
    subgroup = 'py-alienlife-biofluid-network',
    order = 'a',
    place_result = 'bioport',
    stack_size = 10
}

data:extend{{
    name = 'biofluid',
    type = 'recipe-category',
    hidden = true
}}

local recipe = RECIPE {
    type = 'recipe',
    name = 'bioport-hidden-recipe',
    enabled = false,
    allow_inserter_overload = false,
    hidden = true,
    ingredients = {
        {'gobachov', data.raw.item['gobachov'].stack_size},
        {'huzu', data.raw.item['huzu'].stack_size},
        {'chorkok', data.raw.item['chorkok'].stack_size},
    },
    results = {
        {'guano', data.raw.item['guano'].stack_size},
    },
    energy_required = 100,
    category = 'biofluid',
    icon = '__pyalienlifegraphics2__/graphics/icons/o-roboport.png',
    icon_size = 64,
    subgroup = 'py-alienlife-biofluid-network',
}

for name, _ in pairs(Biofluid.favorite_foods) do
    recipe:add_ingredient{name = name, amount = data.raw.item[name].stack_size, type = 'item'}
end

ENTITY {
    type = 'assembling-machine',
    name = 'bioport',
    bottleneck_ignore = true,
    icon = '__pyalienlifegraphics2__/graphics/icons/o-roboport.png',
    icon_size = 64,
    flags = {'placeable-player', 'player-creation'},
    minable = {mining_time = 1, result = 'bioport'},
    selection_priority = 49,
    fixed_recipe = 'bioport-hidden-recipe',
    max_health = 500,
    allowed_effects = {'consumption', 'pollution'},
    module_specification = {module_slots = 1},
    corpse = 'big-remnants',
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    dying_explosion = 'medium-explosion',
    collision_mask = {vessel_collision_mask},
    crafting_speed = 1,
    energy_usage = '1W',
    crafting_categories = {'biofluid'},
    energy_source = {
        connections = {{
            direction = 4,
            position = {0, 2},
        }},
        max_temperature = 0,
        default_temperature = 0,
        min_working_temperature = 0,
        max_transfer = '1W',
        specific_heat = '1W',
        type = 'heat',
        pipe_covers = require('__pyalienlife__/prototypes/biofluid/pipe-cover'),
        heat_pipe_covers = require('__pyalienlife__/prototypes/biofluid/pipe-cover'),
    },
    show_recipe_icon = false,
    vehicle_impact_sound = {filename = '__base__/sound/car-metal-impact.ogg', volume = 0.65},
    integration_patch = {
        layers = {
            {
                filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/raw.png',
                priority = 'extra-high',
                width = 175,
                height = 182,
                shift = util.by_pixel(16.75, -38.75 - 32),
                hr_version = {
                    filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/hr-raw.png',
                    priority = 'extra-high',
                    width = 351,
                    height = 365,
                    shift = util.by_pixel(16.75, -38.75 - 32),
                    scale = 0.5,
                    frame_count = 1
                },
                frame_count = 1
            },
            {
                filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/glow.png',
                priority = 'extra-high',
                width = 175,
                height = 182,
                shift = util.by_pixel(16.75, -38.75 - 32),
                draw_as_glow = true,
                hr_version = {
                    filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/hr-glow.png',
                    priority = 'extra-high',
                    width = 351,
                    height = 365,
                    shift = util.by_pixel(16.75, -38.75 - 32),
                    draw_as_glow = true,
                    scale = 0.5,
                    frame_count = 1
                },
                frame_count = 1
            },
            {
                filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/sh.png',
                priority = 'extra-high',
                draw_as_shadow = true,
                width = 176,
                height = 116,
                shift = {1.5, 1.5},
                hr_version = {
                    filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/hr-sh.png',
                    priority = 'extra-high',
                    draw_as_shadow = true,
                    width = 352,
                    height = 232,
                    shift = {1.5, 1.5},
                    scale = 0.5,
                    frame_count = 1
                },
                frame_count = 1
            }
        }
    },
    integration_patch_render_layer = 'higher-object-under'
}

local function random_order(l)
	local order = {}
	local i = 1
	for _, elem in pairs(l) do
        table.insert(order, math.random(1, i), elem)
        i = i + 1
	end
	return order
end

local frame_offset = 0
local function add_creature_animations(animations, animation_order, name)
    animation_order = random_order(animation_order)
    for i, _ in pairs(animation_order) do
        local layers = {}
        for j = 1, i do
            local layer_data = animation_order[j]
            local shift = util.by_pixel(layer_data[1] / 2 - 62, layer_data[2] / 2 - 113.75 - 32)
            if name == 'chorkok' then shift[2] = shift[2] + 0.16 end
            layers[#layers+1] = table.deepcopy(animations[layer_data[3]])
            layers[#layers].shift = shift
        end
        table.sort(layers, function(a, b) return a.priority < b.priority end)
        for _, layer in pairs(layers) do
            layer.priority = 'medium'
            for _ = 0, frame_offset do
                table.insert(layer.frame_sequence, 1, layer.frame_sequence[#layer.frame_sequence])
                layer.frame_sequence[#layer.frame_sequence] = nil
            end
            frame_offset = frame_offset + 13
        end
        data:extend{{
            type = 'animation',
            name = 'bioport-animation-' .. name .. '-' .. i,
            layers = layers,
        }}
    end
end

add_creature_animations(
    {
        {
            filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/g1.png',
            height = 64,
            width = 64,
            frame_count = 30,
            line_length = 6,
            priority = 0,
            scale = 0.75,
            frame_sequence = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}
        },
        {
            filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/g2.png',
            height = 64,
            width = 32,
            frame_count = 30,
            line_length = 6,
            priority = 0,
            scale = 0.75,
            frame_sequence = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}
        },
        {
            filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/g3.png',
            height = 64,
            width = 32,
            frame_count = 30,
            line_length = 6,
            priority = 0,
            scale = 0.75,
            frame_sequence = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}
        },
    },
    {{30, 69, 1}, {200, 35, 1}, {178, 127, 1}, {152, 25, 2}, {71, 59, 2}, {221, 105, 2}, {125, 143, 2}, {97, 19, 3}, {179, 78, 3}, {99, 131, 3}},
    'gobachov'
)

add_creature_animations(
    {
        {
            filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/c1.png',
            height = 64,
            width = 32,
            frame_count = 50,
            repeat_count = 3,
            line_length = 10,
            priority = 0,
            scale = 0.75,
            frame_sequence = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50}
        },
        {
            filename = '__pyalienlifegraphics2__/graphics/entity/bots/roboport/c2.png',
            height = 64,
            width = 128,
            frame_count = 70,
            line_length = 10,
            priority = 1,
            scale = 0.75,
            frame_sequence = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
        }
    },
    {{5, 164, 1}, {29, 188, 1}, {52, 201, 2}, {83, 210, 1}, {112, 214, 1}, {147, 215, 1}, {182, 209, 2}, {208, 201, 1}, {233, 186, 1}, {253, 164, 1}},
    'chorkok'
)