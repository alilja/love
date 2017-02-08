function love.load()
	inspect = require('lib.inspect')

	player = {}
	player.x = 100
	player.y = 300

	vel = 0
	decay = 0.85
	acceleration = 50 -- pixels per second
	max_velocity = 600

	jump_force = -1050
	jump_cutoff = -300 -- if your speed is below this, you are fixed to this speed
					   -- basically, the lower this number, the sooner you are fixed
					   -- to a low jump
	jump_tolerance = 20 -- how far away from the ground can you be before you can
						-- trigger a jump again; the jump happens as soon as the character
						-- touches the ground

	reactivity_percent = 1.95 -- how quickly you start moving in the opposite direction

	jump_vel = 0
	gravity = 45

	is_jumping = false
	jump_tolerance_trigger = false

	-- how movement changes in the air
	air_accel_control = 2.2
	air_vel_control = 0.84
	air_reactivity = 0.6
	air_decay = 0.97

	combos = {}
	combo_time = 0
	max_combo_time = 0.5
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

function jump()
	jump_vel = jump_force
	is_jumping = true
	jump_tolerance_trigger = false
end

function love.keypressed(key)
	if key == "space" and not is_jumping then
		jump()
	elseif key == "space" and is_jumping then
		if player.y >= 300 - jump_tolerance then
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
	if #combos == 2 then
		if combos[1] == "a" then
			if combos[2] == "a" then
				return "double a"
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
	elseif #combos == 4 then
		if combos[1] == "a" then
			if combos[2] == "s" then
				if combos[3] == "a" then
					if combos[4] == "s" then
						return "asas"
					end
				end
			end
		end
	end
	return nil
end


function love.update(dt)
	if love.keyboard.isDown("right") then
		vel = calculate_horizontal_speed("right", vel)
	elseif love.keyboard.isDown("left") then
		vel = calculate_horizontal_speed("left", vel)
	else
		if is_jumping then
			vel = vel * air_decay
		else
			vel = vel * decay
		end
	end

	if next(combos) ~= nil then
		combo_time = combo_time + dt

		combo = check_combos(combos)
		if combo_time >= max_combo_time or combo ~= nil then
			print(combo)
			combos = {}
			combo_time = 0

			if combo == "double a" then
				vel = vel * 30
			elseif combo == "ass" then
				vel = 0
			elseif combo == "asas" then
				jump_vel = jump_vel - 2000
			end
		end
	end

	jump_vel = jump_vel + gravity
	if jump_vel > 500 then jump_vel = 500 end

	player.x = player.x + vel * dt
	player.y = player.y + jump_vel * dt
	if player.y >= 300 and is_jumping then
		love.timer.sleep(0.02)
	end
	if player.y >= 300 then
		player.y = 300
		jump_vel = 500
		is_jumping = false
		if jump_tolerance_trigger then
			jump()
		end
	end
end

function love.draw()
	love.graphics.rectangle("line", player.x, player.y, 50, 50)
	love.graphics.line(0, 351, love.graphics.getWidth(), 351)
end