#!/usr/bin/env node

var npid = require('../index');

var pid = npid.create('./exception.pid');
pid.removeOnExit();

process.on('uncaughtException', function(err) {
    console.log('Caught exception: ' + err);
    process.exit(1);
});

throw new Error('Boum!');
