pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
p = {{x=32,y=5,xv=0, yv=0, 
 hrot=.375,hrotv=0,near=0,far=2.125,fov=.12}}
--near -> ground curvature
 --far -> height?
 --fov -> viewing angle
 map_bounds_x = 128
map_bounds_y = 64

scale = -8

guys = {}
guy = {
	x = 0,
	y = 0,
	dist = 0,
	scx = 0,
	scy = 0}

function guy:new(x,y)
	local obj = {
		x = x,
		y = y,
		talkable = false,
		base = self
	}
	add(guys,obj)
	return setmetatable(obj, {__index = self})
end

function guy:draw(pn)
	local near, far, fov =
		 p[pn].near, p[pn].far, p[pn].fov
	local size = (far+1.4-near)*cos(fov)/(self.dist-near*cos(fov))+0.1
	local width = 16*size
	local height = 32*size
		sspr(16,0,16,32,self.scx-0.5*width,self.scy-height+2,width,height)
	if self.talkable then
	 sspr(0,24,8,8,self.scx-0.25*width,self.scy-height*1.2,size*8,size*8)
	end
end

function _init()
	palt(0,false)
	palt(14,true)
	pal(7,-14,1)
	poke(0x5f5c,-1)

	guy:new(32,1)
	guy:new(32,4)
	guy:new(30,2)
	guy:new(38,3)
	guy:new(28,7)
	guy:new(30,6)
	guy:new(35,2)
	
	p[1].x = -cos(p[1].hrot)*3 + px
	p[1].y = -sin(p[1].hrot)*3 + py
end

function _update60()
	--controls + debug
	--[[
	if btn(4) and btn(5) then
		--if (btn(2)) hz += 1/16
		--if (btn(3)) hz -= 1/16
	elseif btn(❎) then --x
		--if (btn(⬆️)) scale_y += 1
		--if (btn(⬇️)) scale_y -= 1
		--if (btn(⬅️)) scale_x -= 1
		--if (btn(➡️)) scale_x += 1
	elseif btn(🅾️) then --z
		if (btn(⬆️)) p[1].fov +=  1/256 
		if (btn(⬇️)) p[1].fov -=  1/256
		if (btn(⬅️)) p[1].near += 1/32
		if (btn(➡️)) p[1].near -= 1/32
	else

		if btn(⬆️) then
			p[1].xv += cos(p[1].hrot)*.05
			p[1].yv += sin(p[1].hrot)*.05
		end
		if btn(⬇️) then
			p[1].xv -= cos(p[1].hrot)*.05
			p[1].yv -= sin(p[1].hrot)*.05
		end
		if (btn(⬅️))p[1].hrotv -= 0.002--1/5
		if (btn(➡️))p[1].hrotv += 0.002--1/5
	end
	--mset(p[1].x-cos(p[1].hrot)*p[1].far*1.45,p[1].y-sin(p[1].hrot)*p[1].far*1.45,17)
	--player character collision
	local fx = p[1].x+cos(p[1].hrot+p[1].hrotv)*p[1].far*1.45 + p[1].xv
	local fy = p[1].y+sin(p[1].hrot+p[1].hrotv)*p[1].far*1.45 + p[1].yv
	if fx < 0 or fx >= 128 or fget(mget(fx,p[1].y+sin(p[1].hrot)*p[1].far*1.45),0) then p[1].hrotv = 0 p[1].xv = 0 end
	if fy < 0 or fy >= 64 or fget(mget(p[1].x+cos(p[1].hrot)*p[1].far*1.45,fy),0) then p[1].hrotv = 0 p[1].yv = 0 end
	--player motion
	p[1].x += p[1].xv
	p[1].y += p[1].yv
	p[1].hrot = norm_angle(p[1].hrot+p[1].hrotv)
	p[1].xv = 0
	p[1].yv = 0
	p[1].hrotv = 0 ]]
	local vx,vy = 0,0

	if btn(4) then
		p[1].hrot += ((btn(1) and 1 or 0) - (btn(0) and 1 or 0))*0.004
		p[1].hrot = norm_angle(p[1].hrot)
		p[1].x = -cos(p[1].hrot)*3 + px
		p[1].y = -sin(p[1].hrot)*3 + py
	else
		if btn(0) then
			vx = -sin(p[1].hrot)*0.05
			vy = cos(p[1].hrot)*0.05
		end
		if btn(1) then
			vx = sin(p[1].hrot)*0.05
			vy = -cos(p[1].hrot)*0.05
		end
	end
	if btn(2) then
		vx = cos(p[1].hrot)*0.05
		vy = sin(p[1].hrot)*0.05
	elseif btn(3) then
		vx = -cos(p[1].hrot)*0.05
		vy = -sin(p[1].hrot)*0.05
	end
	local fx = px + vx
	local fy = py + vy
	if fx >= 0 and fx < 128 and fget(mget(fx,py),0) then px = fx p[1].x += vx end
	if fy >= 0 and fy < 64 and fget(mget(px,fy),0) then py = fy p[1].y += vy end

	--player animation
	player:update()
	
	local closest = 1
	local closest_guy = nil
	for g in all(guys) do
		dist2 = find_distance2({x=fx,y=fy},g)
		g.talkable = false
		if dist2 < closest then
			closest = dist2
			closest_guy = g
		end
	end
	if (closest_guy) closest_guy.talkable = true
	
	cpu = stat(1)
