pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--wasabi

coin = 1000
fish = 100
veg = 100

max_capacity = 3

function _init()
	poke(0x5f5c,255)
	palt(0,false)
	palt(14,true)

	anim(cam,"x",xinput*24-56,180,out_quad)--reset camera
end

function _update60()
	update_controller()
 	guy:update()

	for b in all(blocks) do
		b:update()
	end

	if xinput != last_input then
		anim(cam,"x",xinput*24-56,300,out_quad)
	end
	update_object(cam)
	update_object(coin_l)

	for i = 1,3 do
		if (watering_anims[i]) watering_anims[i]:update()
	end

	for i = 1,3 do
		if (plots[i]) plots[i]:update()
	end

	charge_meter:update()

	for b in all(blocks) do
		update_object(b)
	end

	for l in all(label) do
		if guy.x >= l[1] and guy.x < l[2] and guy.y < l[3] and guy.y > l[3]-24 then
			current_label = l
			break
		end
		current_label = nil
	end
end

cam = {x = -248, a = {}}

trash = {y = 72, a = {}}

coin_l = {y = 5, a = {}, c = {8,7,11},cl = 2}

label = {{44,76,88,"go to shop","\|fX"},
	{76,84,88,"throw unwanted items here"},
	{108,124,88,"buy plot: -60","^"},
	{124,140,88,"buy plot: -60","^"},
	{140,156,88,"plant seed here","^"},
	{220,252,88,"wasabi"},
	{268,284,72,"store items here"},
	{284,300,72,"buy storage: -50","^"},
	{300,316,72,"buy storage: -50","^"},
	{332,348,88,"grab bait (7/15)","\|fX"},
	{356,372,88,"bring bait here to fish"}
}
current_label = nil

function _draw()
	local m = mid(0,cam.x+guy.x,312)
	camera(m)

	fillp(0x7fdf)
 	rectfill(m+0,0,m+127,127,0xc7)
	fillp(0xa5a5)

	local cl_off = m>>2
	draw_cloud(cl_off+16,28,90)
	draw_cloud(cl_off+32,24,60)

	draw_cloud(cl_off+130,34,42)
	draw_cloud(cl_off+142,30,18)
	draw_cloud(cl_off+146,38,18)

	draw_cloud(cl_off+208,28,75)
	draw_cloud(cl_off+224,24,45)

	local mo_off = m>>1
	draw_mountain(mo_off+24,5)
	draw_mountain(mo_off+88,5)
	draw_mountain(mo_off+152,7)

	for i = 1,3 do
		if (watering_anims[i]) watering_anims[i]:draw()
	end

	for i = 1,3 do
		if (plots[i]) plots[i]:draw()
	end

	charge_meter:draw()

	map(0,0,0,0,64,16)

	spr(111, 80, trash.y, 1, 2)--trash can

	guy:draw()

	for b in all(blocks) do
		b:draw()
	end
	
	--print(m,m,0,0)
	print(stat(1),m,0,0)
	print("fish: "..fish)
	print("veg: "..veg)
	print("coin: "..coin,m+89,coin_l.y-1,0)
	print("coin: "..coin,m+91,coin_l.y+1,0)
	print("coin: "..coin,m+90,coin_l.y,coin_l.c[coin_l.cl&0x7fff])

	if current_label then 
		printc(current_label[4],m+64,116,7)
		if #current_label > 4 then 
			button:draw(current_label[5],m)
		end
	end

	--[[for l in all(label) do
		rect(4+l[1],l[3]-24,3+l[2],l[3],11)
	end]]
end

button = {
	x = 57,
	y = 98,
	c = 9,
	t = 0,
	draw = function(self,letter,m)
		self.t = (self.t+1)%60
		if self.t >= 30 then
			pal(9,(letter == "^" and 12 or 8))
			spr(115,self.x+m,self.y,2,1)
			print(letter,self.x+6+m,self.y+3,7)
			pal(9,9)
		else
			spr(115,self.x+m,self.y+2,2,1)
			print(letter,self.x+6+m,self.y+5,7)
		end
		spr(113,self.x+m,self.y+7,2,1)

	end
}

function draw_cloud(x1,y1,w)
	for i = 1,w,6 do
		spr(102,x1+i,y1)
		spr(102,x1+i,y1+2)
	end
