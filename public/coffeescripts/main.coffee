PI = Math.PI
BASE_RADIUS = 300
MAX_SPEED = 50
getContext = ->
	ctx = $('#maincanvas')[0].getContext('2d')
	ctx.canvas.width = window.innerWidth
	ctx.canvas.height = window.innerHeight
	ctx.setTransform(1,0,0,1,window.innerWidth/2, window.innerHeight/2)
	ctx
flipCanvas = ->
	return
	mainctx = $('#maincanvas')[0].getContext('2d')
	viewctx = $('#viewcanvas')[0].getContext('2d')
	w = viewctx.canvas.width = window.innerWidth
	h = viewctx.canvas.height = window.innerHeight
	#viewctx.clearRect 0,0,w,h
	viewctx.drawImage mainctx.canvas,0,0

time = ->
	return (new Date).getTime()

keyboardHandler =
	87: 'up'
	65: 'left'
	83: 'down'
	68: 'right'

game = null
myPlaneId = null

now.killedBy = (planeId, dealer) ->
	game.killedBy planeId, dealer
	
now.youDead = ->
	game.die()

now.updateBullet = (bullet) ->
	game.world.updateBullet bullet

now.deleteBullet = (id) ->
	game.world.deleteBullet id

now.updatePlaneCount = (planeCount) ->
	game.world.updatePlaneCount planeCount

now.updatePlane = (plane) ->
	game.world.updatePlane(plane)

now.deletePlane = (id) ->
	game.world.deletePlane id

now.notifyMyPlane = (planeId) ->
	myPlaneId = planeId
	console.log "i am plane", myPlaneId

now.pingTime = 100
now.pong = (t) ->
	now.pingTime = now.pingTime * 0.5 + (time()-t)/2*0.5
	
class Entity
	constructor: (meta) ->

class Bullet extends Entity
	constructor: (meta) ->
		@id = meta.id
		@x = meta.x
		@y = meta.y
		@vx = meta.vx
		@vy = meta.vy
		@ax = meta.ax
		@ay = meta.ay
		@r = meta.r

	update: (delta=1/60) ->
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta

	render: (ctx) ->
		ctx.beginPath()
		ctx.arc(@x,@y,@r,0,2*Math.PI)
		ctx.closePath()
		ctx.stroke()
		ctx.fill()
		
class Plane extends Entity
	constructor: (meta) ->
		@id = meta.id
		@x = meta.x
		@y = meta.y
		@vx = meta.vx
		@vy = meta.vy
		@ax = meta.ax
		@ay = meta.ay
		@dir = meta.dir
		@targetX = meta.targetX
		@targetY = meta.targetY
		@firing = meta.firing
		@dead = meta.dead
		@deadCount = meta.deadCount
		@playTime = meta.playTime
		@playTime ?= 0
		@exciting = meta.exciting
		@maxExciting = meta.maxExciting
		@name = meta.name
		@kill = meta.kill
	isMe: ->
		@id == myPlaneId
	update: (delta = 1.0/60)->
		# update position
		@vx += @ax*delta
		@vy += @ay*delta
		vsize = Math.sqrt (@vx*@vx + @vy*@vy)
		if vsize > MAX_SPEED
			@vx = @vx * MAX_SPEED / vsize
			@vy = @vy * MAX_SPEED / vsize
		@x += @vx*delta
		@y += @vy*delta
		@vx *= 0.8
		@vy *= 0.8

		# update direction
		#if not @firing
		if @targetX == @x and @targetY == @y
			@targetDir = @dir
		else
			@targetDir = Math.atan2 @targetY-@y, @targetX-@x
		if @targetDir != @dir
			ANGULAR_SPEED = 10 * PI / 180
			angleDiff = @targetDir - @dir
			angleDiff += 2*PI while angleDiff < -PI
			angleDiff -= 2*PI while angleDiff >= +PI
			if angleDiff >= 0
				if angleDiff < ANGULAR_SPEED
					@dir = @targetDir
				else
					@dir += ANGULAR_SPEED
			else
				if angleDiff > -ANGULAR_SPEED
					@dir = @targetDir
				else
					@dir -= ANGULAR_SPEED

	render: (ctx) ->
		if @dead
			ctx.globalAlpha = 0.3
		ctx.beginPath()
		LONG_RADIUS = 13
		SHORT_RADIUS = 5
		ctx.fillStyle = '#ffffff'
		ctx.arc(@x, @y, 2, 0, 2*PI)
		ctx.fill()
		ctx.fillStyle = '#000000'
		ctx.moveTo(@x + Math.cos(@dir)*LONG_RADIUS, @y + Math.sin(@dir)*LONG_RADIUS)
		ctx.lineTo(@x + Math.cos(@dir+PI*2/3)*SHORT_RADIUS, @y + Math.sin(@dir+PI*2/3)*SHORT_RADIUS)
		ctx.lineTo(@x + Math.cos(@dir-PI*2/3)*SHORT_RADIUS, @y + Math.sin(@dir-PI*2/3)*SHORT_RADIUS)
		ctx.lineTo(@x + Math.cos(@dir)*LONG_RADIUS, @y + Math.sin(@dir)*LONG_RADIUS)
		ctx.closePath()
		ctx.stroke()
		if @isMe()
			ctx.fillStyle = '#16f'
		ctx.fill()
		ctx.fillStyle = '#000000'
		t = time()/10 % 30
		if time() - @lookOverTime < 1000 and @name?
			ctx.textAlign = 'center'
			ctx.font = '12px helvetica'
			ctx.fillText @name, @x, @y+20
		if @firing and not @dead
			for x in [0, 30, 60, 90]
				if x == 90
					cv = Math.floor(t*255/30)
					ctx.strokeStyle = "rgb("+cv+","+cv+","+cv+")"
					#ctx.strokeStyle = 'rgb(0,255,0)'
				ctx.beginPath()
				ctx.arc(@x, @y, x+t, @dir-PI/6, @dir+PI/6)
				ctx.stroke()
		ctx.strokeStyle = '#000000'
		ctx.fillStyle = '#000000'
		ctx.globalAlpha = 1.0
		if @dead and @isMe()
			ctx.textAlign = 'center'
			ctx.font = '20px helvetica'
			ctx.fillText("You died " + @deadCount + " time(s).",0,0)


