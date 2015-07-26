local Moveable={}
local Sprite=require "sprite"
local love=love
local ipairs=ipairs

	--[[arguments to Moveable.new are as follows (defaults, where applicable, are in [brackets]):
		world: the world table that includes the Moveable
		spritepath string:	path to an image or a folder of images. If it is a folder, the folder
							must contain files named in the format: directionindex.png e.g. "down1.png"
							if no valid path is provided, [love.graphics.newCanvas()] is used instead
		collidable boolean:	whether the Moveable can collide with other Moveables [false]
		moveable boolean:	whether the Moveable can move or not [false]
		x:	initial position on x axis [0]
		y:	initial position on y axis [0]
		xl:	length of the Moveable on x [1] (note that sprites automatically scale to this)
		yl:	length of the Moveable on y [1] (ditto)
		vx:	initial velocity on x axis [0]
		vy:	initial velocity on y axis [0]
		ax:	initial acceleration on x axis [0]
		ay:	initial acceleration on y axis [0]
		ia:	initial index for the animation [1] (e.g. if ia=2, then "down2.png" will be the first sprite for animation)
		dir: initial direction for the animation ["down"] (if dir="up", then "up1.png" will be used initially)
		ta: amount of time between animations [.1] ]]

function Moveable.new(world,spritepath,mc,mm,mx,my,mxl,myl,mvx,mvy,max,may,mia,mdir,mta)
	local sprite,sprites,mxscl,myscl=Sprite.newSpriteField(spritepath,mxl,myl,mia,mdir)
	
	local mc,mm,mx,my,mxl,myl,mxscl,myscl,mvx,mvy,max,may,mia,mdir,mta
			=	mc or false,mm or false,mx or 0,my or 0,mxl or 1,myl or 1,mxscl or 1,myscl or 1,
				mvx or 0,mvy or 0,max or 0,may or 0,mia or 1,mdir or "down",mta or .1
	local m={collidable=mc,moveable=mm,x=mx,y=my,cx=mcx,cy=mcy,xl=mxl,yl=myl,xscl=mxscl,yscl=myscl,vx=mvx,vy=mvy,ax=max,ay=may,
		world=world,xcollisioncount={},ycollisioncount={},ia=mia,ta=mta,cta=0,dir=mdir,pdir=dir,sprite=sprite,sprites=sprites}
	setmetatable(m,{__index=Moveable})
	world[#world+1]=m	--inserts the moveable into a new index in the world
	return m
end

function Moveable:nextSprite()
	self.sprite=self.sprites[self:currentDirection()..self.ia..".png"]
end

function Moveable:currentDirection()
	if self.ay>0 then pdir="down" return "down"
	elseif self.ay<0 then pdir="up" return "up"
	elseif self.ax>0 then pdir="right" return "right"
	elseif self.ax<0 then pdir="left" return "left"
	else return pdir or "down" end
end

function Moveable:update(dt)
	if self.moveable then
		self.vx=(self.vx+self.ax)*self.world.f
		self.vy=(self.vy+self.ay)*self.world.f	--(velocity+acceleration)*friction
		self.x=self.x+self.vx
		self.y=self.y+self.vy					--position+velocity
		
		if self:isMoving() then
			self.cta=self.cta+dt
			if self.cta>self.ta then
				if self.ia<=3 then
					self.ia=self.ia+1
				else
					self.ia=1
				end
				self:nextSprite()
				self.cta=self.cta-self.ta
			end
		else 
			self.ia=1
			self:nextSprite()
		end
		
		for i,ma in ipairs(self.world) do		--check object with all other objects in its world
			if self~=ma and self.vx and self.vy then	--only if it's moving and if it's not the same object as self
				local xcollision,ycollision=self:collidesWith(ma)	--checks basic axis collisions
				if self.xcollisioncount[ma]<2 and xcollision then self.xcollisioncount[ma]=self.xcollisioncount[ma]+1
					elseif not xcollision then self.xcollisioncount[ma]=0 end
				if self.ycollisioncount[ma]<2 and ycollision then self.ycollisioncount[ma]=self.ycollisioncount[ma]+1
					elseif not ycollision then self.ycollisioncount[ma]=0 end	--determines which axis has been colliding for longer
				if xcollision and ycollision
					then self:correctCollision(ma)	--corrects them if the objects have collided
				end
			end
		end
	end
end

function Moveable:draw()
	love.graphics.draw(self.sprite,self.x,self.y,0,self.xscl,self.yscl)
end

function Moveable:isAccelerating()
	return self.ax~=0 or self.ay~=0
end

function Moveable:collidesWith(ma)
	local xcollision,ycollision=self.collidable and ma.collidable and self.y<ma.y+ma.yl and self.y+self.yl>ma.y,
		self.collidable and ma.collidable and self.x<ma.x+ma.xl and self.x+self.xl>ma.x
	return xcollision,ycollision,xcollision and ycollision
end

function Moveable:overlapOnX(ma) return self.y+self.yl-ma.y end

function Moveable:overlapOnY(ma) return self.x+self.xl-ma.x end	--returns the overlap with other moveables

function Moveable:correctCollision(ma)
	if self.xcollisioncount[ma]<=self.ycollisioncount[ma] then self:correctXCollision(ma)
	elseif self.ycollisioncount[ma]<self.xcollisioncount[ma] then self:correctYCollision(ma)
	end
end

function Moveable:correctXCollision(ma)
	local overlap=self:overlapOnX(ma)
	if overlap>ma.yl then overlap=overlap-ma.yl-self.yl end
	self.y=self.y-overlap
	self.vy=0
	self.xcollisioncount[ma]=0
end

function Moveable:correctYCollision(ma)
	local overlap=self:overlapOnY(ma)
	if overlap>ma.xl then overlap=overlap-ma.xl-self.xl end
	self.x=self.x-overlap
	self.vx=0
	self.ycollisioncount[ma]=0
end

return Moveable