end

function draw_mountain(x,s)
	for i = 0, s-1 do
		spr(103,x+i*8,105-i*8)
		spr(103,x+s*16-i*8-7,105-i*8,1,1,true)
		for j = 1, s-1-i do
			spr(104,x+j*8+i*8,105-i*8)
			spr(104,x+s*16-j*8-i*8-7,105-i*8,1,1,true)
		end
	end
	fillp(0x0f0f)
	poke(0x5f33,1)
	line(x+s*8,105-s*8+8,x+s*8,112,0xef)
	fillp()
end

blocks = {}
block = {state = 0, t = 0}
function block:new(x,y,c,s,f,i)
	local obj = {
		x = x,
		y = y,
		c = c,
		s = s,
		f = f,
		i = i,
		a = {},
		base = self
	}
	add(blocks,obj)
	return setmetatable(obj, {__index = self})
end

function block:update()

end

function block:on_hit(g)
	g.vy *= -1
	anim(self,"y",self.y-4,5,linear,1,1)
	self:f(g)
end

function block:draw()
	pal(8,self.c)
	spr(112,self.x,self.y)
	if type(self.s) == "string" then
		print(self.s,self.x+2,self.y+1,7)
	end
	pal(8,8)
end

water_plot = function(self,g)
	if (not watering_anims[self.i]) watering_anim:new(self.x,self.i) plots[self.i]:water()
end

buy_plot = function(self,g)
	if make_purchase(60) then
		self.c = 12
		self.f = water_plot
		self.s = "W"
		plot:new(self.x, self.i)
		label[2+self.i][4] = "plant seed here"
		label[2+self.i][5] = nil
	else

	end
	return
end

store_item = function(self)

end

buy_storage = function(self)
	if make_purchase(50) then
		self.c = 11
		self.f = store_item
		self.s = "E"
		label[6+self.i][4] = "store items here"
		label[6+self.i][5] = nil
	end
end

plots = {}
plot = {thirst = 0, growth = 0}
function plot:new(x,i,p)
	local obj = {
		x = x,
		i = i,
		plant = p or nil,
		s = 118,
		base = self
	}
	plots[i] = obj
	return setmetatable(obj, {__index = self})
end

function plot:update()
	if self.plant and self.growth < 100 then
		self.growth = min(100,self.growth+0.11-self.thirst/1000)
		self.thirst = min(100, self.thirst+0.2)
	end
	local g_int = self.growth&0x7fff
	if g_int == 35 then
		self.s = 119
	elseif g_int == 65 then
		self.s = 120
	elseif g_int == 100 then
		self.s = 105
	end
end

function plot:draw()
	if (not self.plant) return
	if self.growth < 100 then
		spr(self.s,self.x, 80)
	else
		spr(self.s,self.x,72,1,2)
	end
	print(self.thirst.." "..self.growth,self.x, 20,0)
end

function plot:water()
	self.thirst = 0
end

plot:new(148,3,"raddish")

block:new(116,55,10,"B",buy_plot,1)
block:new(132,55,10,"B",buy_plot,2)
block:new(148,55,12,"W",water_plot,3)

spawn_customer = function(self)
	if (self.s == "0") return
	charge_meter.t -= 100
	self.s = tostr(tonum(self.s)-1)
	self.c = (self.s == "0" and 8 or 10)
end

spawn_block = block:new(180,39,8,"0",spawn_customer)
function spawn_block:inc()
	if (tonum(self.s) != max_capacity) self.s = tostr(tonum(self.s)+1)
	self.c = (tonum(self.s) != max_capacity and 10 or 11)
end



block:new(276,39,11,"E",store_item,1)
block:new(292,39,10,"B",buy_storage,2)
block:new(308,39,10,"B",buy_storage,3)

watering_anims = {}
watering_anim = {}
function watering_anim:new(x,i)
	local obj = {
		x = x,
		t = 0,
		s = {},
		i = i,
		base = self
	}
	watering_anims[i] = obj
	return setmetatable(obj, {__index = self})
end


function watering_anim:update()
	if self.t%4 == 0 then
		add(self.s,{x = rnd(8)+self.x, y = 63, v = 0.1})
	end
	for ds in all(self.s) do
		ds.y += ds.v
		ds.v += 0.1
	end
	self.t += 1
	if self.t == 240 then
		watering_anims[self.i] = nil
	end