end 

px = 30
py = 4

function _draw()
 cls(7)
	--skybox
 	--draw_background(p[1].hrot)
	--drawing floor + other character
 	draw_track(1,0,32,128,96)
	--drawing player, always in center of room... unless???
	
	
	--debug
	print(stat(1),0,0,14)
	?p[1].hrot
	?p[1].x
	?p[1].y
end

--(index of table that represents camera info, topleft corner of screen xy, resolution in pixels xy)
function draw_track(pn,
	corner_x, corner_y, 
	xres, yres)
	 --local pl= p
		--local gx, gy, hrot, near, far, fov =
		--p[pn].x, p[pn].y, p[pn].hrot, p[pn].near, p[pn].far, p[pn].fov

	--(postion xy, angle,)
	local gx, gy, hrot,
	 near, far, fov =
		p[pn].x, p[pn].y, p[pn].hrot,
		 p[pn].near, p[pn].far, p[pn].fov
	
	local coshmf=cos(hrot-fov)
	local sinhmf=sin(hrot-fov)
	local coshpf=cos(hrot+fov)
	local sinhpf=sin(hrot+fov)
	
	local farx1 = gx+coshmf*far
	local fary1 = gy+sinhmf*far
	
	local nearx1 = gx+coshmf*near
	local neary1 = gy+sinhmf*near
	
	local farx2 = gx+coshpf*far
	local fary2 = gy+sinhpf*far
	
	local nearx2 = gx+coshpf*near
	local neary2 = gy+sinhpf*near
	
	--do as many calculations as possible outside the loop
	local v1,v2,v3,v4 = 
	farx1-nearx1,fary1-neary1,farx2-nearx2,fary2-neary2 

	local xshift = 7
	if(xres == 64) xshift = 6
	
	--draw horozontal lines top to bottom
	for y = 0, yres, 1 do
	
		local sampledepth = yres/(y-scale) -- (y-scale)	
	
		local startx = v1*sampledepth+nearx1
		local starty = v2*sampledepth+neary1
		local endx = v3*sampledepth+nearx2
		local endy = v4*sampledepth+neary2
			
		--draw distance/xres. used for mdx,mdy in tline
		local x1 = (endx-startx)>>xshift
		local y1 = (endy-starty)>>xshift

		--dont draw map tiles out of bounds
		if startx < -128 or startx >= 256 or starty < -128 or starty >= 256 or
		endx <-128 or endx >= 256 or endy < -128 or endy >= 256 then
			goto nextline
		end

		tline( 0, y+corner_y, xres, y+corner_y,
		startx, starty,
		x1, y1)
		::nextline::

		
	end

	local zsort = {player}
	for g in all(guys) do
		local dx = g.x-gx
		local dy = g.y-gy

		local theta = norm_angle(hrot - atan2(dx,dy))
		g.dist = sqrt(dx*dx+dy*dy)*cos(theta)
		g.scy = (far-near)*cos(fov)/(g.dist-near*cos(fov))*yres+scale+corner_y
		if g.scy >= corner_y and theta == mid(-fov-0.02,theta,fov+0.02) then
			local depth = (g.dist-near*cos(fov))/((far-near)*cos(fov))
			local sx = v1*depth+nearx1
			local ex = v3*depth+nearx2
			g.scx = ((g.x-sx)<<xshift)/(ex-sx)
			for i = 1, #zsort do
				if g.dist >= zsort[i].dist then
					add(zsort,g,i)
				elseif i == #zsort then
					add(zsort,g)
				end
			end
		end
	end

	for z in all(zsort) do
		z:draw(pn)
	end
	
end

