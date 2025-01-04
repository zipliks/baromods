-- К оружие из WEAPONS соотносится патрон из AMMO, индекс к индексу
local WEAPONS = {
    "smg", -- 1
    "revolver", -- 2
    "stunbaton", -- 3
    "nucleargun", -- 4
    "handcannon", -- 5
    "harpoongun", -- 6
    "weldingtool", -- 7
    "plasmacutter", -- 8
    "rifle", -- 9
    "autoshotgun" -- 10
}
local AMMO = {
    "smgammo", -- 1
    "revolverammo", -- 2
    "mobilebattery", -- 3
    "reactorfuel", -- 4
    "handcannonammo", -- 5
    "harpoonammo", -- 6
    "weldingfuel", -- 7
    "oxygensource", -- 8
    "rifleammo", -- 9
    "shotgunammo" -- 10
}

-- Рекурсивный поиск патронов
local function findRecursively(container, tag)
    for item in container.OwnInventory.AllItems do
        if item.OwnInventory ~= nil then
            findRecursively(item, tag)
        end
        if item.HasTag(tag) then
            return item
        end
    end
end

local function handleWeaponHand(weaponHand, usedItem, itemUser)
    if weaponHand then
        local weaponIdentifier = weaponHand.Prefab.Identifier
        local ammoIndex = nil

        -- Проверяем является ли предмет в руках оружием из таблицы
        for i, weapon in ipairs(WEAPONS) do
            if weaponIdentifier == weapon then
                ammoIndex = i
                break
            end
        end

        if ammoIndex then
            -- Проверка пустого магазина
            local ammoTag = AMMO[ammoIndex]
            local ammoItem = usedItem.OwnInventory.FindItemByTag(ammoTag, true)

            --Повторно берём предметы в руках, что убедиться, что не утащим патроны из второй руки
            local rHand = itemUser.Inventory.GetItemInLimbSlot(InvSlotType.RightHand)
            local lHand = itemUser.Inventory.GetItemInLimbSlot(InvSlotType.LeftHand)

            -- Мне впадлу искать свободный слот для пустых боеприпасов, роняем их на пол
            if ammoItem and ammoItem.Condition > 0 then
                return
            elseif ammoItem and ammoItem.Condition <= 0 then
                ammoItem.Drop()
            end

            local foundItem = nil
            for item in itemUser.Inventory.AllItems do
                if item.OwnInventory ~= nil and item ~= rHand and item ~= lHand then
                    foundItem = findRecursively(item, ammoTag)
                end
                if foundItem then
                    usedItem.OwnInventory.TryPutItem(foundItem, 0, true, true, itemUser)
                    break
                end
                if item.HasTag(ammoTag) then
                    usedItem.OwnInventory.TryPutItem(item, 0, true, true, itemUser)
                    break
                end
            end
        end
    end
end

Hook.Add("item.use", "autoreload", function(usedItem, character, _)
    if not character then
        return
    end

    if character and not character.IsPlayer then
        return
    end

    local rHand = character.Inventory.GetItemInLimbSlot(InvSlotType.RightHand)
    local lHand = character.Inventory.GetItemInLimbSlot(InvSlotType.LeftHand)

    handleWeaponHand(rHand, usedItem, character)
    handleWeaponHand(lHand, usedItem, character)
end)