end

function watering_anim:draw()
	for ds in all(self.s) do
		pset(ds.x,ds.y,1)
	end
	print(self.t,self.x,self.y,0)
end

charge_meter = {
	x = 212,
	y = 59,
	t = 0
}

function charge_meter:update()
	self.t = min(self.t+1,100*max_capacity)
	if self.t%100 == 0 then
		spawn_block:inc()
	end
end

function charge_meter:draw()
	line(self.x,self.y-10,self.x,self.y,7)
	line(self.x,self.y-((self.t-1)%100)/10,self.x,self.y,(self.t == 100*max_capacity and 11 or 8))
	rect(self.x-1,self.y-11,self.x+1,self.y,0)
	--print(self.t,self.x,self.y-18,0)
end

guy = {
	x = 248,
	y = 60,
	s = 1,
	f = false,
	vx = 0,
	vy = 0,
	remainder_x = 0,
	remainder_y = 0,
	a = {},
	t = 0
}

function guy:move_x(x)
	self.remainder_x += x
	local mx = flr(self.remainder_x + 0.5)
	self.remainder_x -= mx
	
	local total = mx
	local mxs = sgn(mx)
	while mx != 0 do
		if self:check_solid(mxs, 0) then
			return true
		else
			self.x += mxs
			mx -= mxs
		end
	end

	return false
end

function guy:move_y(y)
	self.remainder_y += y
	local my = flr(self.remainder_y + 0.5)
	self.remainder_y -= my
	
	local total = my
	local mys = sgn(my)
	while my != 0 do
		if self:check_solid(0, mys) then
			return true
		else
			self.y += mys
			my -= mys
		end
	end

	return false
end

function guy:check_solid(ox,oy)
	ox = ox or 0
	oy = oy or 0

	for i = (ox + self.x+3)>>3&0x8fff,(ox + self.x + 11)>>3&0x8fff do
		local y = (oy+self.y+14)>>3
		local j = y&0x7fff
		if fget(mget(i, j), 0) and j == y and self.vy >= 0 then
			return true
		end
	end

	if mid(30,ox+self.x,372) != ox + self.x then
		return true
	end
	--checks objects for solidity
	for b in all(blocks) do
		if self:overlaps(b, ox, oy) then
			return true
		end
	end

	return false
end

function guy:overlaps(b, ox, oy)
    if self == b then return false end
    ox = ox or 0
    oy = oy or 0
	if (oy + self.y + 3 == b.y + 8 and ox + self.x + 11 > b.x and ox + self.x + 3 < b.x + 8 and oy == -1) b:on_hit(self)
    return
        ox + self.x + 11 > b.x and
        oy + self.y + 14 > b.y and
        ox + self.x + 3 < b.x + 8 and
        oy + self.y + 4 < b.y + 8
end


function guy:update()
	local on_ground = self:check_solid(0,1)
	self.t += 1
	if self.t == 30 then
		self.s = 3
	elseif self.t == 60 then
		self.s = 1
		self.t = 0
	end
	if xinput != 0 then --walking around
		self.vx = xinput*0.8
		self.f = (xinput == -1)
	elseif self.vx != 0 then --slow to stop
		self.vx = approach(self.vx, 0, 0.1)
	end
	
	if not on_ground then
		self.vy = min(self.vy + 0.06, 4.4) 
	else
		self.vy = 0
	end

	if on_ground and btnp(2) then
		self.vy = -1.6
	end

	self:move_x(self.vx)
	self:move_y(self.vy)

	
end

function make_purchase(g)
	if coin >= g then
		coin -= g
		anim(coin_l,"y",coin_l.y-3,6,linear,1,1)
		anim(coin_l,"cl",4,6,linear,1,1)
		return true
	end

	anim(coin_l,"y",coin_l.y-3,6,linear,1,1)
	anim(coin_l,"cl",1,6,linear,1,1)
	return false
end

function guy:draw()
	spr(self.s,self.x,self.y,1.75,2,self.f)
	--print(self:check_solid(0,1),self.x,self.y-8,0)
	--print(self.vy,56,self.y-8,0)
end

last_input = 0
xinput = 0

