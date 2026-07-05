local mod = SMODS.current_mod or {}
local orig_pseudoseed = pseudoseed

---@param key any
---@param ... unknown
---@return number
_G.pseudoseed = function(key, ...)
    return mod.pseudoseed_locked and (math.abs(
            tonumber(
                string.format("%.13f", (2.134453429141 + (
                    G.GAME.pseudorandom[key] or pseudohash(
                        key .. (G.GAME.pseudorandom.seed or "")
                    )
                ) * 1.72431234) % 1)
            ) or 0) +
        (G.GAME.pseudorandom.hashed_seed or 0)
    ) / 2 or orig_pseudoseed(key, ...)
end

---@param key_append string?
---@return fun(self: self, info_queue: any[]): { vars: { [1]: string } }
local function next_joker(key_append)
    return function(self, info_queue)
        if G.SETTINGS.paused or not mod.config[self.key] then
            return {vars = {localize "k_unknown"}}
        end

        local playing_cards = G.playing_cards
        G.playing_cards = G.playing_cards or {}
        mod.pseudoseed_returns_center = true
        mod.pseudoseed_locked = true

        local joker = create_card(
            "Joker",
            G.jokers,
            key_append == "sou",
            key_append == "wra" and 0.99 or nil,
            true,
            nil,
            nil,
            key_append
        )

        mod.pseudoseed_locked = false
        mod.pseudoseed_returns_center = false
        G.playing_cards = playing_cards

        info_queue[#info_queue + 1] = joker
        return {vars = {localize {type = "name_text", key = joker.key, set = joker.set}}}
    end
end

SMODS.Consumable:take_ownership("soul", {loc_vars = next_joker "sou"}, true)
SMODS.Consumable:take_ownership("wraith", {loc_vars = next_joker "wra"}, true)
SMODS.Consumable:take_ownership("judgement", {loc_vars = next_joker "jud"}, true)

local function toggle(id)
    return create_toggle {
        label = localize {type = "variable", key = "b_Soulseeking_" .. id},
        ref_table = mod.config,
        ref_value = id,
        scale = 2,
    }
end

function SMODS.current_mod.config_tab()
    return {
        n = G.UIT.ROOT,
        config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.BLACK},
        nodes = {{
            n = G.UIT.C,
            config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.CLEAR},
            nodes = {
                toggle "c_judgement",
                toggle "c_wraith",
                toggle "c_soul",
            },
        }},
    }
end
