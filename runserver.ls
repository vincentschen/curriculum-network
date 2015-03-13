{exec, which} = require 'shelljs'

for command in ['mongosrv', 'lsc', 'node-dev']
  if not which command
    console.log "missing #{command} command"
    process.exit()

exec 'mongosrv', {async: true}
exec 'lsc -cw .', {async: true}
exec 'node-dev app.ls', {async: true}
