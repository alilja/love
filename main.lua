function love.load()
	player = {}
	player.x = 100
	player.y = 300

	vel = 0
	decay = 0.75

	reactivity_percent = 1.95 -- how quickly you start moving in the opposite direction

	jump_vel = 0
	gravity = 11

	is_jumping = false

	air_accel_control = 1.7
	air_vel_control = 0.6
	air_reactivity = 0.3
end

function calculate_horizontal_speed(direction, time_since_press, velocity)
	max_velocity = 600
	reactivity = reactivity_percent
	acceleration = 80 -- pixels per second
	if is_jumping then
		acceleration = acceleration * air_accel_control
		reactivity = air_reactivity
	end
	if direction == "left" and velocity > 0 then -- moving right and press left
		print("condition 1")
		velocity = velocity - (acceleration + acceleration * reactivity_percent)
	elseif direction == "right" and velocity < 0 then -- moving left and press right
		print("condition 2")
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

function love.keypressed(key)
   if key == "space" then
   		jump_vel = -650
   end
end

function love.keyreleased(key)
   if key == "space" then
   		if jump_vel <= -400 then
   			jump_vel = -400
   		end
   end
end


function love.update(dt)
	if love.keyboard.isDown("right") then
		vel = calculate_horizontal_speed("right", right_key_down_time, vel)
	elseif love.keyboard.isDown("left") then
		vel = calculate_horizontal_speed("left", left_key_down_time, vel)
	else
		vel = vel * decay
	end

	jump_vel = jump_vel + gravity
	if jump_vel > 500 then jump_vel = 500 end

	print(jump_vel)
	player.x = player.x + vel * dt
	player.y = player.y + jump_vel * dt
	if player.y >= 300 then player.y = 300; is_jumping = false; jump_vel = 500 end
end

function love.draw()
	love.graphics.rectangle("line", player.x, player.y, 50, 50)
end