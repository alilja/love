-- basically the way a combo system needs to work is:
-- listen to the key inputs
-- match the input to a known combo
-- start paying attention to just those combos
-- if the timer for that key expires (i.e. the player hasn't pressed any more keys in the last n seconds, where n is the time specified for that key in the combo), trigger the combo that it matches
-- if a key is pressed before that timer expires, look for the next combo that it matches

ComboManager = Object:extend()
function ComboManager:new(combos)
	self.combos = combos or {}
	self.current_step = 1
end

function ComboManager:add_combo(combo)
	if type(combos) ~= "table" then return false end
	table.insert(self.combos, combo)
	return true
end

function ComboManager:check(key)
end

Step = Object:extend()
function Step:new(buttons, time)
	self.time = time or 0.1
	self.buttons = buttons
end

function Step:check_input(input)
	if input == self.buttons then
		return true
	end
	return false
end