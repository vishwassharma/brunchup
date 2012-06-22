sysPath = require 'path'
path = 'public'

index = (req, res, next) ->
  console.log "[App] Rendering '/' uri"
  res.sendfile sysPath.join path, 'index.html'

login = (req, res, next) ->
  console.log "[App] Rendering '/login' uri"
  res.sendfile sysPath.join path, 'login.html'

exports.index = index
exports.login = login
