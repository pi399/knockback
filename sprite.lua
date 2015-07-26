local Sprite={}
local love=love
local ipairs=ipairs

function Sprite.newSpriteField(filepath,xl,yl,i,dir)
	i=i or 1
	dir=dir or "down"
	local r
	if filepath and love.filesystem.isFile(filepath) then
		r=love.graphics.newImage(filepath)
		r:setFilter("nearest","nearest")
		return r,{[1]=r},xl/r:getWidth(),yl/r:getHeight()
	elseif filepath and love.filesystem.isDirectory(filepath) then
		r={}
		local items=love.filesystem.getDirectoryItems(filepath)
		for k,file in ipairs(items) do
			local i=love.graphics.newImage(filepath.."/"..file)
			i:setFilter("nearest","nearest")
			r[file]=i
		end
		local dr=r[dir..tostring(i)..".png"]
		return dr,r,xl/dr:getWidth(),yl/dr:getHeight()
	else
		r=love.graphics.newCanvas()
		r:setFilter("nearest","nearest")
		return r,{r},1,1
	end
end

return Sprite