class Player extends Plane
	constructor: (meta) ->
		super meta
		@directions = {}
	startFiring: ->
		now.startFiring @dir
		@firing = true
	endFiring: ->
		now.endFiring @dir
		@firing = false

	die: ->
		# do nothing?
		console.log 'ARGH!!!! I died!!!', @deadCount
		
	look: (x,y) ->
		@targetX = x
		@targetY = y
		if now.syncTarget?
			if @lastLook?
				if time() - @lastLook < 150 or @firing and time() - @lastLook < 100
					return
			@lastLook = time()
			#now.syncPosition @x, @y, @vx, @vy, @ax, @ay
			now.syncTarget x, y, @dir
	accelerate: (direction, onoff) ->
		if onoff
			@directions[direction] = 1
		else
			@directions[direction] = 0
		dx=0
		dy=0
		for dir, onoffState of @directions
			if onoffState
				if dir == 'left'
					dx -= 1
				else if dir == 'right'
					dx += 1
				else if dir == 'up'
					dy -= 1
				else if dir == 'down'
					dy += 1
		dsize = Math.sqrt (dx*dx+dy*dy)
		if dsize > 0
			@ax = dx / dsize*600
			@ay = dy / dsize*600
		else
			@ax = 0
			@ay = 0
		if now.syncPosition?
			now.syncPosition @x, @y, @vx, @vy, @ax, @ay
		if @lastdx != dx or @lastdy != dy
			console.log dx, dy
			@lastdx = dx
			@lastdy = dy

	update: (delta = 1.0/60) ->
		super delta


class World
	constructor: ->
		@planes = {}
		@bullets = {}
	update: ->
		for id, plane of @planes
			plane.update()
			x=plane.x
			y=plane.y
			w = @computeWorldSize()
			if x*x+y*y > w*w
				d=Math.sqrt(x*x+y*y)
				plane.x *= w/d
				plane.y *= w/d

		for id, bullet of @bullets
			bullet.update()
	computeWorldSize: ->
			Math.sqrt(1+0.1*@planeCount) * BASE_RADIUS
	renderBackground: (ctx)->
		if not @planeCount?
			return
		if not @lastRenderedBackgroundSize?
			@lastRenderedBackgroundSize = @computeWorldSize()
		w = ctx.canvas.width
		h = ctx.canvas.height
		ctx.globalCompositeOperation = 'source-over'
		ctx.fillStyle="#ffefc0"
		ctx.fillRect -w/2, -h/2, w, h
		ctx.globalCompositeOperation = 'destination-out'
		ctx.beginPath()
		targetRadius = @computeWorldSize()
		if Math.abs(targetRadius - @lastRenderedBackgroundSize) < 10
			@lastRenderedBackgroundSize = targetRadius
		if @lastRenderedBackgroundSize < targetRadius
			@lastRenderedBackgroundSize += 10
		else if @lastRenderedBackgroundSize > targetRadius
			@lastRenderedBackgroundSize -= 10
		ctx.arc(0,0,@lastRenderedBackgroundSize,0,2*Math.PI)
		#ctx.arc(0,0,600,0,2*Math.PI)
		ctx.closePath()
		ctx.stroke()
		ctx.fill()
		ctx.globalCompositeOperation = 'destination-over'
		ctx.fillStyle="#000000"
	render: (ctx) ->
		@renderBackground(ctx)

		for id, plane of @planes
			plane.render(ctx)

		for id, bullet of @bullets
			bullet.render(ctx)

	deleteBullet: (id) ->
		delete @bullets[id]

	updateBullet: (bullet) ->
		newBullet = new Bullet(bullet)
		old = @bullets[newBullet.id]
		@bullets[newBullet.id] = newBullet

	deletePlane: (id) ->
		delete @planes[id]

	updatePlaneCount: (@planeCount) ->
		
	updatePlane: (plane) ->
		if plane.id of @planes
			# update plane data
			if plane.id != myPlaneId and plane.id of @planes
				@planes[plane.id] = new Plane(plane)
				#@planes[newPlane.id].sync plane
			else
				@planes[plane.id].kill = plane.kill
				@planes[plane.id].dead = plane.dead
				@planes[plane.id].deadCount = plane.deadCount
				@planes[plane.id].playTime = plane.playTime
				@planes[plane.id].exciting = plane.exciting
				@planes[plane.id].maxExciting = plane.maxExciting
		else
			# new plane appear
			if plane.id == myPlaneId
				newPlane = new Player(plane)
			else
				newPlane = new Plane(plane)
			@planes[newPlane.id] = newPlane
	getMyPlane: ->
		if myPlaneId?
			return @planes[myPlaneId]
		return null

