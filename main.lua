local inspect = require 'lib.inspect'
local anim8 = require 'lib.anim8'

local image, animation

function love.load()
	love.window.setMode(1216, 760, {})
	love.graphics.setBackgroundColor(89, 86, 82)
	love.graphics.setDefaultFilter("nearest")


	idle_image = love.graphics.newImage('images/an-1x/idle.png')
	local g = anim8.newGrid(32, 32, idle_image:getWidth(), idle_image:getHeight())
	idle_animation = anim8.newAnimation(g('1-5',1), 0.1)

	-- do the same for left and right facing

	right_run_image = love.graphics.newImage('images/an-1x/run.png')
	local g = anim8.newGrid(32, 32, right_run_image:getWidth(), right_run_image:getHeight())
	right_run_animation = anim8.newAnimation(g('1-8',1), 0.1):flipH()

	left_run_image = love.graphics.newImage('images/an-1x/run.png')
	local g = anim8.newGrid(32, 32, left_run_image:getWidth(), left_run_image:getHeight())
	left_run_animation = anim8.newAnimation(g('1-8',1), 0.1)


	animation = idle_animation
	image = idle_image







	player = {}
	player.x = 100
	player.y = 300
	player.height = 64
	player.width = 64

	vel = 0
	decay = 0.74
	acceleration = 80 -- pixels per second
	max_velocity = 400

	jump_force = -1250
	jump_cutoff = -400 -- if your speed is below this, you are fixed to this speed
					   -- basically, the lower this number, the sooner you are fixed
					   -- to a low jump
	jump_tolerance = 20 -- how far away from the ground can you be before you can
						-- trigger a jump again; the jump happens as soon as the character
						-- touches the ground

	reactivity_percent = 1.95 -- how quickly you start moving in the opposite direction

	jump_vel = 0
	gravity = 60
	hang_time = 0
	max_hang_time = 0.5

	is_jumping = false
	jump_tolerance_trigger = false

	-- how movement changes in the air
	air_accel_control = 2.2
	air_vel_control = 0.9
	air_reactivity = 0.6
	air_decay = 0.94

	combos = {}
	combo_time = 0
	max_combo_time = 0.5

	ground = love.graphics.getHeight() - 150

	facing = "left"
end

function calculate_horizontal_speed(direction, velocity)
	reactivity = reactivity_percent
	if is_jumping then
		acceleration = acceleration * air_accel_control
		reactivity = air_reactivity
	end
	if direction == "left" and velocity > 0 then -- moving right and press left
		velocity = velocity - (acceleration + acceleration * reactivity_percent)
	elseif direction == "right" and velocity < 0 then -- moving left and press right
		velocity = velocity + (acceleration + acceleration * reactivity_percent)
	elseif direction == "left" then
		velocity = velocity - acceleration
	elseif direction == "right" then
		velocity = velocity + acceleration
	end

	if velocity > max_velocity then velocity = max_velocity end -- cap
	if velocity < -max_velocity then velocity = -max_velocity end -- cap

	if is_jumping then velocity = velocity * air_vel_control end
	return velocity
end

function jump(force)
	jump_vel = jump_force
	is_jumping = true
	jump_tolerance_trigger = false
end

function love.keypressed(key)
	if key == "space" and not is_jumping then
		jump()
	elseif key == "space" and is_jumping then
		if player.y >= ground - jump_tolerance then
			jump_tolerance_trigger = true
			print("tolerance jump")
		end
	end
	if key == "a" then
		print("a pressed")
		table.insert(combos, "a")
	end
	if key == "s" then
		print("s pressed")
		table.insert(combos, "s")
	end
end

function love.keyreleased(key)
   if key == "space" then
   		if jump_vel <= jump_cutoff then
   			jump_vel = jump_cutoff
   		end
   end
end

function check_combos(combos)
	if #combos == 4 then
		if combos[1] == "a" then
			if combos[2] == "s" then
				if combos[3] == "a" then
					if combos[4] == "s" then
						return "asas"
					end
				end
			end
		end
	elseif #combos == 3 then
		if combos[1] == "a" then
			if combos[2] == "s" then
				if combos[3] == "s" then
					return "ass"
				end
			end
		end
	elseif #combos == 2 then
		if combos[1] == "a" then
			if combos[2] == "a" then
				return "double a"
			end
		end
	end
	return nil
end


function love.update(dt)

	if love.keyboard.isDown("right") then
		vel = calculate_horizontal_speed("right", vel)

		animation = right_run_animation
		image = right_run_image
	elseif love.keyboard.isDown("left") then
		vel = calculate_horizontal_speed("left", vel)

		animation = left_run_animation
		image = left_run_image
	else
		if is_jumping then
			vel = vel * air_decay
		else
			vel = vel * decay
		end
	end


	if math.abs(vel) < 0.1 then
		animation = idle_animation
		image = idle_image
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
				if is_jumping then distance = distance * 1.5 end
				if love.keyboard.isDown("right") then
					--vel = vel + impulse
					player.x = player.x + distance
				end
				if love.keyboard.isDown("left") then
					--vel = vel - impulse
					player.x = player.x - distance
				end
				if love.keyboard.isDown("up") then
					--jump_vel = jump_vel - impulse/15
					player.y = player.y - distance/2
					max_hang_time = 0.3
				end
				if love.keyboard.isDown("down") then
					--jump_vel = jump_vel - impulse/15
					player.y = player.y + distance/2
					if player.y >= ground then player.y = ground end
				end
			elseif combo == "ass" then
				vel = 0
			elseif combo == "asas" then
				jump_vel = jump_vel - 2000
				is_jumping = true
			end
		end
	end

	jump_vel = jump_vel + gravity
	if jump_vel > 500 then jump_vel = 500 end
	if jump_vel > 0 then
		-- we're falling, change animations as needed
	end
	if hang_time > max_hang_time then
		hang_time = 0
		max_hang_time = 0
	elseif max_hang_time > 0 then
		jump_vel = 0
		hang_time = hang_time + dt
	end

	player.x = player.x + vel * dt
	player.y = player.y + jump_vel * dt

	if player.y >= ground then
		player.y = ground
		jump_vel = 500
		is_jumping = false
		if jump_tolerance_trigger then
			jump()
		end
	end

	if player.x > love.graphics.getWidth() then player.x = 0 end
	if player.x < 0 then player.x = love.graphics.getWidth() end

	animation:update(dt)
end

function love.draw()
	animation:draw(image, player.x, player.y, 0, 2, 2)
	love.graphics.line(0, ground + player.height + 1, love.graphics.getWidth(), ground + player.height + 1)
end