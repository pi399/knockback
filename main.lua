require "TEsound"			local TEsound=TEsound
Moveable=require "moveable"	local Moveable=Moveable
World=require "world"		local World=World
local love=love
local ipairs=ipairs

local world,keys
local pausedtime,start
local debug,paused
local fonts

local function round(num) return math.floor(num+0.5) end

local function playtime() return math.floor(love.timer.getTime()-pausedtime-start) end

function love.load()
	world=World.loadFile("worlds/testworld",true)
	world:follow(world.player)
	love.graphics.setBackgroundColor(255,255,255)
	
	math.randomseed(os.time())
	debug,paused=false,false
	pausedtime,start=0,love.timer.getTime()
	fonts={}
	for _,v in ipairs(love.filesystem.getDirectoryItems("fonts")) do
		fonts[string.gsub(v,"%..+","")]=love.graphics.newFont("fonts/"..v)
	end
	keys=World.loadFile("controls") --loads controls, maybe should have a superclass for World which has the load function
end

function love.update(dt)
	world:update(dt)
	TEsound.cleanup()
end

local function pausedupdate(dt) pausedtime=pausedtime+dt end

function love.draw()
	world:draw()
	
	if debug then
		love.graphics.setColor(0,0,0)	love.graphics.setFont(fonts.oxygenmono)
		love.graphics.print(
			"world name: "..world.name..
			"\nx: "..round(world.player.x)..", y: "..round(world.player.y)..", ia: "..world.player.ia..
			"\ntx: "..round(world.tx)..", ty: "..round(world.ty)..
			"\nfps: "..love.timer.getFPS()..", debug: "..tostring(debug)..", paused: "..tostring(paused)..
			"\nplaytime: "..playtime().." seconds",10,10)
	end
end

local function pauseddraw()
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(fonts.oxygenmono)
	love.graphics.print("playtime: "..playtime().." seconds",10,10)
	love.graphics.setFont(fonts.futura)
	love.graphics.printf("GAME PAUSED",0,200,512,"center")
end

function love.keypressed(key)
	if key==keys.up then
		world.player.ay=world.player.ay-world.a
	elseif key==keys.down then
		world.player.ay=world.player.ay+world.a
	elseif key==keys.left then
		world.player.ax=world.player.ax-world.a
	elseif key==keys.right then
		world.player.ax=world.player.ax+world.a
	elseif key==keys.debug then
		debug=not debug
	elseif key==keys.pause then
		paused=not paused
		love.update,pausedupdate=pausedupdate,love.update
		love.draw,pauseddraw=pauseddraw,love.draw
        	if paused and world.music then
        		world.pauseMusic()
        	else world.resumeMusic() end
	elseif key==keys.quit then
		love.event.push("quit")
	end
end

function love.keyreleased(key)
	if key==keys.up then
		world.player.ay=0
	elseif key==keys.down then
		world.player.ay=0
	elseif key==keys.left then
		world.player.ax=0
	elseif key==keys.right then
		world.player.ax=0
	end
end