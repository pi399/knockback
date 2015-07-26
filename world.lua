local World={}
local Moveable=Moveable
local TEsound=TEsound
local love=love
local ipairs=ipairs

function World.loadFile(filepath,collisions) -- add a superseding library which is for files; this is its derivative
	w={}
	w.tx,w.ty=0,0
	
	t,f=true,false
	
	local file=love.filesystem.newFile(filepath)
	
	if assert(file:open("r"),filepath.." could not be opened.") then
		for line in file:lines() do
			local index=string.gsub(line,"=.+","")		--text before =
			local arguments=string.gsub(line,".+=","")	--text after =
			if string.sub(line,1,2)=="--" then
				--do nothing, this line is a comment
			elseif string.sub(line,1,1)=="~" then		-- a ~ means to load a Moveable object
				index=string.gsub(index,"~","",1)		--index without ~
				w[index]=assert(loadstring("return Moveable.new(w,"..arguments..")")(),
					"could not load line: "..line.." in file "..filepath)
			else
				local nargs=tonumber(arguments)
				if nargs then
					w[index]=nargs	--guarantees a number rather than a string is used
				else
					w[index]=arguments	--w[text before =] = everything after =
				end
			end
		end
	end
	local rw=w;w,t,f=nil,nil,nil
	setmetatable(rw,{__index=World})
	if collisions then rw:initializeCollisions() end
	return rw
end

function World:initializeCollisions()	--initializes the collision count tables, which determine which axis to correct in the event of a collision
	for i,ma in ipairs(self) do			
		for imi,imma in ipairs(self) do
			if type(imma)=="table" then
				ma.xcollisioncount[imma]=0
				ma.ycollisioncount[imma]=0
			end
		end
	end
end

function World:basicSprites(r,g,b)	--gives all the objects in the world basic rectangle sprites of a r,g,b color
	love.graphics.setColor(r or 0,g or 0,b or 0)	--default values if r,g,b values aren't provided
	for i,ma in ipairs(self) do
		if ma.sprite and ma.sprite:typeOf("Canvas") then
			love.graphics.setCanvas(ma.sprite)
			love.graphics.rectangle("fill",0,0,ma.xl,ma.yl)
		end
	end
	love.graphics.setCanvas()
end

function World:update(dt)
	for i,ma in ipairs(self) do
		ma:update(dt)
	end
	
	if self.follow then
		if self.follow.y+self.follow.yl+self.ty>=love.window.getHeight()-(self.downthreshold or self.threshold) and self.follow.vy>0 then
			self.ty=-(self.follow.y+self.follow.yl+(self.downthreshold or self.threshold)-love.window.getHeight())
		elseif self.follow.y+self.ty<=(self.upthreshold or self.threshold) and self.follow.vy<0 then
			self.ty=-(self.follow.y-(self.upthreshold or self.threshold))
		end
		
		if self.follow.x+self.follow.xl+self.tx>=love.window.getWidth()-(self.rightthreshold or self.threshold) and self.follow.vx>0 then
			self.tx=-(self.follow.x+self.follow.xl+(self.rightthreshold or self.threshold)-love.window.getWidth())
		elseif self.follow.x+self.tx<=(self.leftthreshold or self.threshold) and self.follow.vx<0 then
			self.tx=-(self.follow.x-(self.leftthreshold or self.threshold))
		end
	end
end

function World:draw()
	love.graphics.translate(self.tx,self.ty)
	love.graphics.setColor(255,255,255)
	for i,ma in ipairs(self) do	
		ma:draw()
	end
	love.graphics.translate(-self.tx,-self.ty)
end

function World:follow(ma)
	self.follow=ma
end


function World:playMusic() TEsound.playLooping(self.music,"world") end
function World:pauseMusic() TEsound.pause("world") end
function World:resumeMusic() TEsound.resume("world") end

return World