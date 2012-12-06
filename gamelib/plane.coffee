class Plane
	constructor: (@id, @x=0, @y=0, @vx=0, @vy=0, @ax=0, @ay=0, @dir=0, @targetX=0, @targetY=0, @firing=false, @dead=false, @deadCount=0, @startTime = (new Date()).getTime(), @exciting=0, @maxExciting=0, @kill=0, @maxMana=100, @mana=0, @manaRegen=160.0/60, @manaCost=280.0/60) ->

	computePlayTime: ->
		if not @dead
			@playTime = (new Date()).getTime() - @startTime

	die: (cb) ->
		@dead = true
		@exciting = 0
		@deadCount++
		delayed = =>
			@revive()
			cb this
		setTimeout delayed, 5000

	revive: ->
		@dead = false

	update: (delta = 1.0/60)->
        # update position
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta
		@vx *= 0.8
		@vy *= 0.8

		# update stats
		if @firing
			if @mana < @manaCost
				@firing = false
			else
				@mana = Math.max 0, @mana - @manaCost
		else
			@mana = Math.min @maxMana, @mana+@manaRegen

	distance: (another) ->
		dx = another.x - @x
		dy = another.y - @y
		return Math.sqrt(dx*dx+dy*dy)
	
	near: (another, d) ->
		dx = another.x - @x
		dy = another.y - @y
		(-d < dx < d) and (-d < dy < d) and dx*dx+dy*dy < d*d
		

	angularDiff: (another) ->
		dx = another.x - @x
		dy = another.y - @y
		return Math.atan2(dy, dx) - @dir

	setClient: (@client) ->

module.exports =
	Plane: Plane
