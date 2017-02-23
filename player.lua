local inspect = require 'lib.inspect'
Player = Object:extend()

function Player:new(world)
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

	self.world = world

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


	self.acceleration = 80 -- pixels per second
	self.max_velocity = 400

	self.jump_force = -1250
	self.jump_cutoff = -400 -- if your speed is below this, you are fixed to this speed
					   -- basically, the lower this number, the sooner you are fixed
					   -- to a low jump
	self.jump_tolerance = 20 -- how far away from the ground can you be before you can
						-- trigger a jump again; the jump happens as soon as the character
						-- touches the ground

	self.reactivity_percent = 1.95 -- how quickly you start moving in the opposite direction


	self.jump_tolerance_trigger = false

	-- how movement changes in the air
	self.air_accel_control = 2.2
	self.air_vel_control = 0.9
	self.air_reactivity = 0.6
	self.air_decay = 0.94
end

function Player:jump(force)
	self.vel.y = force
	self.state = STATE_JUMP
	self.jump_tolerance_trigger = false
end


function Player:calculate_horizontal_speed(direction, velocity)
	accel = self.acceleration
	react = self.reactivity_percent
	if self.state == STATE_JUMP then
		accel = accel * self.air_accel_control
		react = self.air_reactivity
	end
	if direction == "left" and velocity > 0 then -- moving right and press left
		velocity = velocity - (accel + accel * react)
	elseif direction == "right" and velocity < 0 then -- moving left and press right
		velocity = velocity + (accel + accel * react)
	elseif direction == "left" then
		velocity = velocity - accel
	elseif direction == "right" then
		velocity = velocity + accel
	end

	if velocity > self.max_velocity then velocity = self.max_velocity end -- cap
	if velocity < -self.max_velocity then velocity = -self.max_velocity end -- cap

	if self.state == STATE_JUMP then velocity = velocity * self.air_vel_control end
	return velocity
end

function Player:handle_input(input)
	if self.state ~= STATE_JUMP then
		if input == "space" then
			print(self.state)
			self:jump(self.jump_force)
			print(self.state)
		end
		if input == "right" then
			self.vel.x = self:calculate_horizontal_speed("right", self.vel.x)
			self.facing = "right"
			self.state = STATE_RUN
		end
		if input == "left" then
			self.vel.x = self:calculate_horizontal_speed("left", self.vel.x)
			self.facing = "left"
			self.state = STATE_RUN
		end
		if input == "nil" then
			self.vel.x = self.vel.x * self.world.decay
			if math.abs(self.vel.x) < 1 then
				self.state = STATE_IDLE
			end
		end
	elseif self.state == STATE_JUMP then
		if input == "space" then
			print(self.world.ground - self.jump_tolerance)
			if self.y >= ground - self.jump_tolerance then
				self.jump_tolerance_trigger = true
				print("tolerance jump")
			end
		end
		if input == "right" then
			self.vel.x = self:calculate_horizontal_speed("right", self.vel.x)
			self.facing = "right"
		end
		if input == "left" then
			self.vel.x = self:calculate_horizontal_speed("left", self.vel.x)
			self.facing = "left"
		end
		if input == "nil" then
			self.vel.x = self.vel.x * self.air_decay
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

	self.vel.y = self.vel.y + self.world.gravity * dt
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
	if self.y >= world.ground then
		self.y = world.ground
		self.vel.y = 500
		if math.abs(self.vel.x) > 1 then self.state = STATE_RUN else self.state = STATE_IDLE end
		if jump_tolerance_trigger then
			self:jump(self.jump_force)
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