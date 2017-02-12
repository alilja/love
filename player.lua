local inspect = require 'lib.inspect'
Player = Object:extend()

function Player.new(self)
	STATE_IDLE = 0
	STATE_RUN = 1
	STATE_JUMP = 2
	STATE_ATTACK = 3
	STATE_SPECIAL = 4
	self.state = STATE_IDLE
	self.x = 100
	self.y = 300
	self.scale = 2.0
	self.vel = {
		x = 0,
		y = 0
	}

	self.hang_time = 0
	self.max_hang_time = 0.5

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

	self.pose = "idle"
end

function Player:jump(force)
	self.vel.y = force
	self.state = STATE_JUMP
	jump_tolerance_trigger = false
end

function Player:handle_input(input)
	held = held or false
	if self.state ~= STATE_JUMP then
		if input == "space" then
			print(self.state)
			self:jump(jump_force)
			print(self.state)
		end
		if input == "right" then
			self.vel.x = calculate_horizontal_speed("right", self.vel.x)
			self.facing = "right"
			self.state = STATE_RUN
		end
		if input == "left" then
			self.vel.x = calculate_horizontal_speed("left", self.vel.x)
			self.facing = "left"
			self.state = STATE_RUN
		end
		if input == "nil" then
			self.vel.x = self.vel.x * decay
			if math.abs(self.vel.x) < 1 then
				self.state = STATE_IDLE
			end
		end
	elseif self.state == STATE_JUMP then
		if input == "space" then
			print(ground - jump_tolerance)
			if self.y >= ground - jump_tolerance then
				jump_tolerance_trigger = true
				print("tolerance jump")
			end
		end
		if input == "right" then
			self.vel.x = calculate_horizontal_speed("right", self.vel.x)
			self.facing = "right"
		end
		if input == "left" then
			self.vel.x = calculate_horizontal_speed("left", self.vel.x)
			self.facing = "left"
		end
		if input == "nil" then
			self.vel.x = self.vel.x * air_decay
		end
	end
end

function Player:update(dt)
	if love.keyboard.isDown("right") then
		self:handle_input("right")
	elseif love.keyboard.isDown("left") then
		self:handle_input("left")
	else
		self:handle_input("nil")
	end

	-- combos
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
				self.max_hang_time = 0.3
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
					self.max_hang_time = 0.6
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
				self.state = STATE_JUMP
			end
		end
	end

	self.vel.y = self.vel.y + gravity
	if self.vel.y > 500 then self.vel.y = 500 end
	if self.vel.y > 0 then
		-- we're falling, change animations as needed
	end

	-- hangtime
	if self.hang_time > self.max_hang_time then
		self.hang_time = 0
		self.max_hang_time = 0
	elseif self.max_hang_time > 0 then
		self.vel.y = 0
		self.hang_time = self.hang_time + dt
	end


	self.x = self.x + self.vel.x * dt
	self.y = self.y + self.vel.y * dt

	-- stick to ground
	if self.y >= ground then
		self.y = ground
		self.vel.y = 500
		if math.abs(self.vel.x) > 1 then self.state = STATE_RUN else self.state = STATE_IDLE end
		if jump_tolerance_trigger then
			self:jump(jump_force)
		end
	end

	-- wraparound
	if self.x > love.graphics.getWidth() then self.x = 0 end
	if self.x < 0 then self.x = love.graphics.getWidth() end

	-- animations
	new_pose = "idle"
	if self.state == STATE_JUMP then
		new_pose = "air"
	elseif self.state == STATE_RUN then
		new_pose = "run"
	elseif self.state == STATE_IDLE then
		new_pose = "idle"
	end
	self.pose = new_pose .. "_" .. self.facing

	self.animation = self.animations[self.pose]["animation"]
	self.animation:update(dt)
end

function Player:draw()
	self.animation:draw(self.animations[self.pose]["image"], self.x, self.y, 0, self.scale, self.scale)
end