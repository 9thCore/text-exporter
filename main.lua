--[[

9th is back with a tool woo i sure do hope floating text decos dont come within 3 updates of releasing this

this tool exports all the words from a text file using a specified font into multiple pngs, to be used for decorations

no i dont get any of the math either

CREDITS
https://github.com/EmmanuelOga/easing/blob/master/lib/easing.lua
https://love2d.org/wiki/HSV_color
https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
https://gist.github.com/jasonbradley/4357406
https://stackoverflow.com/questions/1426954/split-string-in-lua
https://github.com/rxi/json.lua

]]

_EXPORTERVERSION = '1.2'

-- variables
min = math.min

json = require 'json'
easing = require 'easing'

rdfont = love.graphics.newFont("rdfont.otf", 16)
rdfont:setFilter("nearest", "nearest")

previewrdfont = love.graphics.newFont("rdfont.otf", 16)
previewrdfont:setFilter("nearest", "nearest")

-- @customizable in-program
outlineColor = {0, 0, 0, 1}
textColor = {1, 1, 1, 1}
makeSpritesheet = false
ignoreDupes = true
fontSize = 24
wordAlign = 0.5
dropShadowAngle = 315
dropShadowDist = 3
dropShadowColor = {1, 0, 0, 0}

words = {} -- stores the words from the lyrics
uniquewords = {} -- stores unique words only
escaped_space_str = '_originallyescapedspace_terriblecode_woo_noedgecasesright__fuck_' -- i sure do hope this doesnt cause issues

camera = {
	x = 0, -- pos
	y = 0, -- pos

	startTime = 0, -- anim
	duration = 0, -- anim
	ease = easing.outQuad, -- anim
	startX = 0, -- anim
	startY = 0, -- anim
	endX = 0, -- anim
	endY = 0, -- anim
	animating = false, 

	update = function()

		if camera.animating then

			local progress = camera.ease(love.timer.getTime() - camera.startTime, 0, 1, camera.duration)

			if progress < 1 then

				camera.x = math.floor(lerp(camera.startX, camera.endX, progress) + 0.5)
				camera.y = math.floor(lerp(camera.startY, camera.endY, progress) + 0.5)

			else

				camera.animating = false
				camera.x = camera.endX
				camera.y = camera.endY

			end

		end

	end, 
	moveTo = function(x, y, dur, ease)

		camera.startX = camera.x
		camera.startY = camera.y

		camera.endX = x
		camera.endY = y 

		camera.duration = dur or 1
		camera.startTime = love.timer.getTime()
		camera.ease = ease or easing.outQuad

		camera.animating = true

	end
}

default = {
	touchTest = function(mousex, mousey, obj)
		return touching(mousex, mousey, obj.x, obj.y, obj.x + obj.width, obj.y + obj.height)
	end,
	onClickButton = function(b) end,
	onClickPicker = function(p) end,
	onClickTextInput = function(i) end,
	onUnselectTick = function(t) end,
	onClickTick = function(t)

		t.clicked = not t.clicked

	end,
	onDrawButton = function(b)

		if mousetouching(b) then

			if b.activeFillColor then
				love.graphics.setColor(b.activeFillColor[1], b.activeFillColor[2], b.activeFillColor[3], 1)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end

		else
			
			if b.inactiveFillColor then
				love.graphics.setColor(b.inactiveFillColor[1], b.inactiveFillColor[2], b.inactiveFillColor[3], 1)
			else
				love.graphics.setColor(0.8, 0.8, 0.8, 1)
			end
			
		end

		love.graphics.rectangle("fill", b.x, b.y, b.width, b.height, min(10,b.width/4), min(10,b.height/4), 20)
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.push()

		local width, lines = rdfont:getWrap(b.text, b.width)

		local theight = rdfont:getHeight(b.text) * #lines

		love.graphics.translate(b.x, b.y + (b.height - theight * b.textscale) / 2)

		love.graphics.scale(b.textscale, b.textscale)

		love.graphics.setColor(b.textcolor[1], b.textcolor[2], b.textcolor[3], 1)
		love.graphics.printf(b.text, rdfont, 0, 0, b.width / b.textscale, 'center')
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.pop()

	end,
	onDrawText = function(t)

		love.graphics.push()

		local width, lines = t.font:getWrap(t.text, t.width)
		local theight = t.font:getHeight() * #lines

		local scaleFactor = t.fontSize/24
		local outlineOffset = math.max(math.floor(scaleFactor)*2, 1)

		love.graphics.translate(t.x, t.y + (t.height - theight * t.textscale) / 2)
		love.graphics.scale(t.textscale, t.textscale)

		-- main

		love.graphics.setColor(t.textcolor[1], t.textcolor[2], t.textcolor[3], t.textcolor[4])
		love.graphics.printf(t.text, t.font, 0, 0, t.width / t.textscale, 'center')

		love.graphics.pop()

	end, 
	onDrawPicker = function(p)

		local slideradd = p.sliderHeight + p.sliderDistance

		p:updateColors()

		-- hue slider
		do
			love.graphics.rectangle('fill', p.x - p.outlineWidth, p.y - p.outlineWidth - slideradd/2, p.width + p.outlineWidth*2, p.sliderHeight + p.outlineWidth*2)
			love.graphics.draw(p.huesliderimg, p.x, p.y - slideradd/2)
		end

		-- hue slider selector
		do
			love.graphics.setLineWidth(4)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle('line', p.x - p.outlineWidth + p.hue * p.width, p.y - p.outlineWidth - slideradd/2, 8, p.sliderHeight + p.outlineWidth*2)

			love.graphics.setLineWidth(2)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle('line', p.x - p.outlineWidth + p.hue * p.width, p.y - p.outlineWidth - slideradd/2, 8, p.sliderHeight + p.outlineWidth*2)
			love.graphics.setLineWidth(1)

		end

		-- alpha slider
		do
			love.graphics.rectangle('fill', p.x - p.outlineWidth, p.y + p.height + p.outlineWidth*2 + p.sliderDistance + p.sliderHeight/2, p.width + p.outlineWidth*2, p.sliderHeight + p.outlineWidth*2)
			love.graphics.draw(p.alphasliderimg, p.x, p.y + p.height + p.outlineWidth*3 + p.sliderDistance + p.sliderHeight/2)
		end

		-- alpha slider selector
		do
			love.graphics.setLineWidth(4)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle('line', p.x - p.outlineWidth + p.alpha * p.width, p.y + p.height + p.outlineWidth*2 + p.sliderDistance + p.sliderHeight/2, 8, p.sliderHeight + p.outlineWidth*2)

			love.graphics.setLineWidth(2)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle('line', p.x - p.outlineWidth + p.alpha * p.width, p.y + p.height + p.outlineWidth*2 + p.sliderDistance + p.sliderHeight/2, 8, p.sliderHeight + p.outlineWidth*2)
			love.graphics.setLineWidth(1)
		end

		-- picker
		do
			love.graphics.rectangle('fill', p.x - p.outlineWidth, p.y - p.outlineWidth + slideradd/2, p.width + p.outlineWidth*2, p.height + p.outlineWidth*2)
			love.graphics.draw(p.img, p.x, p.y + slideradd/2)
		end

		do
			love.graphics.setLineWidth(4)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.circle('line', p.x + p.selectedX * p.width, p.y + slideradd/2 + p.selectedY * p.height, 6)

			love.graphics.setLineWidth(2)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.circle('line', p.x + p.selectedX * p.width, p.y + slideradd/2 + p.selectedY * p.height, 6)
			love.graphics.setLineWidth(1)
		end

	end, 
	onDrawTextInput = function(i)

		local used = i.text

		love.graphics.setColor(1, 1, 1, 1)
		if inputting == i then
			love.graphics.setColor(1, 1, 0, 1)
			used = used .. '|'
		end

		love.graphics.rectangle('fill', i.x - 4, i.y - 4, i.width + 8, i.height + 8)

		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.rectangle('fill', i.x, i.y, i.width, i.height)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(used, rdfont, i.x - i.width/2, i.y + i.height/2 - rdfont:getHeight(), i.width, 'center', 0, 2)

	end, 
	onDrawTick = function(t)

		local width = t.font:getWidth(t.text)
		local height = t.font:getHeight() * math.ceil(width / t.width)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle('fill', t.x + t.side*0.5, t.y + t.side, t.side, t.side, 5, 5, 10)

		if t.clicked then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf('X', t.font, t.x, t.y + t.side, t.side*2, 'center')
		end

		local origh = t.height

		t.x = t.x + 20
		t.y = t.y + t.textoffsety
		t.width = t.width - 20
		t.height = 0

		default.onDrawText(t)

		t.x = t.x - 20
		t.y = t.y - t.textoffsety
		t.width = t.width + 20
		t.height = origh

	end
}

