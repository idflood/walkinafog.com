# Require node modules
sys = require("util")
fs = require("fs")
spawn = require("child_process").spawn
path = require("path")
url = require("url")
exec = require("child_process").exec
watch = require("watch")
express = require("express")
coffee = require("coffee-script")
stylus = require("stylus")
jade = require("jade")
nib = require("nib")
requirejs = require('requirejs')

io = require('socket.io')
main_socket = false

# Dirname to point to the project root
# @see: server.js
__dirname = global.basePath

# Utility functions
delay = (ms, func) -> setTimeout func, ms
exec_and_log = (command, on_complete = null) ->
  console.log "executing command: " + command
  exec command, (err, stdout, stderr) ->
    if err
      console.log "error: " + err
    console.log stdout + stderr
    if on_complete then delay 50, () => on_complete()

# Setup express server
app = express.createServer()
io = io.listen(app)
port = process.env.PORT || 3000
app.use app.router
app.use express.methodOverride()
app.use express.bodyParser()
app.set "views", __dirname + "/views"
app.set "view engine", "jade"

# Configure the stylus middleware (.styl -> .css)
app.use stylus.middleware(
  src: __dirname + "/src"
  dest: __dirname + "/public"
  compile: (str, path) ->
    stylus(str).set("filename", path).set("warn", true).set("compress", false).set("paths", [ require("stylus-blueprint") ]).use nib()
)
# Configure static assets
app.use express.static(__dirname + "/public")

# Serve on the fly compiled js or existing js if there is no .coffee
app.get "/scripts/*.coffee", (req, res) ->
  file = req.params[0]
  return_static = () ->
    path.exists "src/scripts/" + file + ".coffee", (exists) ->
      if exists
        res.header("Content-Type", "application/x-javascript")
        cs = fs.readFileSync("src/scripts/" + file + ".coffee", "utf8")
        res.send(cs)
      else
        # attempt to serve test file before doing a 404
        path.exists file + ".coffee", (exists) ->
          if exists
            res.header("Content-Type", "application/x-javascript")
            cs = fs.readFileSync(file + ".coffee", "utf8")
            res.send(cs)
          else
            res.send("Cannot GET " + "src/scripts/" + file + ".coffee", 404)
  
  return_static()

app.get "/scripts/*.js", (req, res) ->
  file = req.params[0]
  
  return_static = () ->
    path.exists "src/scripts/" + file + ".js", (exists) ->
      if exists
        res.header("Content-Type", "application/x-javascript")
        cs = fs.readFileSync("src/scripts/" + file + ".js", "utf8")
        res.send(cs)
      else
        res.send("Cannot GET " + "/scripts/" + file + ".js", 404)
  
  return_static()

# Setup html routes
app.get "/", (req, res) ->
  res.render "index",
    layout: false

app.get "/test", (req, res) ->
  res.render "test",
    layout: false

# Start the server
app.listen port

# Live reload
send_socket_refresh = () ->
  if main_socket
    console.log "emit refresh event!"
    main_socket.emit("reload")

io.sockets.on 'connection', (socket) ->
  main_socket = socket

watch.watchTree("src/scripts", {'ignoreDotFiles': true}, send_socket_refresh)


console.log "###################################################"
console.log ""
console.log "Server ready!"
console.log ""
console.log "Tests available at:"
console.log "http://localhost:#{port}/test"
console.log ""
console.log "Main url:"
console.log "http://localhost:#{port}/"
console.log ""
console.log "Live coding (automatically reload on file save):"
console.log "http://localhost:#{port}/?dev=true"
console.log ""
console.log "###################################################"

if process.argv[2] == "test"
  # Run continuous tests if "node server.js test"
  runTests = () -> exec_and_log "node ./src/scripts/server/testrunner.js"
  
  test_if_change = (f, curr, prev) ->
    # Skip testrunner.js changes to avoid infinite compilation
    if !f || f == "src/scripts/server/testrunner.js" then return
    if typeof f != "object" && prev != null && curr != null then runTests()
  watch.watchTree("src/scripts", {'ignoreDotFiles': true}, test_if_change)
  
  runTests()