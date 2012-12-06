plane = require('./plane')
bullet = require('./bullet')
space = require('./space')
NEW_BULLET_SPEED_RANGE_LIST = [[50, 50], [30,60],[100,120]]
VIRTUAL_USER_COUNT = 0
BASE_WORLD_SIZE = 300
BULLET_PER_PLANE = 60#130
MAX_BULLET_PUSH_POWER = 48#24#12

flipCoin = (p) ->
	Math.random() < p

world = null

class World
	constructor: (@now) ->
		@planes = {}
		@bullets = {}
		@bulletSpace = new space.Space()
		@planeId = 1
		@bulletId = -1
		@planeCount = VIRTUAL_USER_COUNT

		world = this

		@now.syncPosition = (x, y, vx, vy, ax, ay) ->
			world.syncPosition this, x, y, vx, vy, ax, ay

		@now.syncTarget = (x, y, dir) ->
			world.syncTarget this, x, y, dir

		@now.startFiring = (dir) ->
			world.syncFire this, dir, true

		@now.endFiring = (dir) ->
			world.syncFire this, dir, false

	#player sync
	syncPosition: (client, x, y, vx, vy, ax, ay) ->
		id = client.user.id
		pingTime = client.now.pingTime
		syncPlane = @planes[id]
		if syncPlane?
			#dx = syncPlane.x-x
			#dy = syncPlane.y-y
			#if dx*dx+dy*dy > 25
				#console.log Math.sqrt(dx*dx+dy*dy)
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
			syncPlane.dir = dir
			@now.updatePlane syncPlane

	syncFire: (client, dir, onoff) ->
		id = client.user.id
		pingTime = client.now.pingTime
		syncPlane = @planes[id]
		if syncPlane?
			syncPlane.dir = dir
			syncPlane.firing = onoff
			@now.updatePlane syncPlane

	computeWorldSize: ->
		return Math.max(100,Math.sqrt(1+0.1*@planeCount) * BASE_WORLD_SIZE)

	computeTotalBulletCount: ->
		return (1+@planeCount*0.2) * BULLET_PER_PLANE

	update: ->
		# update bullet positions and kill far away bullets
		currentBulletCount = 0
		toDie = []
		updatedPlanes = {}
		updatedBullets = {}
		for idx, eachBullet of @bullets
			if eachBullet.isLive(@computeWorldSize())
				if eachBullet.checkReflect @computeWorldSize()
					updatedBullets[idx] = eachBullet

				eachBullet.update()
				@bulletSpace.update eachBullet
				currentBulletCount++
			else
				@bulletSpace.remove eachBullet
				toDie.push idx

		for idx in toDie
			delete @bullets[idx]
			if @now.deleteBullet?
				@now.deleteBullet idx

		# create new bullet
		totalBulletCount = @computeTotalBulletCount()
		while currentBulletCount < totalBulletCount
			newBullet = @createBullet()
			@bulletSpace.add newBullet
			currentBulletCount++

		# push bullets by plane
		for _, plane of @planes

			plane.computePlayTime()
			if plane.dead
				continue
			@bulletSpace.foreach2 plane.x,plane.y,10, (bullet) =>
				if plane.near(bullet, 4)
					dealer = bullet.getDealer()
					if dealer.length > 0 and @planes[dealer[0]]?
						@planes[dealer[0]].kill += 1
					plane.client.now.youDead()
					plane.die(@now.updatePlane)
					updatedPlanes[plane.id]=plane
					@now.killedBy plane.id, dealer
				else if plane.near(bullet, 10)
					d = (plane.distance bullet)
					plane.exciting += 1/d/d
					if plane.maxExciting < plane.exciting
						plane.maxExciting = plane.exciting
					updatedPlanes[plane.id]=plane

			if plane.firing and not plane.dead
				updated={}
				@bulletSpace.foreach2 plane.x,plane.y,120, (bullet) =>
					if plane.near(bullet, 120) and not updated[bullet.id]?
						updated[bullet.id] = 1
						angularDiff = plane.angularDiff bullet
						angularDiff += 2*Math.PI while angularDiff < -Math.PI
						angularDiff -= 2*Math.PI while angularDiff > +Math.PI
						if Math.abs(angularDiff) < Math.PI/6
							bullet.pushAway plane, (120-plane.distance(bullet))*MAX_BULLET_PUSH_POWER/120
							@bulletSpace.update bullet
							updatedBullets[bullet.id] = bullet

			plane.update()
			x=plane.x
			y=plane.y
			w = @computeWorldSize()
			if x*x+y*y > w*w
				d=Math.sqrt(x*x+y*y)
				plane.x *= w/d
				plane.y *= w/d
		for idx, plane of updatedPlanes
			@now.updatePlane plane
		for idx, bullet of updatedBullets
			@now.updateBullet bullet

	onDisconnect: (client) ->
		@deletePlane client.user.id

	deletePlane: (id) ->
		delete @planes[id]
		@planeCount--
		@now.deletePlane id
		@now.updatePlaneCount @planeCount

	createPlane: (client) ->
		id = @planeId
		@planeId++
		@planes[id] = newPlane = new plane.Plane(id)
		@planeCount++
		console.log client, id, 'active user',@planeCount
		@now.updatePlaneCount @planeCount

		newPlane.setClient client
		newPlane.name = client.now.name
		client.user.id = id
		client.now.notifyMyPlane id
		@now.updatePlane newPlane
		bc=0
		for idx, eachBullet of @bullets
			client.now.updateBullet eachBullet
			bc++
		for idx, eachPlane of @planes
			client.now.updatePlane eachPlane

		newPlane

	createBullet: ->
		id = @bulletId
		@bulletId--

		newBullet = null
		isAimedShot = flipCoin 0.2
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
				vx = ex-sx
				vy = ey-sy
				vsize = Math.sqrt(vx*vx + vy*vy)
				vx/=vsize
				vy/=vsize
				speedPick = Math.floor(Math.random() * NEW_BULLET_SPEED_RANGE_LIST.length)
				speedRange = NEW_BULLET_SPEED_RANGE_LIST[speedPick]
				speed = Math.random() * (speedRange[1] - speedRange[0]) + speedRange[0]
				#speed = Math.random() * (NEW_BULLET_SPEED_RANGE[1] - NEW_BULLET_SPEED_RANGE[0]) + NEW_BULLET_SPEED_RANGE[0]
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
			speedPick = Math.floor(Math.random() * NEW_BULLET_SPEED_RANGE_LIST.length)
			speedRange = NEW_BULLET_SPEED_RANGE_LIST[speedPick]
			speed = Math.random() * (speedRange[1] - speedRange[0]) + speedRange[0]
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
