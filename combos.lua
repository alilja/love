
Combo = Object:extend()
function Combo:new(steps)
	self.steps = steps or {}

	self.max_check_time = self:calculate_duration()

	self.input_sequence = {}
end

function Combo:add_step(step)
	table.insert(self.steps, step)
	self.max_check_time = self.max_check_time + step.time
end

function Combo:calculate_duration()
	for i, step in ipairs(self.steps) then
		self.max_check_time = self.max_check_time + self.steps[i].time
	end
end

function Combo:check_key(key, time):



function Combo:check(sequence, times)
	total_input_time = 0
	for i = 1, #sequence do
		duration = times[i]
		if total_input_time + duration > self.max_check_time then return false end

		input_step = sequence[i]
		combo_step = self.steps[i]

		if step:check_input(input_step) and duration < step:time then
			total_input_time = total_input_time + duration
		else
			return false
		end
	end
	return true
end


Step = Object:extend()
function Step:new(buttons, time)
	self.time = 0.1 or time
	self.buttons = buttons
end

function Step:check_input(inputs)
	-- make sure ALL the inputs are in the step
	local ty1 = type(self.buttons)
	local ty2 = type(inputs)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return self.buttons == inputs end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(self.buttons)
	if not ignore_mt and mt and mt.__eq then return self.buttons == inputs end
	for k1,v1 in pairs(self.buttons) do
		local v2 = inputs[k1]
		if v2 == nil or not deepcompare(v1,v2) then return false end
	end
	for k2,v2 in pairs(inputs) do
		local v1 = self.buttons[k2]
		if v1 == nil or not deepcompare(v1,v2) then return false end
	end
	return true
end