function draw_background(hrot)
		--
		--spr( 76, 95, 0, 4, 4 )
		--map( 0, 35, 63, 0, 8, 4 )
		rectfill( 0, 0, 127, 54, 56 )
		rectfill( 0, 56, 127, 14, 57 )
		line(0, 55, 127, 55, 8)
		--spr( 104, 63, 17, 8, 4 )
		rotation_ratio = 8
		m=flr(hrot<<rotation_ratio)%(8*2)
		--spr( 104, 0, 15, 4, 4 )
		sspr(64+m,0, 32-m,32, 0-m,0)
		if m~=0 then
		sspr(64,0, 2*m,32, 32-2*m,0)
	end
	for i = 0, 32 do
		adder = (i)<<6 //add 64
		memcpy(0x6000+adder+16, 0x6000+adder, 16 )
	end
	
	--copis 1/2 of whats in the screen to 2/2
	for i = 0, 32 do
		adder = (i)<<6 //add 64
		memcpy(0x6000+adder+32, 0x6000+adder, 32 )
	end
	
--rectfill( 0, 0, 127, 16, 8 )
--rectfill( 0, 0, 127, 16, 8 )
end

player = {s = 2, a = 0, f = false, d = 3, dist = 3}

function player:update()
	if btn(2) then
		self.d = 2
	elseif btn(3) then
		self.d = 3
	elseif btn(1) then
		self.d = 1
	elseif btn(0) then
		self.d = 0
	end
	
	if btn(0) or btn(1) or btn(2) or btn(3) then
		self.a = (self.a%4)+0.1
	else
		self.a = 0
	end
	
	if self.d <= 1 then
		self.f = (self.d == 1)
		self.s = (self.a > 2 and 12 or 14)
		if self.a == 0 then 
			self.s = 10 
		end
	elseif self.d == 2 then
		self.f = (self.a > 2)
		self.s = (self.a == 0 and 6 or 8)
		
	elseif self.d == 3 then
		self.f = (self.a > 2)
		self.s = (self.a == 0 and 2 or 4)
		
	end
end

function player:draw()
	pal(2,5)
	spr(self.s,56,44,2,4,self.f)
	pal(2,2)
end

function norm_angle(a)
	return (a+0.5)%1-0.5
end

function find_distance2(a,b)
	return (a.x-b.x)^2+(a.y-b.y)^2
