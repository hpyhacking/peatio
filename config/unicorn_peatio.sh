#! /bin/sh

### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $all
# Required-Stop:     $network $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the unicorn web server
# Description:       starts unicorn
### END INIT INFO

# Change these to match your app:
USER=deploy
APP_NAME=peatio
APP_PATH=/home/$USER/$APP_NAME
ENV=production
RBENV_RUBY_VERSION=2.1.0

# env
APP_ROOT="$APP_PATH/current"
RBENV_ROOT="/home/$USER/.rbenv"
PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
SET_PATH="cd $APP_ROOT; rbenv rehash; rbenv local $RBENV_RUBY_VERSION"
DAEMON="bundle exec unicorn_rails"
DAEMON_OPTS="-c $APP_ROOT/config/unicorn.rb -E $ENV -D"
CMD="$SET_PATH; $DAEMON $DAEMON_OPTS"
NAME=unicorn
DESC="Unicorn app for peatio"
PID="$APP_ROOT/tmp/pids/unicorn.pid"
OLD_PID="$PID.oldbin"

cd $APP_ROOT || exit 1

sig () {
        test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
        test -s $OLD_PID && kill -$1 `cat $OLD_PID`
}

case ${1-help} in
start)
        sig 0 && echo >&2 "Already running" && exit 0
        su - $USER -c "$CMD"
        ;;
stop)
        sig QUIT && exit 0
        echo >&2 "Not running"
        ;;
force-stop)
        sig TERM && exit 0
        echo >&2 "Not running"
        ;;
restart|reload)
        sig HUP && echo reloaded OK && exit 0
        echo >&2 "Couldn't reload, starting '$CMD' instead"
        su - $USER -c "$CMD"
        ;;
upgrade)
        sig USR2 && exit 0
        echo >&2 "Couldn't upgrade, starting '$CMD' instead"
        su - $USER -c "$CMD"
        ;;
rotate)
        sig USR1 && echo rotated logs OK && exit 0
        echo >&2 "Couldn't rotate logs" && exit 1
        ;;
*)
        echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
        exit 1
        ;;
esac

exit 0
