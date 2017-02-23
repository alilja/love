World = Object:extend()

function World:new()
	self.decay = 0.74
	self.gravity = 6000

	self.combos = {}
	self.combo_time = 0
	self.max_combo_time = 0.5

	self.ground = love.graphics.getHeight() - 150

	self.slow_time = 1
	self.slow_time_return = 1
	self.slow_time_remaining = 0
	self.slow_time_return_speed = 1
end

function World:slow_time(dt)
	if self.slow_time > 1 then
		self.slow_time_remaining = self.slow_time_remaining + dt * self.slow_time
		if self.slow_time_remaining >= self.slow_time_return then
			self.slow_time = self.slow_time - (1 / self.slow_time_return_speed) * dt * self.slow_time^2
			if self.slow_time <= 1 then
				self.slow_time = 1
				self.slow_time_remaining = 0
			end
		end
	end
end