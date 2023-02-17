local FUN = require '__pycoalprocessing__/prototypes/functions/functions'

if data then
    for _, recipe in pairs({
        table.deepcopy(data.raw.recipe['caged-xeno-1']),
        table.deepcopy(data.raw.recipe['caged-xeno-2']),
        table.deepcopy(data.raw.recipe['caged-xeno-3']),
        table.deepcopy(data.raw.recipe['caged-xeno-4']),
    }) do
        recipe.name = recipe.name .. '-dna-polymerase'
        FUN.add_ingredient(recipe, {name = 'dna-polymerase', amount = 1, type = 'item'})
        data:extend{recipe}
    end

    data:extend{{
        type = 'recipe',
        name = 'xeno-rc-breeding',
        enabled = false,
        energy_required = 120,
        category = 'rc',
        main_product = 'caged-xeno',
        ingredients = {
            {'water-barrel', 6},
            {'bones', 8},
            {'guts', 7},
            {'caged-dingrits', 1},
            {'bedding', 3},
        },
        results = {
            {'caged-xeno', 1},
            {'empty-barrel', 6}
        }
    }}

    for _, recipe in pairs({
        table.deepcopy(data.raw.recipe['xeno-egg-1']),
        table.deepcopy(data.raw.recipe['xeno-egg-2']),
        table.deepcopy(data.raw.recipe['xeno-egg-3']),
        table.deepcopy(data.raw.recipe['xeno-egg-4']),
    }) do
        recipe.name = recipe.name .. '-cheap'
        FUN.remove_ingredient(recipe, 'bones')
        FUN.add_ingredient_amount(recipe, 'fish', -15)
        FUN.add_ingredient(recipe, {'hydrofluoric-acid-barrel', 1})
        FUN.add_result_amount(recipe, 'empty-barrel', 1)
        data:extend{recipe}
    end
end

return {
    affected_entities = { -- the entities that should be effected by this tech upgrade
        'xenopen-mk01',
        'xenopen-mk02',
        'xenopen-mk03',
        'xenopen-mk04',
    },
    master_tech = { -- tech that is shown in the tech tree
        name = 'xeno-upgrade',
        icon = '__pyalienlifegraphics3__/graphics/technology/updates/u-xeno.png',
        icon_size = 128,
        order = 'c-a',
        prerequisites = {'xeno-mk03'},
        unit = {
            count = 500,
            ingredients = {
                {'automation-science-pack', 1},
                {'logistic-science-pack', 1},
                {'military-science-pack', 1},
                {'chemical-science-pack', 1},
                {'production-science-pack', 1},
                {'py-science-pack-4', 1},
            },
            time = 45
        }
    },
    sub_techs = {
        {
            name = 'ap',
            icon = '__pyalienlifegraphics3__/graphics/technology/ap.png',
            icon_size = 128,
            order = 'c-a',
            effects = { -- the effects the tech will have on the building. valid types: 'module-effects', 'unlock-recipe', 'lock-recipe', 'recipe-replacement'
                {productivity = 0.10, type = 'module-effects'},
                {old = 'caged-xeno-1', new = 'caged-xeno-1-dna-polymerase', type = 'recipe-replacement'},
                {old = 'caged-xeno-2', new = 'caged-xeno-2-dna-polymerase', type = 'recipe-replacement'},
                {old = 'caged-xeno-3', new = 'caged-xeno-3-dna-polymerase', type = 'recipe-replacement'},
                {old = 'caged-xeno-4', new = 'caged-xeno-4-dna-polymerase', type = 'recipe-replacement'},
            },
        },
        {
            name = 'herm',
            icon = '__pyalienlifegraphics3__/graphics/technology/herm.png',
            icon_size = 128,
            order = 'c-a',
            effects = { -- the effects the tech will have on the building. valid types: 'module-effects', 'unlock-recipe', 'lock-recipe', 'recipe-replacement'
                {recipe = 'xeno-rc-breeding', type = 'unlock-recipe'}
            }
        },
        {
            name = 'hive',
            icon = '__pyalienlifegraphics3__/graphics/technology/hive.png',
            icon_size = 128,
            order = 'c-a',
            effects = { -- the effects the tech will have on the building. valid types: 'module-effects', 'unlock-recipe', 'lock-recipe', 'recipe-replacement'
                {consumption = 3.33, speed = 0.1, type = 'module-effects'},
                {old = 'xeno-egg-1', new = 'xeno-egg-1-cheap', type = 'recipe-replacement'},
                {old = 'xeno-egg-2', new = 'xeno-egg-2-cheap', type = 'recipe-replacement'},
                {old = 'xeno-egg-3', new = 'xeno-egg-3-cheap', type = 'recipe-replacement'},
                {old = 'xeno-egg-4', new = 'xeno-egg-4-cheap', type = 'recipe-replacement'},
            }
        }
    },
    module_category = 'xeno'
}