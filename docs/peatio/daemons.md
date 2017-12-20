# Peatio daemons

Peatio daemons are managed by [God](http://godrb.com/).

## Starting daemons

To start God as daemon run:

`god -c lib/daemons/daemons.god`

You can also start God in foreground:

`god -c lib/daemons/daemons.god -D`

**God starts all daemons when it is being initialized.**

Use `god stop` to stop all daemons. God will still be up.
Use `god start` to start all daemons.

## Stopping daemons

To stop God and all daemons run:

`god terminate`

To stop only daemons leaving God up run:

`god stop`

## Restarting daemons

`god restart`

Be patient when starting or stopping daemons: most of daemons support graceful termination so God will first send SIGTERM, wait short period of time, and forcefully kill process by sending SIGKILL if it is still up.

## Querying status

`god status`

## Reading logs

Each daemon has it's own log file localed at `log/daemons`.
