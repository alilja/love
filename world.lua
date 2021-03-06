World = Object:extend()

function World:new()
	self.decay = 0.74
	self.gravity = 6000

	self.combos = {}
	self.combo_time = 0
	self.max_combo_time = 0.5

	self.ground = love.graphics.getHeight() - 150

	self.slow_time = 1
	self.slow_time_return = 2
	self.slow_time_remaining = 0
	self.slow_time_return_speed = 1
	self.slow_max = 10
end

function World:slow(factor, duration, return_time)
	self.slow_time = self.slow_time * factor
	if self.slow_time > self.slow_max then self.slow_time = self.slow_max end
	self.slow_time_return = duration
	self.slow_time_return_speed = return_time
end

function World:calculate_slow_time(dt)
	if self.slow_time > 1 then
		dt = dt * (1 / self.slow_time)
		self.slow_time_remaining = self.slow_time_remaining + (self.slow_time * dt)
		if self.slow_time_remaining >= self.slow_time_return then
			-- going to need to know start and finish times to calculate a percentage, then scale the slow time by that percentage + 1
			self.slow_time = self.slow_time + ((self.slow_time / -self.slow_time_return_speed) * (dt * self.slow_time^2))
			print(self.slow_time)
			print(self.slow_time_remaining)
			if self.slow_time <= 1.01 then
				self.slow_time = 1
				self.slow_time_remaining = 0
			end
		end
	end
	return dt
end
