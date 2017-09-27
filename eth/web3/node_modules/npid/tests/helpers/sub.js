/*
 * Copyright (c) 2012 Mathieu Turcotte
 * Licensed under the MIT license.
 */

var npid = require('../../index');

var path = process.argv[2];
setInterval(function() {}, 5000);

var pid = npid.create(path);
pid.removeOnExit();

process.on('message', function(m) {
    process.exit(0);
});

process.send('ok');