end
__gfx__
00000000f4ffffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000fffff4ffeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00700700ffffff4feeeeee04440eeeeeeeeeee000eeeeeeeeeeeee09440eeeeeeeeeee09440eeeeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00077000fffff4ffeeeeee09440eeeeeeeeee04440eeeeeeeeeeee04440eeeeeeeeeee04440eeeeeeeee09440eeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeee
00077000fff4ffffeeee000222000eeeeee0009440eeeeeeeeeeee00400eeeeeeeeeee00400eeeeeeeee02220eeeeeeeeeeee000eeeeeeeeeee09440eeeeeeee
00700700ffffffffeee0990dd00990eeee0440222000eeeeeeee002000200eeeeeee002000200eeeeeee0dd20eeeeeeeeeee09440eeeeeeeeee02220eeeeeeee
000000004fffffffee044400d004444ee04440dd00440eeeeee02202220220eeeee022022202d0eeeeee0d200eeeeeeeeeee02220eeeeeeeeee0dd20eeeeeeee
00000000ffffffffe04444400044440ee044440d004444eeeee22222222222eeee022222222220eeeeeee00990eeeeeeeeee0dd20eeeeeeeeee0d200eeeeeeee
eeeeeeee4eeeeeeee0444440d044440ee0444400044440eeee0222222222220eee0002222222220eeeeee020020eeeeeeeee0d2000eeeeeeeeee00990eeeeeee
eeeeeeee44eeeeeee00044440444000ee000440d040040eeee0220222220220eee0440222220220eeeee0202200eeeeeeeeee00990eeeeeeeeee020220eeeeee
eeeeeeee4eeeeeeee02200044400020ee0d0044040d000eeee0000222220000eee0d00222220000eeeee0202220eeeeeeeeee200220eeeeee0e02202220eeeee
eeeeeeee44eeeeeee02202200020020ee0d0200440ddd0eeee0440022200040eee0d00022200eeeeeeee0204440eeeeeee0ee0220220eeee0d0022002220eeee
eeeeeeee4e4eeeeee02202222220020eee0e0220000dd0eee09d000000000d0eee4900000000eeeeeeee0200dd0eeeeee0d002220200eeee0dd022200020eeee
ee4eeeee44eeeeeee02200499940020eeeee049944000eeee09000499440090eee0000449940eeeeeeeee000d90eeeeee0ddd22022f0eeeee09000009d0eeeee
e4e4e44e4eeeeeeee00002222220000eeeee00222000eeeeee00e0200002040eeeee020000222eeeeeee0909d90eeeeeee09d900000eeeeeee000990d90eeeee
444444444eeeeeeeee0dd2222220dd0eeee222222220eeeeeeeee0222220e0eeeeee202222220eeeeeee202dd0eeeeeeeee0049940eeeeeeeeee000dd20eeeee
44444444eeeeeee4ee0dd222202000eeeee0222222220eeeeeee02222220eeeeeeee022222220eeeeeee0022220eeeeeeeee0002002eeeeeeeee022220eeeeee
e4e4e44eeeeeee44eeee022220220eeeeee0222222020eeeeeee022200220eeeeeee022200220eeeeeee2022220eeeeeeeee0222220eeeeeeeee022220eeeeee
ee4eeeeeeeeeeee4eeee022220220eeeee00220222020eeeeeee022202220eeeeeee022202220eeeeeee200220eeeeeeeee02022220eeeeeeee022220eeeeeee
eeeeeeeeeeeeee44eee0222220220eeeee00220222200eeeeeee022202220eeeeeee222002022eeeeeee002220eeeeeeee022002220eeeeeee0222200eeeeeee
eeeeeeeeeeeee4e4eee2220222020eeeee02222000200eeeeeee022202220eeeeeeee2200040eeeeeeee202220eeeeeeee022202220eeeeeee02220020eeeeee
eeeeeeeeeeeeee44eee0220222022eeeee022220440eeeeeeeee022200220eeeeeeee2220400eeeeeeeee00220eeeeeeee022002220eeeeeee02200220eeeeee
eeeeeeeeeeeeeee4eee0220200000eeeee00222000eeeeeeeeee022000200eeeeeeee0220440eeeeeeeee20220eeeeeeee022202220eeeeeee022002220eeeee
eeeeeeeeeeeeeee4eee0000004400eeeeee00000eeeeeeeeeeee022002220eeeeeeee022000eeeeeeeeee202220eeeeeee0220e02220eeeeee0222002220eeee
ee0000ee00000000eeee04400440eeeeeeee0440eeeeeeeeeeee022200220eeeeeeee0220eeeeeeeeeeee002220eeeeeeee020ee022200eeeee0220e00440eee
e088880e00000000eeee04400400eeeeeeee0440eeeeeeeeeeeee02200220eeeeeeee2020eeeeeeeeeeee000220eeeeeeee020eee000440eeee0200eee0440ee
0880088000000000eeee000000400eeeeeee0000eeeeeeeeeeeee02200000eeeeeeeee000eeeeeeeeeeee090400eeeeeeee000eeeee0040eeee0440ee0440eee
0880088000000000eeee0400044000eeeeee04000000eeeeeeeee00400440eeeeeeeee040000eeeeeeee09404400eeeeee0440eeeeee090eeee0940ee000eeee
0888888000000000eee009400044000eeee00440000000eeeeee0094000400eeeeeee004400000eeeeee000094000eeee0440eeeeeee00eeee094000000000ee
0880088000000000eee004000000000eeee009900000000eeeee09940044000eeeeee0044000000eeeeee00944000eeee00000000000000eee0000000000000e
e088880e00000000eee009900000000eeee000000000000eeeee00440000000eeeeee0000000000eeeeeee000000eeeeeee00000000000eeeee000000000eeee
ee0000ee00000000eeee0000000000eeeeee0000000000eeeeeee000000000eeeeeeee0000000eeeeeeeeeee000eeeeeeeeee0000000eeeeeeeee00000eeeeee
f4fff44444444444444fffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff4444ee4e4e44ee44444ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff44e4eeee4eeeeeee4e444f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f444eeeeeeeeeeeeeeee444f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f44eeeeeeeeeeeeeeeeee44f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44eeeeeeeeeeeeeeeeeeee4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4eeeeeeeeeeeeeeeeee4e400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4eeeeeeeeeeeeeeeeeeeeee400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4eeeeeeef4ffffffeeeeeee400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44eeeeeefffff4ffeeeeee4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4eeeeeeeffffff4feeeeeee400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44eeeeeefffff4ffeeeeee4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4eeeeefff4ffffeeeee4e400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44eeeeeeffffffffeeeeee4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4eeeeeee4fffffffeeeeeee400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4eeeeeeeffffffffeeeeeee400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4eeeeeeeeeeeeeeeeeeeeee400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4eeeeeeeeeeeeeeeeee4e400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44eeeeeeeeeeeeeeeeeeee4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f44eeeeeeeeeeeeeeeeee44f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f444eeeeeeeeeeeeeeee444f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff44e4eeee4eeeeeee4e44ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ff4444ee4e4e44ee4444fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffff44444444444444fffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
25151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0061616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161610101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
5251515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151510101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
