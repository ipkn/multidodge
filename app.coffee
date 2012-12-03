express = require('express')
#routes = require('./routes')
#user = require('./routes/user')
http = require('http')
path = require('path')
nowjs = require('now')
connect = require('connect')
redisStore = require('connect-redis')(connect)

app = module.exports = express.createServer()

# Configuration

app.configure ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.favicon())
  app.use(express.logger('dev'))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.cookieParser('jfj32*#&hfi83*#*'))
  app.use(express.session({secret:'jfkj(32Hfi9('}))
  app.use(require('express-coffee')({ debug:true,path: __dirname + '/public',}))
  app.use(app.router)
  app.use(express.static(path.join(__dirname, 'public')))

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

# Routes

app.get '/', (req, res)->
  res.render('main', {title:"Multiplayer Dodge"})

everyone = nowjs.initialize app
enow = everyone.now
enow.users = []

game = require('./gamelib/game')(enow)

enow.helloServer = ->
	console.log 'new user',@user.clientId
	game.newConnection(this)

tools = require './public/coffeescripts/tools.coffee'


#everyone.now.observe = (roomid, userid) ->
	#@now.doObserve()
#everyone.now.readyToPlay = (roomid, userid) ->
	#nowjs.getGroup("room#{roomid}").addUser @user.clientId

app.listen 40038, ->
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)
