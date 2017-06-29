debug = true;
isAlive = true;
score = 0;
player = {x = love.graphics:getWidth()/2, y = 0, speed = 300, img = nil}
bgSpeed = 300;
stamp = 0;
carSpeed = 300;
highScore = 0;

-- Timers
-- We declare these here so we don't have to edit them multiple places
createEnemyTimerMax = 1.4
createEnemyTimer = createEnemyTimerMax

-- Image Storage
carImg = nil
carRImg = nil
bgImg = nil

-- Entity Storage
cars = {} -- array of current bullets being drawn and updated
carRs = {}
bgs = {}

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return 	x1 < x2+w2 and
				x2 < x1+w1 and
				y1 < y2+h2 and
				y2 < y1+h1
end

function love.load(arg)
	player.img = love.graphics.newImage("assets/player.png")
	carImg = love.graphics.newImage("assets/car.png")
	carRImg = love.graphics.newImage("assets/carR.png")
	bgImg = love.graphics.newImage("assets/road.png")
	bg1 = {y = -480}
	table.insert(bgs, bg1)
	bg2 = {y = 480}
	table.insert(bgs, bg2)
	bg3 = {y = -1440}
	table.insert(bgs, bg3)
	bg4 = {y = -2400}
	table.insert(bgs, bg4)
	bg5 = {y = 1440}
	table.insert(bgs, bg5)
end

function love.update(dt)
	if love.keyboard.isDown("escape") then --fast quit
		love.event.push("quit")
	end
	
	if love.keyboard.isDown("left", "a") then
		if player.x > 0 then --bounds the left side of the screen
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown("right", "d") then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then --bounds the right side of the screen
			player.x = player.x + (player.speed*dt)
		end
	end
	
	if love.keyboard.isDown("up", "w") then
		player.y = player.y - (bgSpeed*dt)
		if (isAlive) then score = score + 3 end
		for i, bg in ipairs(bgs) do
			bg.y = bg.y + (bgSpeed*dt)
		end
	end
	if love.keyboard.isDown("down", "s") then
		player.y = player.y + (bgSpeed*dt)
		if (isAlive) then score = score - 4 end
		for i, bg in ipairs(bgs) do
			bg.y = bg.y - (bgSpeed*dt)
		end
	end
	
	
	-- times enemy creation
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax
		
		-- and create an enemy
		randomNumber = math.random(1,2)
		randomY = math.random(player.y-260, player.y+260)
		if randomNumber == 1 then
			newCar = {x = 740, y = randomY, img = carImg}
			table.insert(cars, newCar)
		else
			newCar = {x = -100-carImg:getWidth(), y = randomY, img = carRImg}
			table.insert(carRs, newCar)
		end
	end
	
	-- update enemy positions
	for i, enemy in ipairs(cars) do
		enemy.x = enemy.x - (carSpeed*dt)
		
		if enemy.x < 0 - carImg:getWidth() then --remove enemies that pass off the screen
			table.remove(cars, i)
		end
	end
	for i, enemy in ipairs(carRs) do
		enemy.x = enemy.x + (carSpeed*dt)
		
		if enemy.x > 800 then --remove enemies that pass off the screen
			table.remove(carRs, i)
		end
	end
	
	-- collision detection running
	for i, enemy in ipairs(cars) do
		
			if CheckCollision(enemy.x, enemy.y-player.y, carImg:getWidth(), carImg:getHeight(), player.x+30, love.graphics:getWidth()/2-60, player.img:getWidth()-60, player.img:getHeight()-60)
			and isAlive then
				table.remove(cars, i)
				isAlive = false
				if highScore < score then highScore = score end
			end
	end
	for i, enemy in ipairs(carRs) do
		
			if CheckCollision(enemy.x, enemy.y-player.y, carImg:getWidth(), carImg:getHeight(), player.x+30, love.graphics:getWidth()/2-60, player.img:getWidth()-60, player.img:getHeight()-60)
			and isAlive then
				table.remove(carRs, i)
				isAlive = false
				if highScore < score then highScore = score end
			end
	end
	
	-- on a lighter note, here's the thing that's handling death
	if not isAlive and love.keyboard.isDown("r") then
		-- remove game elements
		
		for i, enemy in ipairs(cars) do
			table.remove(cars, i)
		end
		for i, enemy in ipairs(carRs) do
			table.remove(carRs, i)
		end
		
		bg1.y = -480
		bg2.y = 480
		bg3.y = -1440
		bg4.y = -2400
		bg5.y = 1400
		carSpeed = 300
		
		--reset timers
		createEnemyTimer = createEnemyTimerMax
		
		-- default position
		player.x = love.graphics:getWidth()/2
		player.y = 0
		
		--reset game state
		isAlive = true
		score = 0
	end
	
	if (isAlive) then score = score + 1 end
	
	if (stamp-player.y) >= 960 then --scrolled up to replace lowest bg
		for i, bg in ipairs(bgs) do
			bg.y = bg.y - 960
		end
		stamp = player.y
	end
	if (stamp-player.y) <= -960 then --scrolled down to replace highest bg
		for i, bg in ipairs(bgs) do
			bg.y = bg.y + 960
		end
		stamp = player.y
	end
	
	--faster ;)
	carSpeed = carSpeed + 0.3;
end

function love.draw(dt)
	for i, bg in ipairs(bgs) do
		love.graphics.draw(bgImg, 0, bg.y)
	end
	if isAlive then
		love.graphics.draw(player.img,player.x,love.graphics:getHeight()/2)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50,love.graphics:getHeight()/2-15)
		love.graphics.print("Score: " .. tostring(score), love.graphics:getWidth()/2-30,love.graphics:getHeight()/2)
	end
	
	for i, enemy in ipairs(cars) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y-player.y)
	end
	for i, enemy in ipairs(carRs) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y-player.y)
	end
	
	if debug then
		love.graphics.print("Score: " .. tostring(score), 10, 10)
		love.graphics.print("Alive: " .. tostring(isAlive), 10, 25)
		love.graphics.print("Car Speed: " .. tostring(carSpeed), 10, 40)
		love.graphics.print("HIGH: " .. tostring(highScore), 10, 55)
	end
	
end