class Game
	constructor: (fps=60)->
		@fps = fps
		@nextGameTick = time()
		@fpsData = []
		@skipTicks = 1000.0/fps
		@world = new World
		now.helloServer()

	killedBy: (planeId, dealer) ->
		@killMsgIndex ?= 0
		@killMsgIndex++
		killed = @world.planes[planeId]
		if not killed?
			return
		kills = ''
		if dealer.length == 0
			kills = '(environment)'
		else
			kills = ''
			killsCount = 0
			for id in dealer
				p = @world.planes[id]
				if not p?
					if killsCount == 0
						killsCount = 1
					continue
				if not p.name?
					if killsCount == 0
						killsCount = 1
					continue
				if killsCount == 0
					if p.id == myPlaneId
						kills = '<span style="color:#19f">'+ p.name + '</span>'
					else
						kills = p.name
				else if second
					kills += ' ('
					if p.id == myPlaneId
						kills += '<span style="color:#19f">'+ p.name + '</span>'
					else
						kills += p.name
				else
					kills += ', '
					if p.id == myPlaneId
						kills += '<span style="color:#19f">'+ p.name + '</span>'
					else
						kills += p.name
				killsCount++
			if killsCount > 1
				kills += ')'

			if kills == ''
				kills = '(unknown)'
		killedName = killed.name
		if killed.id == myPlaneId
			killedName = '<span style="color:#19f">'+ killedName + '</span>'

		$('#killStat').append("""<div id='kmsg#{@killMsgIndex}'>#{kills} -> #{killedName}</div>""")
		msgIndex = @killMsgIndex
		setTimeout (=> $('#kmsg'+msgIndex).remove()), 10000
	update: ->
		@world.update()
		p = @world.getMyPlane()
		if not p?
			return
		s = ''
		s += 'WSAD to move, Click to push bullets<br>'
		s += 'I am Plane '+p.id+'<br>'
		v = []
		for idx, plane of @world.planes
			if not plane.playTime?
				continue
			v.push [plane.kill,plane.deadCount,plane.id]
		v.sort (l,r)->
			if l[0] < r[0]
				return 1
			if l[0] > r[0]
				return -1
			if l[1] < r[1]
				return -1
			if l[1] > r[1]
				return 1
			if l[2] < r[2]
				return 1
			if l[2] > r[2]
				return -1
		s += '<br>Rank by kill<br>'
		i = 0
		while i < 10 and i < v.length
			if v[i][2] == myPlaneId
				s += '<span style="color:#19f">'
			p = @world.planes[v[i][2]]
			if p.name?
				s += p.name
			else
				s += 'Plane ' + v[i][2]
			s += ' : '
			s += v[i][0]
			s += ' / ' + v[i][1] + '<br>'
			if v[i][2] == myPlaneId
				s += '</span>'
			i+=1
		v = []
		for idx, plane of @world.planes
			if not plane.playTime?
				continue
			v.push [(plane.playTime - plane.deadCount*5000) / (plane.deadCount+1), plane.id]
		v.sort (l,r)->
			return - l[0] + r[0]
		s += '<br>Rank by avg play time per life<br>'
		i = 0
		while i < 10 and i < v.length
			if v[i][1] == myPlaneId
				s += '<span style="color:#19f">'
			p = @world.planes[v[i][1]]
			if p.name?
				s += p.name
			else
				s += 'Plane ' + v[i][1]
			s += ' : '
			s += (v[i][0]/1000).toFixed(1)
			s += ' / ' + @world.planes[v[i][1]].deadCount + '<br>'
			if v[i][1] == myPlaneId
				s += '</span>'
			i+=1
		s += '<br>Rank by exciting(비비기,절묘도)<br>score : max (current)<br>'
		v = []
		for idx, plane of @world.planes
			if not plane.exciting?
				continue
			v.push [plane.maxExciting, plane.id]
		v.sort (l,r)->
			return - l[0] + r[0]
		i = 0
		while i < 10 and i < v.length
			if v[i][1] == myPlaneId
				s += '<span style="color:#19f">'
			p = @world.planes[v[i][1]]
			if p.name?
				s += p.name
			else
				s += 'Plane ' + v[i][1]
			s += ' : '
			s += p.maxExciting.toFixed(3)
			s += ' (' + p.exciting.toFixed(3) + ')<br>'
			if v[i][1] == myPlaneId
				s += '</span>'
			i+=1
		$('#rankStat').html(s)

	die: ->
		@world.getMyPlane().die()
		
	look: (x,y)->
		if not @ctx?
			return
		x -= @ctx.canvas.width / 2
		y -= @ctx.canvas.height / 2
		if @world.getMyPlane()?
			@world.getMyPlane().look x,y
		for idx,plane of @world.planes
			dx = plane.x - x
			dy = plane.y - y
			if dx*dx+dy*dy < 50*50
				plane.lookOverTime = time()
	startFiring: ->
		if @world.getMyPlane()?
			@world.getMyPlane().startFiring()
		
	endFiring: ->
		if @world.getMyPlane()?
			@world.getMyPlane().endFiring()

	processCommand: (dir, onoff) ->
		if @world.getMyPlane()?
			@world.getMyPlane().accelerate dir, onoff

	render: ->
		@ctx = getContext()
		testrender = (ctx) ->
			w = ctx.canvas.width
			h = ctx.canvas.height
			ctx.beginPath()
			ctx.arc Math.random()*w, Math.random()*h, Math.random()*50+50,0,2*3.141592
			ctx.closePath()
			ctx.stroke()
		#testrender(@ctx)
		@world.render(@ctx)
		@updateFps()

	updateFps: ->
		currentTime = time()
		idx = 0
		while idx < @fpsData.length
			if @fpsData[idx] + 1000 < currentTime
				@fpsData[idx] = @fpsData[@fpsData.length-1]
				@fpsData.pop()
			else
				idx += 1

		@fpsData.push(currentTime)
		$("#fpsText").text(@fpsData.length)

	start: ->
		onEachFrame =>
			@gameloop()

	gameloop: ->
		updateProcessed = 0
		MAX_FRAME_SKIP = 10
		while time() > @nextGameTick and updateProcessed < MAX_FRAME_SKIP
			@update()
			updateProcessed += 1
			@nextGameTick += @skipTicks

		if updateProcessed
			@render()
			flipCanvas()
		#else # for interpolation
		# @render (new Date()).getTime() - @nextGameTick


