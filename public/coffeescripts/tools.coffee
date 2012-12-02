BASE_WORLD_SIZE = 50
BULLET_PER_USER = 100

module.exports =
	computeBulletCount: (userCount) ->
		userCount * BULLET_PER_USER
	computeWorldSize: (userCount) ->
		BASE_WORLD_SIZE*Math.sqrt(userCount)
