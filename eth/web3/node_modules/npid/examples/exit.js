#!/usr/bin/env node

var npid = require('../index');

var pid = npid.create('./example.pid');
pid.removeOnExit();