objects = {}

-- https://stackoverflow.com/questions/1426954/split-string-in-lua
function mysplit (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function clamp(v,minv,maxv) return math.max(math.min(v, maxv), minv) end

function lerp(a,b,t) return a * (1-t) + b * t end

-- https://love2d.org/wiki/HSV_color
function HSV(h, s, v)
	if s <= 0 then return v,v,v end
	h = h*6
	local c = v*s
	local x = (1-math.abs((h%2)-1))*c
	local m,r,g,b = (v-c), 0, 0, 0
	if h < 1 then
		r, g, b = c, x, 0
	elseif h < 2 then
		r, g, b = x, c, 0
	elseif h < 3 then
		r, g, b = 0, c, x
	elseif h < 4 then
		r, g, b = 0, x, c
	elseif h < 5 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return r+m, g+m, b+m
end

-- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
function rgbToHsv(r, g, b, a)
  r, g, b, a = r / 255, g / 255, b / 255, a / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v, a
end

-- x, y are a point that's checked if it's inside of the area defined by x1, x2, y1, y2
function touching(x, y, x1, y1, x2, y2)
	return (x > x1) and (x < x2) and (y > y1) and (y < y2)
end

function mousetouching(o)
	return (o.touchTest or default.touchTest)(love.mouse.getX() + camera.x, love.mouse.getY() + camera.y, o)
end

-- functions
function newobject(args)

	local o = {}

	o.allowHold = false

	o.touchTest = args.touchTest
	o.font = args.font or rdfont
	o.text = args.text or ''
	o.textscale = args.textscale or 1
	o.textcolor = args.textcolor or {1,1,1,1}
	o.outlinecolor = args.outlinecolor or {0,0,0,0}

	o.fontSize = 24

	o.x = args.x or 0
	o.y = args.y or 0

	o.width = args.width or 0
	o.height = args.height or 0

	if args.centered then
		o.x = o.x - o.width / 2
		o.y = o.y - o.height / 2
	end

	objects[#objects+1] = o

	for k,v in pairs(args) do

		o[k] = o[k] or args[k]

	end

	return o

end

function newbutton(args)

	args.textcolor = args.textcolor or {0,0,0}

	local b = newobject(args)

	b.onClick = args.onClick or default.onClickButton
	b.onDraw = args.onDraw or default.onDrawButton

	b.activeFillColor = args.activeFillColor or nil
	b.inactiveFillColor = args.inactiveFillColor or nil

	return b

end

function newtext(args)

	local t = newobject(args)

	t.onDraw = args.onDraw or default.onDrawText

	return t

end

function newtextinput(args)

	local i = newobject(args)

	i.text = args.text or '#000000'

	i.onDraw = args.onDraw or default.onDrawTextInput
	i.onUnselect = args.onUnselect or default.onUnselectTick
	i.onInput = args.onInput or function(i, text)

		if text == '_backspace' then
			if #i.text > 1 then
				i.text = i.text:sub(1,-2)
			end
		elseif #i.text < 7 then
			text = text:lower()

			local allowed = {
				['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true, ['9'] = true,
				['a'] = true, ['b'] = true, ['c'] = true, ['d'] = true, ['e'] = true, ['f'] = true
			}

			if not allowed[text] then return end

			i.text = i.text .. text

			if #i.text == 7 then

				local hex = i.text:gsub('#', '')
				local r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) -- https://gist.github.com/jasonbradley/4357406
				local h, s, v = rgbToHsv(r,g,b,1)

				if i == textcolorinput then

					textcolorpicker.hue = h
					textcolorpicker.selectedX = s
					textcolorpicker.selectedY = 1-v

					textcolorpicker:updateColors()
					updateTextColor()

				else

					outlinecolorpicker.hue = h
					outlinecolorpicker.selectedX = s
					outlinecolorpicker.selectedY = 1-v

					outlinecolorpicker:updateColors()
					updateTextColor()

				end

			end

		end

	end

	return i

end

function newcolorpicker(args)

	local p = newobject(args)

	p.onDraw = args.onDraw or default.onDrawPicker
	p.onClick = args.onClick or default.onClickPicker

	p.hue = args.hue or 0
	p.alpha = args.alpha or 1
	p.selectedX = args.selectedX or 0
	p.selectedY = args.selectedY or 0

	p.imgdata = love.image.newImageData(p.width, p.height)
	p.img = love.graphics.newImage(p.imgdata)

	p.sliderHeight = 25
	p.sliderDistance = 25

	p.huesliderimgdata = love.image.newImageData(p.width, p.sliderHeight)
	p.huesliderimg = love.graphics.newImage(p.huesliderimgdata)

	p.alphasliderimgdata = love.image.newImageData(p.width, p.sliderHeight)
	p.alphasliderimg = love.graphics.newImage(p.alphasliderimgdata)

	p.outlineWidth = 4

	p.updateColors = function(p)

		-- hue slider
		p.huesliderimgdata:mapPixel(function(x, y)

			x = x / p.width
			y = y / p.sliderHeight

			local r, g, b = HSV(x, 1, 1)

			return r, g, b, 1

		end)

		p.huesliderimg:replacePixels(p.huesliderimgdata)

		-- alpha slider
		p.alphasliderimgdata:mapPixel(function(x, y)

			local half = p.sliderHeight*0.5

			local transp = 0.75

			if x%(half*2) < half then if y > half then transp = 1 end
			elseif y < half then transp = 1
			end

			local progress = x / p.width

			local r, g, b = HSV(p.hue, p.selectedX, 1-p.selectedY)

			return lerp(transp, r, progress), lerp(transp, g, progress), lerp(transp, b, progress), 1

		end)

		p.alphasliderimg:replacePixels(p.alphasliderimgdata)

		-- picker
		p.imgdata:mapPixel(function(x, y)

			x = x / p.width
			y = y / p.height

			local r, g, b = HSV(p.hue, x, 1-y)

			return r, g, b, 1

		end)

		p.img:replacePixels(p.imgdata)

	end

	p.touchTest = function(mousex, mousey, p)

		local slideradd = p.sliderHeight + p.sliderDistance

		if touching(mousex, mousey, p.x, p.y - slideradd/2, p.x + p.width, p.y - slideradd/2 + p.sliderHeight) then -- hue slider

			p.holdingpart = 'hue'
			return true

		elseif touching(mousex, mousey, p.x, p.y + slideradd/2, p.x + p.width, p.y + slideradd/2 + p.height) then -- picker

			p.holdingpart = 'picker'
			return true

		elseif touching(mousex, mousey, p.x, p.y + p.height + p.outlineWidth*2 + p.sliderDistance + p.sliderHeight*0.5, p.x + p.width, p.y + p.height + p.outlineWidth*3 + p.sliderDistance + p.sliderHeight*1.5) then -- alpha slider

			p.holdingpart = 'alpha'
			return true

		end

	end

	return p

end

function newtick(args)

	local t = newobject(args)

	t.onDraw = args.onDraw or default.onDrawTick
	t.onClick = args.onClick or default.onClickTick

	t.side = args.side or 20
	t.clicked = args.clicked or false
	t.textoffsety = args.textoffsety or 0

	return t

end

function updateFontSize(size)

	fontSize = size
	if preview.font ~= previewrdfont then -- custom font
		local res, font = pcall(love.graphics.newFont, 'font.ttf', size)
		if not res then
			res, font = pcall(love.graphics.newFont, 'font.otf', size)
		end
		
		if not res then
			fontnotifier.text = 'Couldn\'t find font!'
			fontnotifier.textcolor = {1,0,0}

			previewrdfont = love.graphics.newFont('rdfont.otf', math.floor(size/24*16+0.5))
			previewrdfont:setFilter('nearest', 'nearest')

			preview.font = previewrdfont
		else
			fontnotifier.text = ''
			preview.font = font
		end
	else
		previewrdfont = love.graphics.newFont('rdfont.otf', math.floor(size/24*16+0.5))
		previewrdfont:setFilter('nearest', 'nearest')

		preview.font = previewrdfont
	end

	preview.fontSize = fontSize

end

function updateTextColor()

	textColor[1], textColor[2], textColor[3] = HSV(textcolorpicker.hue, textcolorpicker.selectedX, 1-textcolorpicker.selectedY)
	textColor[4] = textcolorpicker.alpha

	outlineColor[1], outlineColor[2], outlineColor[3] = HSV(outlinecolorpicker.hue, outlinecolorpicker.selectedX, 1-outlinecolorpicker.selectedY)
	outlineColor[4] = outlinecolorpicker.alpha

	dropShadowColor[1], dropShadowColor[2], dropShadowColor[3] = HSV(shadowcolorpicker.hue, shadowcolorpicker.selectedX, 1-shadowcolorpicker.selectedY)
	dropShadowColor[4] = shadowcolorpicker.alpha

end

function love.load(args)

	-- window stuff
	local data = love.image.newImageData("icon.png")
	local success = love.window.setIcon(data)
	love.window.setTitle('Text Exporter v' .. _EXPORTERVERSION)

	-- making sure the save dir exists
	love.filesystem.write('README.txt', 'This is where you put your lyrics!\n\nSimply plop down a \'lyrics.txt\' file in this folder and the program will automatically extract each word (characters separated by a space).\n\nWhen it\'s done, the output will go into the \'output\' folder.')
	love.filesystem.createDirectory('output')

	-- main screen
	do
		newbutton{
			x = 400,
			y = 300,
			width = 300,
			height = 50,
			centered = true,
			text = 'Import \'lyrics.txt\'',
			textscale = 2,
			onDraw = nil,
			onClick = function(o)

				words = {}

				local contents, size = love.filesystem.read('lyrics.txt')

				if contents then

					local contents_minus_escaped_spaces = contents:gsub('\\ ', escaped_space_str)

					for w in contents_minus_escaped_spaces:gmatch("%S+") do

						w = w:gsub(escaped_space_str, ' ')

						if w:find('\\n') then

							local t = {}
							local lasti = 1
							for i = 1, #w do
								if w:sub(i, i+1) == '\\n' then
									t[#t+1] = w:sub(lasti, i-1)
									lasti = i + 2
								end
							end
							t[#t+1] = w:sub(lasti, -1)

							final = table.concat(t, '\n')

							words[#words+1] = final
							
							local found = false
							for _,w in ipairs(uniquewords) do
								if w == final then
									found = true
									break
								end
							end
							if not found then
								uniquewords[#uniquewords+1] = final
							end

						elseif w:find('/') then

							local t = mysplit(w, '/')

							for i=1,#t do

								local final = t[i]

								for j=i-1,1,-1 do
									final = t[j] .. final
								end

								words[#words+1] = final
									
								local found = false
								for _,w in ipairs(uniquewords) do
									if w == final then
										found = true
										break
									end
								end
								if not found then
									uniquewords[#uniquewords+1] = final
								end

							end

						else

							words[#words+1] = w

							local found = false
							for _,word in ipairs(uniquewords) do
								if word == w then
									found = true
									break
								end
							end
							if not found then
								uniquewords[#uniquewords+1] = w
							end

						end

					end

					if #words < 1 then

						print('Found no words!')

						lyricsnotifier.textcolor = {1,0,0}
						lyricsnotifier.text = 'Couldn\'t find any words!'
						lyricsnotifier.y = 300

						startbutton:newState(false)

					else

						print('Found ' .. #words .. ' words.')

						lyricsnotifier.textcolor = {0,1,0}
						lyricsnotifier.text = 'Successfully loaded!'
						lyricsnotifier.y = 300

						startbutton:newState(true)

					end

				else

					lyricsnotifier.textcolor = {1,0,0}
					lyricsnotifier.text = 'Couldn\'t load!\nAre you sure \'lyrics.txt\' is present in the working directory?'
					lyricsnotifier.y = 325

					startbutton:newState(false)

				end

			end
		}

		lyricsnotifier = newtext{
			x = 400,
			y = 350,
			width = 800,
			height = 100,
			centered = true, 
			text = '',
			textcolor = {0,1,0},
			textscale = 2
		}

		newbutton{
			x = 400,
			y = 120,
			width = 150,
			height = 50,
			centered = true,
			texscale = 1,
			text = 'Open working\ndirectory',
			onDraw = nil,
			onClick = function(o)
				love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
			end
		}

		startbutton = newbutton{
			x = 400,
			y = 500,
			width = 300,
			height = 50,
			textscale = 2,
			centered = true, 
			text = 'Start!',
			onClick = function(b)

				if startbutton.accessible then

					print('Starting with ' .. #words .. ' words...')

					print('Removing old words...')

					love.filesystem.createDirectory('output')
					local files = love.filesystem.getDirectoryItems('output')
					for _,f in ipairs(files) do
						love.filesystem.remove('output/'..f)
					end

					local scaleFactor = fontSize/24
					local outlineOffset = math.max(math.floor(scaleFactor)*2, 1)

					local r = math.rad(dropShadowAngle)
					local shadowX, shadowY = math.floor(math.cos(r) * dropShadowDist + 0.5), -math.floor(math.sin(r) * dropShadowDist + 0.5)

					local offsetX, offsetY = math.max(0, -shadowX), math.max(0, -shadowY)

					local xPad = math.floor(8 * scaleFactor + 0.5)

					love.graphics.setColor(1, 1, 1, 1)

					local function drawText(text, font, x, y)
						love.graphics.printf(text, font, x + offsetX, y + offsetY, 9999)
					end

					local function drawTextWithOutline(text, font, x, y)

						-- drop shadow
						love.graphics.setColor(dropShadowColor[1], dropShadowColor[2], dropShadowColor[3], dropShadowColor[4])

						drawText(text, font, x + outlineOffset + xPad*wordAlign*2 + shadowX, y + outlineOffset + shadowY)

						-- outline
						love.graphics.setColor(outlineColor[1], outlineColor[2], outlineColor[3], outlineColor[4])

						drawText(text, font, x + outlineOffset + xPad*wordAlign*2, y)
						drawText(text, font, x + xPad*wordAlign*2, y + outlineOffset)
						drawText(text, font, x + outlineOffset*2 + xPad*wordAlign*2, y + outlineOffset)
						drawText(text, font, x + outlineOffset + xPad*wordAlign*2, y + outlineOffset*2)

						-- main
						love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4])

						drawText(text, font, x + outlineOffset + xPad*wordAlign*2, y + outlineOffset)

					end

					if not makeSpritesheet then

						for i=1,#words do

							-- draw word
							local word = words[i]

							local _, newlinecount = word:gsub('\n', '\n') -- magic
							newlinecount = newlinecount + 1

							local w = preview.font:getWidth(word) + outlineOffset + xPad*2 + math.abs(shadowX)
							local h = preview.font:getHeight() * newlinecount - preview.font:getDescent() + 1 + math.abs(shadowY)

							local canvas = love.graphics.newCanvas(w, h)

							love.graphics.setCanvas(canvas)

							love.graphics.clear()

							local allWords = mysplit('_' .. word, '\n')
							allWords[1] = allWords[1]:sub(2, -1)

							for i,thisword in ipairs(allWords) do
								drawTextWithOutline(thisword, preview.font, (w - preview.font:getWidth(thisword) - xPad*2 - 2) * wordAlign, (i-1) * preview.font:getHeight())
							end

							love.graphics.setCanvas()

							-- save word
							canvas:newImageData():encode('png', 'output/lyric-' .. i .. '.png')

						end

					else

						local wordusagecount = {}
						local wordfirstframe = {}

						local sheetWidth = 0
						local sheetHeight = 0

						-- calculate max width
						local wordcount = #uniquewords
						local wordwidth = 0
						local wordheight = 0

						for _,w in ipairs(words) do

							wordwidth = math.max(wordwidth, preview.font:getWidth(w))

							local _, newlinecount = w:gsub('\n', '\n') -- magic
							newlinecount = newlinecount + 1

							wordheight = math.max(wordheight, preview.font:getHeight() * newlinecount - preview.font:getDescent() + 1 + math.abs(shadowY))

						end

						wordwidth = wordwidth + outlineOffset + xPad*2 + math.abs(shadowX)

						-- try to make the spritesheet as square as possible to avoid any potential issues
						local sqrt = math.sqrt(wordcount)

						local columns = math.ceil(sqrt)
						local lines = math.ceil(wordcount / columns)

						-- adding a bit so that we have space for the outline and glow; xPad was just to make sure no fonts get cut off
						local wordwidthpadded = wordwidth + 16
						local wordheightpadded = wordheight + 16

						sheetWidth = wordwidthpadded * columns
						sheetHeight = wordheightpadded * lines

						-- prepare json at the same time as drawing the words
						local jsonT = {
							size = {wordwidthpadded, wordheightpadded}, 
							rowPreviewFrame = 0, 
							rowPreviewOffset = {0, 0}, 
							clips = {
								{
									name = 'neutral', 
									frames = {0}, 
									loop = 'onBeat', 
									fps = 0, 
									loopStart = 0, 
									portraitOffset = {0, 0}, 
									portraitSize = {25, 25}, 
									portraitScale = 2
								}
							}
						}

						-- canvas to draw onto so we can export as a png
						local canvas = love.graphics.newCanvas(sheetWidth, sheetHeight)
						love.graphics.setCanvas(canvas)
						love.graphics.clear()

						local usedt = uniquewords
						if not ignoreDupes then
							usedt = words
						end

						local x, y, frame = 1, 1, 0
						for _, wordWithNewlines in ipairs(usedt) do

							local firstusedframe = false

							local jsonname = wordWithNewlines:gsub('%s+', '_')
							wordusagecount[jsonname] = (wordusagecount[jsonname] or 0) + 1

							if wordusagecount[jsonname] > 1 then
								firstusedframe = wordfirstframe[jsonname]
								jsonname = jsonname .. ':' .. tostring(wordusagecount[jsonname])
							else
								wordfirstframe[jsonname] = frame
							end

							if not firstusedframe then

								local allWords = mysplit('_' .. wordWithNewlines, '\n')
								allWords[1] = allWords[1]:sub(2, -1)

								for i,w in ipairs(allWords) do

									-- i have no idea how this works help
									local wordx = (x-1)*wordwidthpadded + (wordwidthpadded - preview.font:getWidth(w) - xPad*2 - math.abs(shadowX)) * 0.5 + (wordwidth - preview.font:getWidth(w) - xPad*2 - math.abs(shadowX)) * (wordAlign - 0.5)
									local wordy = (y-1)*wordheightpadded + (wordheightpadded - wordheight)*0.5 + (i-1) * preview.font:getHeight()

									-- draw	
									drawTextWithOutline(w, preview.font, wordx, wordy)

								end

								-- go to the next frame
								x = x + 1
								if x > columns then
									x = 1
									y = y + 1
								end

							end

							local usedframe = firstusedframe or frame

							-- save expression
							jsonT.clips[#jsonT.clips+1] = {
								name = jsonname,
								frames = {usedframe}, 
								loop = 'onBeat', 
								fps = 0, 
								loopStart = 0, 
								portraitOffset = {0, 0}, 
								portraitSize = {25, 25}, 
								portraitScale = 2
							}

							if not firstusedframe then
								frame = frame + 1
							end

							-- print(jsonname, firstusedframe, usedframe, frame)

						end

						love.graphics.setCanvas()

						local alphaThreshold = 10/255

						-- main spritesheet
						local img = canvas:newImageData()

						-- remove pixels that are pretty much invisible
						img:mapPixel(function(x, y, r, g, b, a)

							if a < alphaThreshold then return 0, 0, 0, 0 end
							return r, g, b, a

						end)

						local orig = img:clone()

						img:encode('png', 'output/lyrics.png')

						--[[
						local function getalpha(img,x,y)

							if x < 0 or x > img:getWidth() - 1 or y < 0 or y > img:getHeight() - 1 then return 0 end
							local r, g, b, a = img:getPixel(x, y)

							return a

						end

						-- outline
						img:mapPixel(function(x, y, r, g, b, a)

							if getalpha(orig, x, y) > alphaThreshold then return 0, 0, 0, 0 end

							local combined = getalpha(orig, x-1, y) + getalpha(orig, x+1, y) + getalpha(orig, x, y-1) + getalpha(orig, x, y+1)

							if combined > 0 then return 1, 1, 1, 1 end
							return 0, 0, 0, 0

						end)

						img:encode('png', 'output/lyrics_outline.png')

						-- glow
						local radius = 4

						img:mapPixel(function(x, y, r, g, b, a)

							local distFromOpaque = radius

							for rx = -radius, radius do
								for ry = -radius, radius do

									if rx ~= 0 and ry ~= 0 then

										local thisalpha = getalpha(orig, x + rx, y + ry)
										if thisalpha > alphaThreshold then
											distFromOpaque = math.min(distFromOpaque, math.sqrt(rx*rx, ry*ry))
										end

									end

								end
							end

							local alpha = 1 - distFromOpaque/radius

							return 1, 1, 1, alpha
							-- it is fucking WRONG

						end)

						img:encode('png', 'output/lyrics_glow_full.png')

						-- glow, no inside color
						img:mapPixel(function(x, y, r, g, b, a)

							if getalpha(orig, x, y) > alphaThreshold then return 0, 0, 0, 0 end
							return r, g, b, a

						end)

						img:encode('png', 'output/lyrics_glow.png')
						]]

						-- json
						love.filesystem.write('output/lyrics.json', json.encode(jsonT))

					end

					logger.text = 'Successfully exported ' .. #words .. ' word' .. ((#words > 1 and 's') or '') .. '!'
					logger.textcolor = {1.5, 1.5, 1.5}

					print('Done!')

				end

			end,
			newState = function(b, active)

				local inactiveColor = 0
				local activeColor = 0

				if active then

					inactiveColor = 0.8
					activeColor = 1

				else

					inactiveColor = 1/4
					activeColor = 1/4

				end

				startbutton.inactiveFillColor = {inactiveColor, inactiveColor, inactiveColor}
				startbutton.activeFillColor = {activeColor, activeColor, activeColor}

				startbutton.accessible = not not active

			end
		}

		startbutton:newState(false)

		logger = newtext{
			x = 0,
			y = 600 - 50,
			width = 800, 
			height = 50, 
			textscale = 2,
			text = '',
			onDraw = function(t)

				t.textcolor = {t.textcolor[1] - 0.016, t.textcolor[2] - 0.016, t.textcolor[3] - 0.016}

				default.onDrawText(t)

			end
		}
	end

	-- general options
	do
		newbutton{
			x = 700,
			y = 300, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Options',
			onClick = function(o)
				camera.moveTo(800, 0, 1, easing.outExpo)
			end
		}

		newbutton{
			x = 900,
			y = 300, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Back',
			onClick = function(o)
				camera.moveTo(0, 0, 1, easing.outExpo)
			end
		}

		preview = newtext{
			x = 1200, 
			y = -300, 
			width = 300, 
			height = 0, 
			centered = true, 
			text = 'Preview',
			textcolor = textColor,
			outlinecolor = outlineColor, 
			font = previewrdfont, 
			onDraw = function(t)

				love.graphics.push()

				local width, lines = t.font:getWrap(t.text, t.width)
				local theight = t.font:getHeight() * #lines

				local scaleFactor = t.fontSize/24
				local outlineOffset = math.max(math.floor(scaleFactor)*2, 1)

				love.graphics.translate(t.x, t.y + (t.height - theight * t.textscale) / 2)
				love.graphics.scale(t.textscale, t.textscale)

				-- drop shadow

				local r = math.rad(dropShadowAngle)
				local dx, dy = math.floor(math.cos(r) * dropShadowDist + 0.5), -math.floor(math.sin(r) * dropShadowDist + 0.5)

				love.graphics.setColor(dropShadowColor[1], dropShadowColor[2], dropShadowColor[3], dropShadowColor[4])
				love.graphics.printf(t.text, t.font, dx, dy, t.width / t.textscale, 'center')

				-- outline

				love.graphics.setColor(t.outlinecolor[1], t.outlinecolor[2], t.outlinecolor[3], t.outlinecolor[4])
				love.graphics.printf(t.text, t.font, -outlineOffset, 0, t.width / t.textscale, 'center')

				love.graphics.setColor(t.outlinecolor[1], t.outlinecolor[2], t.outlinecolor[3], t.outlinecolor[4])
				love.graphics.printf(t.text, t.font, outlineOffset, 0, t.width / t.textscale, 'center')

				love.graphics.setColor(t.outlinecolor[1], t.outlinecolor[2], t.outlinecolor[3], t.outlinecolor[4])
				love.graphics.printf(t.text, t.font, 0, -outlineOffset, t.width / t.textscale, 'center')

				love.graphics.setColor(t.outlinecolor[1], t.outlinecolor[2], t.outlinecolor[3], t.outlinecolor[4])
				love.graphics.printf(t.text, t.font, 0, outlineOffset, t.width / t.textscale, 'center')

				-- main

				love.graphics.setColor(t.textcolor[1], t.textcolor[2], t.textcolor[3], t.textcolor[4])
				love.graphics.printf(t.text, t.font, 0, 0, t.width / t.textscale, 'center')

				love.graphics.pop()

			end,
			textscale = 2
		}

		newtick{
			x = 1350, 
			y = 120, 
			width = 250,
			height = 100,
			text = 'Make spritesheet', 
			textscale = 2, 
			touchTest = function(x, y, t)
				return touching(x, y, t.x, t.y, t.x + t.width, t.y + t.height/2)
			end, 
			onClick = function(t)
				t.clicked = not t.clicked 
				makeSpritesheet = t.clicked
			end
		}

		newtick{
			x = 1350, 
			y = 200, 
			width = 250,
			height = 100,
			text = 'Ignore duplicates in spritesheet',
			textscale = 1, 
			textoffsety = 30,
			clicked = true,
			touchTest = function(x, y, t)
				return touching(x, y, t.x, t.y, t.x + t.width, t.y + t.height/2)
			end, 
			onClick = function(t)
				t.clicked = not t.clicked 
				ignoreDupes = t.clicked
			end
		}

		newtext{
			x = 1480, 
			y = 350, 
			width = 210, 
			height = 50, 
			centered = true, 
			text = 'Word horizontal align', 
			textscale = 2
		}

		newtextinput{
			x = 1480, 
			y = 480, 
			width = 160, 
			height = 50, 
			centered = true,
			text = '50%', 
			onInput = function(i, text)

				if text == '_backspace' then

					local num = i.text:sub(1,-2)
					num = num:sub(1,-2)
					i.text = num .. '%'

				else

					if not tonumber(text) then return end

					local num = i.text:sub(1,-2)
					num = num .. text

					if not tonumber(num) then return end
					num = clamp(tonumber(num), 0, 100)
					i.text = tostring(num) .. '%'

				end

				if #i.text > 1 then
					wordAlign = tonumber(i.text:sub(1,-2)) / 100
				end

			end, 
			onUnselect = function(i)
				if #i.text < 2 then
					i.text = '50%'
					wordAlign = 0.5
				end
			end,
			onDraw = function(i)

				local used = i.text

				love.graphics.setColor(1, 1, 1, 1)
				if inputting == i then
					love.graphics.setColor(1, 1, 0, 1)
					used = used:sub(1,-2) .. '|%'
				end

				love.graphics.rectangle('fill', i.x - 4, i.y - 4, i.width + 8, i.height + 8)

				love.graphics.setColor(0.5, 0.5, 0.5, 1)
				love.graphics.rectangle('fill', i.x, i.y, i.width, i.height)

				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.printf(used, rdfont, i.x - i.width/2, i.y + i.height/2 - rdfont:getHeight(), i.width, 'center', 0, 2)

			end
		}
	end

	-- color
	do
		newbutton{
			x = 1200,
			y = 100, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Color',
			onClick = function(o)
				camera.moveTo(800, -600, 1, easing.outExpo)
				preview.y = -350
			end
		}

		newbutton{
			x = 1200,
			y = -50, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Back',
			onClick = function(o)
				camera.moveTo(800, 0, 1, easing.outExpo)
			end
		}

		newtext{
			x = 950, 
			y = -510, 
			width = 200, 
			height = 50, 
			centered = true, 
			text = 'Text color',
			textscale = 2,
		}

		textcolorinput = newtextinput{
			x = 950, 
			y = -120, 
			width = 200,
			height = 40, 
			centered = true,
			text = '#ffffff',
			onUnselect = function(i)

				if #i.text < 7 then
					local hex = string.format('#%02x%02x%02x', math.floor(textColor[1]*255), math.floor(textColor[2]*255), math.floor(textColor[3]*255))
					i.text = hex
				end

			end
		}

		textcolorpicker = newcolorpicker{
			x = 950, 
			y = -350, 
			width = 200, 
			height = 200, 
			centered = true,
			allowHold = true, 
			onHold = function(p)

				local mousex, mousey = love.mouse.getPosition()
				mousex = mousex + camera.x 
				mousey = mousey + camera.y 

				local slideradd = p.sliderHeight + p.sliderDistance

				if p.holdingpart == 'hue' then -- hue slider

					p.hue = clamp((mousex - p.x) / p.width, 0, 1)

				elseif p.holdingpart == 'picker' then -- picker

					p.selectedX = clamp((mousex - p.x) / p.width, 0, 1)
					p.selectedY = clamp((mousey - p.y - slideradd/2) / p.height, 0, 1)

				elseif p.holdingpart == 'alpha' then -- alpha slider

					p.alpha = clamp((mousex - p.x) / p.width, 0, 1)

				end

				updateTextColor()

				local hex = string.format('#%02x%02x%02x', math.floor(textColor[1]*255), math.floor(textColor[2]*255), math.floor(textColor[3]*255))
				textcolorinput.text = hex

			end
		}

		newtext{
			x = 1450, 
			y = -510, 
			width = 400, 
			height = 50, 
			centered = true, 
			text = 'Outline color',
			textscale = 2,
		}

		outlinecolorinput = newtextinput{
			x = 1450, 
			y = -120, 
			width = 200,
			height = 40, 
			centered = true, 
			onUnselect = function(i)

				if #i.text < 7 then
					local hex = string.format('#%02x%02x%02x', math.floor(outlineColor[1]*255), math.floor(outlineColor[2]*255), math.floor(outlineColor[3]*255))
					i.text = hex
				end

			end
		}

		outlinecolorpicker = newcolorpicker{
			x = 1450, 
			y = -350, 
			width = 200, 
			height = 200, 
			centered = true,
			allowHold = true, 
			selectedY = 1,
			onHold = function(p)

				local mousex, mousey = love.mouse.getPosition()
				mousex = mousex + camera.x 
				mousey = mousey + camera.y 

				local slideradd = p.sliderHeight + p.sliderDistance

				if p.holdingpart == 'hue' then -- hue slider

					p.hue = clamp((mousex - p.x) / p.width, 0, 1)

				elseif p.holdingpart == 'picker' then -- picker

					p.selectedX = clamp((mousex - p.x) / p.width, 0, 1)
					p.selectedY = clamp((mousey - p.y - slideradd/2) / p.height, 0, 1)

				elseif p.holdingpart == 'alpha' then -- alpha slider

					p.alpha = clamp((mousex - p.x) / p.width, 0, 1)

				end

				updateTextColor()

				local hex = string.format('#%02x%02x%02x', math.floor(outlineColor[1]*255), math.floor(outlineColor[2]*255), math.floor(outlineColor[3]*255))
				outlinecolorinput.text = hex

			end
		}

	end

	-- drop shadow
	do

		newbutton{
			x = 1500,
			y = 300, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Shadow',
			onClick = function(o)
				camera.moveTo(1600, 0, 1, easing.outExpo)

				preview.x = 2000 - preview.width/2
				preview.y = 250

			end
		}

		newbutton{
			x = 1700,
			y = 300, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Back',
			onClick = function(o)
				camera.moveTo(800, 0, 1, easing.outExpo)
				
				preview.x = 1200 - preview.width/2
				preview.y = 9999

			end
		}

		newtext{
			x = 2250, 
			y = 110, 
			width = 250, 
			height = 50, 
			text = 'Shadow Color', 
			textscale = 2,
			centered = true
		}

		shadowcolorinput = newtextinput{
			x = 2250, 
			y = 500, 
			width = 200,
			height = 40, 
			centered = true,
			text = '#000000',
			onUnselect = function(i)

				if #i.text < 7 then
					local hex = string.format('#%02x%02x%02x', math.floor(dropShadowColor[1]*255), math.floor(dropShadowColor[2]*255), math.floor(dropShadowColor[3]*255))
					i.text = hex
				end

			end
		}

		shadowcolorpicker = newcolorpicker{
			x = 2250, 
			y = 270, 
			width = 200, 
			height = 200, 
			centered = true,
			allowHold = true, 
			selectedY = 1, 
			alpha = dropShadowColor[4],
			onHold = function(p)

				local mousex, mousey = love.mouse.getPosition()
				mousex = mousex + camera.x 
				mousey = mousey + camera.y 

				local slideradd = p.sliderHeight + p.sliderDistance

				if p.holdingpart == 'hue' then -- hue slider

					p.hue = clamp((mousex - p.x) / p.width, 0, 1)

				elseif p.holdingpart == 'picker' then -- picker

					p.selectedX = clamp((mousex - p.x) / p.width, 0, 1)
					p.selectedY = clamp((mousey - p.y - slideradd/2) / p.height, 0, 1)

				elseif p.holdingpart == 'alpha' then -- alpha slider

					p.alpha = clamp((mousex - p.x) / p.width, 0, 1)

				end

				updateTextColor()

				local hex = string.format('#%02x%02x%02x', math.floor(dropShadowColor[1]*255), math.floor(dropShadowColor[2]*255), math.floor(dropShadowColor[3]*255))
				shadowcolorinput.text = hex

			end
		}

		newtextinput{
			x = 1800, 
			y = 500,
			width = 150, 
			height = 40, 
			centered = true, 
			text = '315', 
			onInput = function(i, text)

				if text == '_backspace' then
					i.text = i.text:sub(1,-2)
				else
					if not tonumber(text) then return end
					i.text = i.text .. text
					local num = clamp(tonumber(i.text), 0, 360)
					dropShadowAngle = num
					i.text = tostring(num)
				end

				if #i.text > 0 then
					dropShadowAngle = tonumber(i.text)
				end

			end, 
			onUnselect = function(i)
				if #i.text < 1 then
					i.text = '315'
					dropShadowAngle = 315
				end
			end
		}

		newtext{
			x = 2000, 
			y = 400, 
			width = 150,
			height = 100,
			centered = true, 
			text = 'Shadow Distance',
			textscale = 2
		}

		newtextinput{
			x = 2000, 
			y = 500,
			width = 150, 
			height = 40, 
			centered = true, 
			text = '2', 
			onInput = function(i, text)

				if text == '_backspace' then
					i.text = i.text:sub(1,-2)
				else
					if not tonumber(text) then return end
					i.text = i.text .. text
					local num = clamp(tonumber(i.text), 0, 100)
					dropShadowDist = num
					i.text = tostring(num)
				end

				if #i.text > 0 then
					dropShadowDist = tonumber(i.text)
				end

			end, 
			onUnselect = function(i)
				if #i.text < 1 then
					i.text = '2'
					dropShadowDist = 2
				end
			end
		}

		newtext{
			x = 1800, 
			y = 400, 
			width = 150,
			height = 100,
			centered = true, 
			text = 'Shadow Angle',
			textscale = 2
		}

	end

	-- font
	do

		newbutton{
			x = 1200,
			y = 700, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Back',
			onClick = function(o)
				camera.moveTo(800, 0, 1, easing.outExpo)
			end
		}

		newbutton{
			x = 1200,
			y = 550, 
			width = 100,
			height = 50,
			centered = true,
			text = 'Font',
			onClick = function(o)
				camera.moveTo(800, 600, 1, easing.outExpo)
				preview.y = 800
			end
		}

		newbutton{
			x = 1100,
			y = 1150, 
			width = 150,
			height = 50,
			centered = true,
			text = 'Import \'font.ttf\' or \'font.otf\'',
			onClick = function(b)

				local name = 'font.ttf'
				local newfont = pcall(love.graphics.newFont, 'font.ttf')

				if not newfont then
					name = 'font.otf'
					newfont = pcall(love.graphics.newFont, 'font.otf')
				end

				if not newfont then

					fontnotifier.text = 'Couldn\'t find neither \'font.ttf\' nor \'font.otf\' in the working directory!'
					fontnotifier.textcolor = {1,0,0}

				else

					preview.font = love.graphics.newFont(name, fontSize)
					preview.textscale = 1

					fontnotifier.text = 'Successfully imported!'
					fontnotifier.textcolor = {0,1,0}

				end

			end
		}

		newbutton{
			x = 1100,
			y = 1075, 
			width = 150,
			height = 50,
			centered = true,
			text = 'Use default font', 
			onClick = function(b)

				previewrdfont = love.graphics.newFont('rdfont.otf', math.floor(fontSize/24*16+0.5))
				previewrdfont:setFilter('nearest', 'nearest')

				preview.font = previewrdfont
				preview.textscale = 2

				fontnotifier.text = 'Reverted back to default!'
				fontnotifier.textcolor = {0,1,0}

			end
		}

		newtext{
			x = 1300, 
			y = 1075, 
			width = 300, 
			height = 50, 
			centered = true, 
			text = 'Font Size', 
			textscale = 2
		}

		newtextinput{
			x = 1300,
			y = 1125, 
			width = 150,
			height = 50,
			centered = true,
			text = '24', 
			onInput = function(i, text)

				if text == '_backspace' then
					i.text = i.text:sub(1,-2)
					if #i.text > 0 then

						local num = clamp(tonumber(i.text), 1, 96)
						updateFontSize(num)
						i.text = tostring(num)

					end
				else

					if not tonumber(text) then return end
					if #i.text < 1 and text == '0' then return end

					i.text = i.text .. text

					local num = clamp(tonumber(i.text), 1, 96)
					updateFontSize(num)
					i.text = tostring(num)

				end

			end, 
			onUnselect = function(i)

				if #i.text < 1 then
					i.text = '24'
					updateFontSize(24)
				end

			end
		}

		fontnotifier = newtext{
			x = 1200,
			y = 750, 
			width = 600,
			height = 50,
			centered = true,
			text = '', 
			textscale = 2,
		}
	end

	-- title
	do
		newtext{
			x = 0, 
			y = 0, 
			width = 800, 
			height = 50, 
			text = 'Text Exporter v' .. _EXPORTERVERSION, 
			textscale = 4, 
			onDraw = function(t)

				t.x = t.x + camera.x
				t.y = t.y + camera.y

				love.graphics.setColor(0, 0, 0, 0.5)
				love.graphics.rectangle('fill', t.x, t.y, t.width, t.height)

				love.graphics.setColor(1, 1, 1, 1)
				default.onDrawText(t)

				t.x = t.x - camera.x
				t.y = t.y - camera.y

			end
		}
	end

	updateTextColor()

end

function love.textinput(text)
	if inputting then
		inputting:onInput(text)
	end
end

function love.keypressed(key)
	if inputting and key == 'backspace' then
		inputting:onInput('_backspace')
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	dragging = nil
end

function love.mousepressed(x, y, button, istouch, presses)

	if button > 1 then return end

	local tempinput = inputting
	inputting = nil
	dragging = nil

	for i=#objects,1,-1 do
		local o = objects[i]

		if mousetouching(o) then
			if o.onInput then
				inputting = o
				dragging = nil
				break
			elseif o.onHold then
				dragging = o
				inputting = nil
				break
			else
				if o.onClick then o:onClick() end
			end
		end
	end

	if tempinput and not inputting then
		if tempinput.onUnselect then tempinput:onUnselect() end
	end

end

function love.update(dt)

	camera.update()

	if love.mouse.isDown(1) then

		if dragging then
			dragging:onHold()
		end

	end

end

function love.draw()

	love.graphics.push()
	love.graphics.translate(-camera.x, -camera.y)

	for _,o in ipairs(objects) do

		if o.onDraw then o:onDraw() end
		love.graphics.setColor(1, 1, 1, 1)

	end

	love.graphics.pop()

end