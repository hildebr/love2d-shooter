debug = true

--player stats
player = {x = 200, y = 510, speed = 150, img = nil}
isAlive = true
score = 0

--enemy stats
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
enemyImg = nil
enemies = {}

--bullet stats
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
bulletImg = nil
bullets = {}

--function to check for collision of bullets and planes
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

--load assets
function love.load(arg)
	player.img = love.graphics.newImage('assets/plane.png')
	bulletImg = love.graphics.newImage('assets/bullet.png')
	enemyImg = love.graphics.newImage('assets/enemy.png')
end

function love.update(dt)
  --allow the player to shoot after a while
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
  		canShoot = true
	end

--quit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

--movement
	if love.keyboard.isDown('left', 'a') then
		if player.x > 0 then
			player.x = player.x - (1.5*player.speed*dt)
		end
	elseif love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics:getWidth() - player.img:getWidth()) then
			player.x = player.x + (1.5*player.speed*dt)
		end
	end

--shooting
if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot and isAlive then
	newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
	table.insert(bullets, newBullet)
	canShoot = false
	canShootTimer = canShootTimerMax
end

--bullet movement and cleanup
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

  		if bullet.y < 0 then
			table.remove(bullets, i)
		end
	end

--enemy generator
	createEnemyTimer = createEnemyTimer - (1*dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = {x = randomNumber, y = -10, img = enemyImg}
		table.insert(enemies, newEnemy)
	end

--enemy movement and cleanup
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

		if enemy.y > 650 then
			table.remove(enemies, i)
		end
	end

--collision check
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
			bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 1
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y,
		 player.img:getWidth(), player.img:getHeight()) and isAlive then
			table.remove(enemies, i)
			isAlive = false
		end
	end

--reset game after dying
	if not isAlive and love.keyboard.isDown('r') then
		bullets = {}
		enemies = {}

		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		player.x = 50
		player.y = 510

		score = 0
		isAlive = true
	end
end

function love.draw(dt)
  --draw score
	love.graphics.print("Score = " .. score, 0, 0)

--draw player
	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

  --draw bullets
	for i, bullet in ipairs(bullets) do
  		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

--draw enemies
	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end
end