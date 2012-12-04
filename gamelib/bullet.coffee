class Bullet
	constructor: (@id, @x=0, @y=0, @vx=0, @vy=0, @ax=0, @ay=0, @r = Math.random()+Math.random()+1+Math.random()) ->
		@impact = {}

	update: (delta = 1.0/60)->
		@vx += @ax*delta
		@vy += @ay*delta
		@x += @vx*delta
		@y += @vy*delta

	checkReflect: (worldSize)->
		if (worldSize*worldSize+5< @x*@x+@y*@y) and (@vx*@vx+@vy*@vy>180*180)
			@vx = @vx*0.9
			@vy = @vy*0.9
			tx = @y
			ty = -@x
			tt = Math.sqrt(tx*tx+ty*ty)
			tx /= tt
			ty /= tt
			cross = tx*@vy - ty * @vx
			@vx = @vx + 2*cross * ty
			@vy = @vy - 2*cross * tx
			@x += @vx/60
			@y += @vy/60
			return true
		return false

	isLive: (worldSize) ->
		@x*@x+@y*@y<=(worldSize+100)*(worldSize+100)

	getDealer: ->
		t = (new Date()).getTime()
		oldIds=[]
		maxid = null
		for id, [dmg, timing] of @impact
			if timing + 10000 < t
				oldIds.push id
			else if not maxid? or dmg > @impact[maxid][0]
				maxid = id

		for id in oldIds
			delete @impact[id]

		if not maxid?
			return []
		ret = [maxid]
		for id, [dmg, timing] of @impact
			if maxid != id
				ret.push id
		return ret

	pushAway: (from, force) ->
		@impact[from.id]?=[0,0]
		if @impact[from.id][1] + 10000<(new Date()).getTime()
			@impact[from.id][0]=0
		@impact[from.id][0]+=force
		@impact[from.id][1]=(new Date()).getTime()
		dx = from.x - @x
		dy = from.y - @y
		dsize = Math.sqrt(dx*dx + dy*dy)
		if dsize
			dx /= dsize
			dy /= dsize
			@vx -= dx * force * 3 / @r / @r
			@vy -= dy * force * 3 / @r / @r


module.exports =
	Bullet: Bullet