function update_controller()
	last_input = xinput
	xinput = 0
	if btn(0) then
		xinput -= 1
	end
	if btn(1) then
	 xinput +=1
	end
end

function approach(x, target, max_delta)
	return x < target and min(x + max_delta, target) or max(x - max_delta, target)
end

function printc(string,x,y,c)
	print(string,x-(#string<<1),y,c)
end

-- animation module
-- by efofeckss

function anim(obj,p,to,d,f,rep,rev)
-- start an animation for object obj

	local f, rep, rev = f or linear, rep or 1, rev or 0
	local b = obj[p]
    -- p: paramter ie "x", "y", "spr"
	obj.a[p] = {
		b=b, -- (b)egin value of parameter
		c=to-b, -- (c)hange of the paramter
  t=0, -- current (t)ime of the animation
  d=d, -- total anim (d)uration, in frames
		f=f, -- interpolation (f)unction, default linear
		rep=rep, -- how many times to (rep)eat (default 1); -1 = forever
		rev=rev -- 1 = if will be (rev)ersed after the animation, 0 = no
	}
end

function update_object(obj)
-- goes through all objects and adjusts its paramters
-- depending on the animation queue it has
	for p,a in pairs(obj.a) do
		a.t += 1
		obj[p]=a.f(a.t,a.b,a.c,a.d)
		if a.t==a.d then
			if (a.rep>0 and a.rev!=1) a.rep -= 1 -- reduce reps by 1
			if a.rep==0 then 
				obj.a[p]=nil --kill object if no more reps
			elseif a.rev==0 then 
				a.t=0 -- reset time to zero, or
			else 
				anim(obj, p, a.b, a.d, a.f, a.rep, -a.rev) --play reverse anim
			end 
		end
	end 
end

function out_quad(t, b, c, d)
    t /= d
    return -c * t * (t - 2) + b
end

function linear(t, b, c, d)
 return c * t / d + b
end
__gfx__
00000000eeeeeeeee0eeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeee080eeeeeeeeeeeeee0eeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700eeee00008800eeeeeeeeeeee080eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000eee088888880eeeeeeee00008800eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000eee08ffffff0eeeeeee088888880eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700ee0f8f0ff0f0eeeeeee08ffffff0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee0f8ffffff0eeeeee0f8f0ff0f0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee0ff0000f0eeeeee0f8ffffff0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee00fffff0eeeeeeee0ff0000f0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee0777b7b770eeeeeee00fffff0eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e0707777b7070eeeee0777b7b770eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e0f077b7b700f0eee0707777b70700ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00e0ccccc0e00ee0f0077b7b700f0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee00c000c0eeeeee00e0cccccc00eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee0b0ee0b0eeeeeeee0b00000b0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee00eee000eeeeeeee00eeee000eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee000000000000000000000007bbbbbbbbbbbbbbbbbbbb70eee065555555555555560eeecccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefbbbbbbbbbbbbbbf
e0777777777777777709990907bbbbbbbbbbbbbbbbbbbb70eee07ffffffffffffff70eeecccccccc00eeeeeeeeeee00eeeeeeeeeeeeeeeeebffffffffffffffd
077bbbbbbbbbbbbbbbb0000007bbbbbbbbbbbbbbbbbbbb70eee07ffffffffffffff70eeecccccc7c080000000000080ee00000000000000ebfbbbbbbbbbbbb5d
07bbbbbbbbbbbbbbbbbbbb7007bbbbbbbbbbbbbbbbbbbb70eee07ffffffffffffff70eeecccccccce0888888888880ee0077777777777700bfb5bbbbbbbb5b5d
07bbbbbbbbbbbbbbbbbbbb7007bbbbbbbbbbbbbbbbbbbb70eee07ffffffffffffff70eeeccccccccee08000800080eee0766666666666670bfbbbbbbbbbbbb5d
07bbbbbbbbbbbbbbbbbbbb7007bbbbbbbbbbbbbbbbbbbb700ee00ff00ff00ff00ff00ee0c7ccccccee080e080e080eee0766660000666670bfbbbbbbbbbbbb5d
07bbbbbbbbbbbbbbbbbbbb70077777777777777777777770700770077007700770077007cccccccce0080008000800ee000000aaaa000000bfbbbbbbbbbbbb5d
07bbbbbbbbbbbbbbbbbbbb70000000000000000000000000c77cc77cc77cc77cc77cc77ccccccccce0888888888880ee005550aaa7055500bfbbbbbbbbbbbb5d
e00000000000000e00000000000000ee000000000000000000000000077777777777777777777770e0080000000800eee07777000077770ebfbbbbbbbbbbbb5d
007777777777770090990990990990ee705565555555565555556507000000000000000000000000ee080eeeee080eeee07777777777770ebfbbbbbbbbbbbb5d
07bbbbbbbbbbbb7000000000000000eeb3005555560000055655503bee09999999999999999990eeee080eeeee080eeee04447744744470ebfbbbbbbbbbbbb5d
07bbbbbbbbbbbb70eee00eeeeeeeeeeebb33000000333330000003bbee0ffffffffffffffffff0eeee080eeeee080eeee07477477744770ebfbbbbbbbbbbbb5d
07bbbbbbbbbbbb70ee00eeeeeeeeeeeebbbb333333bbbbb333333bbbee00000000000000000000eeee080eeeee080eeee07477477747770ebfb5bbbbbbbb5b5d
07bbbbbbbbbbbb70e00eeeeeeeeeeeeebbbbbbbbbbbbbbbbbbbbbbbbee0dddddddddddddddddd0eeee080eeeee080eeee04447744774470ebfbbbbbbbbbbbb5d
07bbbbbbbbbbbb7000eeeeeeeeeeeeeebbbbbbbbbbbbbbbbbbbbbbbbeee000000000000000000eeeee080eeeee080eeee07777777777770ebf5555555555555d
07bbbbbbbbbbbb700eeeeeeeeeeeeeeebbbbbbbbbbbbbbbbbbbbbbbbeee0ffffffffffffffff0eeeee080eeeee080eeee05555555555550efddddddddddddddd
044444444444444deeeee00000000000eeeeeeee000eeeeeee0000000000000000000000000000eeee3ee3eeee00eeeeeeee00ee00eeeeeee11eeeee00000000
d4ddddddddddddd4eeee099999999999eeeeeeee9990eeeeeee06666666666666666666666660eeeee0330eee0aa0eeeeee03300330eeeeee11eeeee00000000
d4000000000000d4eee0999999999999eeeeeeee99990eeeeee07766666666666666666666770eeee083380e0a7790eeeee011157330eeee1771eeee00000000
d4000000000000d4eee0999999999999eeeeeeee99990eeeeee07667767676677676767776670eee088883800a7a90eeee0115777770eeee1cc1eeee00000000
d4000000000000d4eee0999999999999eeeeeeee99990eeeeee06676667676766676766766660eee028888200a7a90eee0155777000eeeee1cc1eeee00000000
d4000000000000d4ee099999999999990ee00ee0999990eeeee06666767676667677766766660eee022882200aaa90ee05055700eeeeeeeee11eeeee00000000
d4000000000000d4ee0fffffffffffff70077007fffff0eeeee07677666776776676767776670eeee022220ee0990eee05557030eeeeeeeeeeeeeeee00000000
d4000000000000d4ee0fffffffffffffc77cc77cfffff0eeeee07766666666666666666666770eeeee0000eeee00eeeee000000eeeeeeeeeeeeeeeee00000000
d41111ddddddddd4ee0000000000000000000000000000eeeee07777777777777777777777770eeee00eeeeeeee00eeeeeeeeeee00eeeeee0000000000000000
d41111ddddddddd4eee06666666666666666666666660eeeeee06666666666666666666666660eee0550eeeee0e0b0eeeeee0000d30eeeee0000000000000000
d4111dddddddddd4eee07777744444444444444477770eeeeee06666666600000000066666660eee0560eeee0a0bb0eeeee03c3c7c30eeee0000000000000000
d4225555555555d4eee07777447747474477447747770eeeeee06666666044440444406666660eee0560eeeee0a00eeeee03cc7776d0eeee0000000000000000
d4225555555555d4eee04444474447474747474744440eeeeee06666666044440444406666660eee0550eeeeee0eeeeee03c7676000eeeee0000000000000000
d4dd4444444445d4eee04444444747774747477744440eeeeee066666660444a0a44406666660eeee00eeeeeeeeeeeee0c0cd600eeeeeeee0000000000000000
d4d44444444445d4eee07777477447474774474447770eeeeee06666666044440444406666660eeeee0eeeeeeeeeeeee0cccd030eeeeeeee0000000000000000
d4ddddddddddddd4eee07777744444444444444477770eeeeee06666666044440444406666660eeeeeeeeeeeeeeeeeeee000000eeeeeeeee0000000000000000
eee0000000000eeeeee07777777777777777777777770eeeee7e7e7eeeeeeeefefefefefe00e00eeee00eeeee0000eeeeeeee0ee00eeeeee00000000eeeeeeee
ee077777777770eeeee04444444444444444444444440eeee7e7e7e7eeeeeefefefefefe0330330ee0000eee033300eeeeee0d0010eeeeee00000000eeeeeeee
ee060066660060eeeee04444444400000000044444440eee7e7e7e7eeeeeefefefefefefe03330ee033330ee0335330eeee011117000eeee00000000eeeeeeee
ee006600006600eeeee04444444011111111104444440eeee7e7e7e7eeeefefefefefefeee030eeee0330eeee0b3030eee011dd7ff10eeee00000000eeeeeeee
ee0d00dddd00d0eeeee04444444011111111104444440eee7e7e7e7eeeefefefefefefefee030eeeee00eeee0533030ee011f77f000eeeee00000000ee0e00ee
ee06d666666d60eeeee04444444011111111104444440eeee7e7e7e7eefefefefefefefee00300eee0990eee0333030e010f5700eeeeeeee00000000e050770e
ee06d666666d60eeeee04444444011111111104444440eee7e7e7e7eefefefefefefefef0667770e0d9dd0ee037370ee07ff70d0eeeeeeee00000000e000000e
ee0dddddddddd0eeeee04444444011111111104444440eeee7e7e7eefefefefefefefefe0777660e099990eee0b030eee000000eeeeeeeee0000000007777770
00000000e13eeeeeeeee31eeeeee9999999eeeee00000000eeeeeeeeeeeeeeeeeeeeeeee0777770e09dd90eee0bb0eeeeeee00ee00eeeeee0000000007567560
08888880e1133333333311eeeee997777799eeee00000000eeeeeeeeeeeeeeeeeeeeeeee0667770ee0990eeee0770eeeeee04400440eeeee0000000007567560
08888880e1111111111111eeeee979999979eeee00000000eeeeeeeeeeeeeeeeee00e00ee07760eee0dd0eeeee070eeeeee088888440eeee0000000007567560
08888880ee11111111111eeeeee999999999eeee00000000eeeeeeeeeeeeeeeee0330330ee000eeeee00eeeeee00eeeeee08844f7740eeee0000000007567560
08888880eeeeeeeeeeeeeeeeeee999999999eeee00000000eeeeeeeeeeeeeeeeee03330eeeeeeeeeeeeeeeeeeeeeeeeee088f477000eeeee0000000007567560
08888880eeeeeeeeeeeeeeeeeee999999999eeee00000000eeeeeeeeeee0e0eeeee030eeeeeeeeeeeeeeeeeeeeeeeeee0f0ff700440eeeee0000000007567560
08888880eeeeeeeeeeeeeeeeeee999999999eeee00000000eee00eeeee03030eeee030eeeeeeeeeeeeeeeeeeeeeeeeee0fff704000eeeeee0000000006666660
00000000eeeeeeeeeeeeeeeeeee999999999eeee00000000ee0440eeeee030eeeee030eeeeeeeeeeeeeeeeeeeeeeeeeee000000eeeeeeeee00000000e055550e
__gff__
0000000000000000000000000000000000000000000000000000000000000000010101000000000000000000000000000101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002a2b000000000000000000002c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004243434500000000000000000000000000003a3b000042434345000000003c3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005253545500000000000000000000000030212131000046474849000030212121213100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000006263646500000000000000000000000037383839000056575859000037383838383900006061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000020212121212121212121343535353536212121212121212121212121212121212121212121212121212232330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000023242424242424242424242424242424242424242424242424242424242424242424242424242424242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444426272727272727272727272727272727272727272727272727272727272727272727272727272727272844444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