if window.webkitRequestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			window.webkitRequestAnimationFrame(_cb)
		_cb()
else if window.mozRequestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			window.mozRequestAnimationFrame(_cb)
		_cb()
else if window.requestAnimationFrame
	onEachFrame = (cb) ->
		_cb = =>
			cb()
			window.requestAnimationFrame(_cb)
		_cb()
else
	onEachFrame = (cb) ->
		setInterval cb, 1000/60

myName = prompt('what is your name')
now.ready ->
	now.name = myName
	$(document).ready ->
		$(document).keydown (e) ->
			if keyboardHandler[e.which]?
				game.processCommand keyboardHandler[e.which], true
		$(document).keyup (e) ->
			if keyboardHandler[e.which]?
				game.processCommand keyboardHandler[e.which], false
		$('#rankStat').keydown (e) ->
			if keyboardHandler[e.which]?
				game.processCommand keyboardHandler[e.which], true
		$('#rankStat').keyup (e) ->
			if keyboardHandler[e.which]?
				game.processCommand keyboardHandler[e.which], false
		$(document).mousemove (e) ->
			x = e.pageX
			y = e.pageY
			game.look(x,y)
		$(document).mousedown (e) ->
			game.startFiring()
		$(document).mouseup (e) ->
			game.endFiring()
		game = new Game()
		game.start()
		# fast ping adaption
		for x in [0..5]
			now.ping time()
		setInterval (->
			if now.ping?
				now.ping time()), 5000
		setInterval (->
			p = game.world.getMyPlane()
			if p?
				if now.syncPosition?
					now.syncPosition p.x, p.y, p.vx, p.vy, p.ax, p.ay), 500

