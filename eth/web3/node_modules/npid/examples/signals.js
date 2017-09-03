#!/usr/bin/env node

var npid = require('../index');

var pid = npid.create('./example.pid');
pid.removeOnExit();

function exit() {
    process.exit(0);
}

process.on('SIGINT', exit);
process.on('SIGTERM', exit);

setInterval(function() {
    /* ... */
}, 5000);
