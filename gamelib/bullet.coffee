class Bullet
	constructor: (@id, @x=0, @y=0, @vx=0, @vy=0, @ax=0, @ay=0, @r = Math.random()+Math.random()+2) ->

	update: (delta = 1.0/60)->
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta

	isLive: (worldSize) ->
		@x*@x+@y*@y<=(worldSize+100)*(worldSize+100)

	pushAway: (from, force) ->
		dx = from.x - @x
		dy = from.y - @y
		dsize = Math.sqrt(dx*dx + dy*dy)
		if dsize
			dx /= dsize
			dy /= dsize
			@vx -= dx * force * 3 / @r
			@vy -= dy * force * 3 / @r


module.exports =
	Bullet: Bullet
