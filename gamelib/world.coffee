plane = require('./plane')
bullet = require('./bullet')
NEW_BULLET_SPEED_RANGE = [30, 150]
VIRTUAL_USER_COUNT = 0
BASE_WORLD_SIZE = 300
BULLET_PER_PLANE = 100

flipCoin = (p) ->
	Math.random() < p

world = null

class World
	constructor: (@now) ->
		setTimeout (=> @createBullet()), 1000/60
		@planes = {}
		@bullets = {}
		@planeId = 1
		@bulletId = -1
		@planeCount = VIRTUAL_USER_COUNT

		world = this

		@now.syncPosition = (x, y, vx, vy, ax, ay) ->
			world.syncPosition this, x, y, vx, vy, ax, ay

		@now.syncTarget = (x, y, dir) ->
			world.syncTarget this, x, y, dir

	#player sync
	syncPosition: (client, x, y, vx, vy, ax, ay) ->
		id = client.user.id
		pingTime = client.now.pingTime
		syncPlane = @planes[id]
		if syncPlane?
			syncPlane.x = x
			syncPlane.y = y
			syncPlane.vx = vx
			syncPlane.vy = vy
			syncPlane.ax = ax
			syncPlane.ay = ay
			@now.updatePlane syncPlane

	syncTarget: (client, x, y, dir) ->
		id = client.user.id
		pingTime = client.now.pingTime
		syncPlane = @planes[id]
		if syncPlane?
			syncPlane.targetX = x
			syncPlane.targetY = y
			@now.updatePlane syncPlane

	computeWorldSize: ->
		return Math.max(100,Math.sqrt(@planeCount) * BASE_WORLD_SIZE)

	computeTotalBulletCount: ->
		return @planeCount * BULLET_PER_PLANE

	update: ->
		# update bullet positions and kill far away bullets
		currentBulletCount = 0
		toDie = []
		for idx, eachBullet of @bullets
			if eachBullet.isLive(@computeWorldSize())
				eachBullet.update()
				currentBulletCount++
			else
				toDie.push idx

		for idx in toDie
			delete @bullets[idx]
			if @now.deleteBullet?
				@now.deleteBullet idx

		# create new bullet
		totalBulletCount = @computeTotalBulletCount()
		while currentBulletCount < totalBulletCount
			@createBullet()
			currentBulletCount++

	onDisconnect: (client) ->
		@deletePlane client.user.id

	deletePlane: (id) ->
		delete @planes[id]
		@planeCount--
		@now.deletePlane id
		@now.updatePlaneCount @planeCount

	createPlane: (client) ->
		id = @planeId
		console.log client, id
		@planeId++
		@planes[id] = newPlane = new plane.Plane(id)
		@planeCount++
		@now.updatePlaneCount @planeCount

		newPlane.setClient client
		client.user.id = id
		client.now.notifyMyPlane id
		@now.updatePlane newPlane

		newPlane

	createBullet: ->
		id = @bulletId
		@bulletId--

		newBullet = null
		isAimedShot = flipCoin 0.3
		if isAimedShot
			n = 0
			pickedPlane = null
			for idx, eachPlane of @planes
				n += 1
				if flipCoin 1/n
					pickedPlane = eachPlane
			if pickedPlane
				worldSize = @computeWorldSize()
				dir1 = Math.random() * 2 * Math.PI
				dist = worldSize
				sx = dist * Math.cos(dir1)
				sy = dist * Math.sin(dir1)
				ex = pickedPlane.x + Math.random() * 50
				ey = pickedPlane.y + Math.random() * 50
				ex = pickedPlane.x
				ey = pickedPlane.y
				vx = ex-sx
				vy = ey-sy
				vsize = Math.sqrt(vx*vx + vy*vy)
				vx/=vsize
				vy/=vsize
				speed = Math.random() * (NEW_BULLET_SPEED_RANGE[1] - NEW_BULLET_SPEED_RANGE[0]) + NEW_BULLET_SPEED_RANGE[0]
				vx *= speed
				vy *= speed
				newBullet = new bullet.Bullet(
					id,
					sx,
					sy,
					vx,
					vy,
					0,
					0
				)
		# random or fail to create by another method
		if not newBullet?
			worldSize = @computeWorldSize()
			dir1 = Math.random() * 2 * Math.PI
			dir2 = dir1
			dir2 = Math.random() * 2 * Math.PI while Math.abs(dir1 - dir2) < Math.PI/4
			dist = worldSize
			sx = dist * Math.cos(dir1)
			sy = dist * Math.sin(dir1)
			ex = dist * Math.cos(dir2)
			ey = dist * Math.sin(dir2)
			vx = ex-sx
			vy = ey-sy
			vsize = Math.sqrt(vx*vx + vy*vy)
			vx/=vsize
			vy/=vsize
			speed = Math.random() * (NEW_BULLET_SPEED_RANGE[1] - NEW_BULLET_SPEED_RANGE[0]) + NEW_BULLET_SPEED_RANGE[0]
			vx *= speed
			vy *= speed
			newBullet = new bullet.Bullet(
				id,
				sx,
				sy,
				vx,
				vy,
				0,
				0
			)

		@bullets[id] = newBullet

		if @now.updateBullet?
			@now.updateBullet newBullet

		newBullet

module.exports =
	World: World
