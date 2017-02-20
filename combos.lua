
Combo = Object:extend()
function Combo:new(steps)
	self.steps = steps or {}

	self.max_check_time = self:calculate_duration()

	self.counter = 1
end

function Combo:add_step(step)
	table.insert(self.steps, step)
	self.max_check_time = self.max_check_time + step.time
end

function Combo:calculate_duration()
	time = 0
	for i, step in ipairs(self.steps) do
		time = time + self.steps[i].time
	end
	return time
end

-- call every time a key is pressed
-- returns true if keypress finishes combo
-- returns false if keypress fails combo
function Combo:check_key(key, duration)
	step = self.steps[self.counter]
	if step:check_input(key) and duration <= step.time then
		self.counter = self.counter + 1
		if self.counter > #self.steps then
			self.counter = 1
			return true
		end
	else
		self.counter = 1
		return false
	end
end


function Combo:check_sequence(sequence, times)
	total_input_time = 0
	for i = 1, #sequence do
		duration = times[i]
		if total_input_time + duration > self.max_check_time then return false end

		input_step = sequence[i]
		combo_step = self.steps[i]

		if step:check_input(input_step) and duration < step.time then
			total_input_time = total_input_time + duration
		else
			return false
		end
	end
	return true
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