function love.conf(t)
	t.identity="knockback"
	t.version="0.9.1"
	
	t.window.title="Knockback"
	t.window.width=512
	t.window.height=512
	
	t.window.vsync=true
	
	t.modules.joystick=false
	t.modules.physics=false
end
