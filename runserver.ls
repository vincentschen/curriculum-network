{exec, which} = require 'shelljs'
{existsSync} = require 'fs'

for command in ['mongosrv', 'lsc', 'node-dev']
  if not which command
    console.log "missing #{command} command"
    process.exit()

exec 'mongosrv', {async: true}
exec 'lsc -cw .', {async: true}
exec 'node-dev app.ls', {async: true}

#if existsSync '/vagrant' and existsSync '/home/vagrant/curriculum-network'
#  exec './repeated_rsync.sh', {async: true}