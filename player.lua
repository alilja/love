local inspect = require 'lib.inspect'
Player = Object:extend()

function Player.new(self)
	self.x = 100
	self.y = 300
	self.scale = 2.0
	self.vel = {
		x = 0,
		y = 0
	}

	self.is_jumping = false
	self.facing = "left"

	self.animations = load_animation({
			{"idle_left", "idle", "1-5", false},
			{"idle_right", "idle", "1-5", true},
			{"run_left", "run", "1-8", false},
			{"run_right", "run", "1-8", true},
			{"land_left", "land", "1-3", false},
			{"land_right", "land", "1-3", true},
			{"jump_left", "jump", "1-3", false},
			{"jump_right", "jump", "1-3", true},
			{"air_left", "air", "1-1", false},
			{"air_right", "air", "1-1", true},
		}, "images/an-1x/")

	self.pose = "idle_left"
end

function Player:jump(force)
	self.vel.y = jump_force
	self.is_jumping = true
	jump_tolerance_trigger = false
end

function Player:update(dt)
	if love.keyboard.isDown("right") then
		self.vel.x = calculate_horizontal_speed("right", self.vel.x)
		self.pose = "run_right"
		self.facing = "right"

	elseif love.keyboard.isDown("left") then
		self.vel.x = calculate_horizontal_speed("left", self.vel.x)
		self.pose = "run_left"
		self.facing = "left"
	else
		if self.is_jumping then
			self.vel.x = self.vel.x * air_decay
		else
			self.vel.x = self.vel.x * decay
		end
	end

	if math.abs(self.vel.x) < 0.1 then
		if self.facing == "left" then self.pose = "idle_left" end
		if self.facing == "right" then self.pose = "idle_right" end
	end

	if next(combos) ~= nil then
		combo_time = combo_time + dt

		combo = check_combos(combos)
		if combo_time >= max_combo_time or combo ~= nil then
			print(combo)
			combos = {}
			combo_time = 0

			if combo == "double a" then
				--impulse = 10000
				--if is_jumping then impulse = impulse * 2 end
				max_hang_time = 0.1
				distance = 300
				if self.is_jumping then distance = distance * 1.5 end
				if love.keyboard.isDown("right") then
					--vel = vel + impulse
					self.x = self.x + distance
				end
				if love.keyboard.isDown("left") then
					--vel = vel - impulse
					self.x = self.x - distance
				end
				if love.keyboard.isDown("up") then
					--jump_vel = jump_vel - impulse/15
					self.y = self.y - distance/2
					max_hang_time = 0.3
				end
				if love.keyboard.isDown("down") then
					--jump_vel = jump_vel - impulse/15
					self.y = self.y + distance/2
					if self.y >= ground then self.y = ground end
				end
			elseif combo == "ass" then
				self.vel.x = 0
				self.vel.y = 0
			elseif combo == "asas" then
				self.vel.y = self.vel.y - 2000
				self.is_jumping = true
			end
		end
	end

	self.vel.y = self.vel.y + gravity
	if self.vel.y > 500 then self.vel.y = 500 end
	if self.vel.y > 0 then
		-- we're falling, change animations as needed
	end
	if hang_time > max_hang_time then
		hang_time = 0
		max_hang_time = 0
	elseif max_hang_time > 0 then
		self.vel.y = 0
		hang_time = hang_time + dt
	end

	self.x = self.x + self.vel.x * dt
	self.y = self.y + self.vel.y * dt

	if self.y >= ground then
		self.y = ground
		self.vel.y = 500
		self.is_jumping = false
		if jump_tolerance_trigger then
			self:jump()
		end
	end

	if self.x > love.graphics.getWidth() then self.x = 0 end
	if self.x < 0 then self.x = love.graphics.getWidth() end

	self.animation = self.animations[self.pose]["animation"]
	self.animation:update(dt)
end

function Player:draw()
	self.animation:draw(self.animations[self.pose]["image"], self.x, self.y, 0, self.scale, self.scale)
end