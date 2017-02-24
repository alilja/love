-- basically the way a combo system needs to work is:
-- listen to the key inputs
-- match the input to a known combo
-- start paying attention to just those combos
-- if the timer for that key expires (i.e. the player hasn't pressed any more keys in the last n seconds, where n is the time specified for that key in the combo), trigger the combo that it matches
-- if a key is pressed before that timer expires, look for the next combo that it matches

ComboManager = Object:extend()
function ComboManager:new(combos)
	self.combos = combos or {}
	self.combo_keys = {"a", "s"} -- TODO: write a function to automatically calcuate this
	self.max_combo_time = 1 -- TODO: write a function to automatically calcuate this

	self.current_step = 1
	self.check_combos = table.copy(self.combos)
	self.time_since_last_keypress = 0
end

function ComboManager:add_combo(combo)
	if type(combos) ~= "table" then return false end
	table.insert(self.combos, combo)
	return true
end

function ComboManager:_key_in_combo_keys(key)
	for _, combo_key in ipairs(self.combo_keys) do
		if key == combo_key then return true end
	end
	return false
end

function ComboManager:check(key)
	if not self:_key_in_combo_keys(key) then return false end -- only do this if the key is an action key
	--find combos that match the key in the current step
	if #self.check_combos == 0 or self.time_since_last_keypress > self.max_combo_time then self:_reset(); print("check_combos length reset") end -- no combos left, reset the system
	print(self.time_since_last_keypress)
	print(self.current_step)
	for i = #self.check_combos, 1, -1 do
		combo = self.check_combos[i]
		name = self.check_combos[i].name

		-- make sure the step isn't bigger than the combo
		if combo.size >= self.current_step then
			print(name .. ": combo is long enough")
			current_step_button = combo:get_step(self.current_step)
			if not current_step_button.check_input(key) then
				print(name .. ": key not in combo, removing...")
				-- the key pressed isn't in the combo, so remove it and move on to the next combo
				table.remove(self.check_combos, i)
			end

			if self.time_since_last_keypress <= current_step_button.time then
				if self.current_step == combo.size then
					print(name .. ": combo time expired, returning")
					-- the input key matches the last step of the combo _and_ the timer has expired
					-- this means we should return the combo and reset the system
					self:_reset()
					return combo
				end
			else
				print(name .. ": combo time expired, not matched, removing...")
				table.remove(self.check_combos, i)
			end
			print(name .. ": still checking")
			-- the only other alternative is that the key is in the combo but the timer hasn't
			-- expired yet, which means we need to keep checking
		else
			print(name .. ": " .. combo.size)
			print(name .. ": combo not long enough, removing...")
			-- if the current step is bigger than the combo we're checking, remove it
			table.remove(self.check_combos, i)
		end
	end
	self.current_step = self.current_step + 1
	self.time_since_last_keypress = 0
end

function ComboManager:update(dt)
	self.time_since_last_keypress = self.time_since_last_keypress + dt
end

function ComboManager:_reset()
	self.current_step = 1
	self.check_combos = table.copy(self.combos)
	self.time_since_last_keypress = 0
	print("reset: " .. #self.combos)
	print("reset: " .. self.combos[1].name)
end

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

Combo = Object:extend()
function Combo:new(name, steps)
	self.name = name
	self.steps = steps
	self.size = #steps
	print(self.size)
end

function Combo:add_step(step)
	table.insert(self.steps, step)
	self.size = self.size + 1
end

function Combo:get_step(num)
	return self.steps[num]
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