/*
 * Copyright (c) 2012 Mathieu Turcotte
 * Licensed under the MIT license.
 */

var cp = require('child_process');
var fs = require('fs');
var path = require('path');

var npid = require('../index');
var rmdirSync = require('./helpers/rmdir');

var SANDBOX = path.join(__dirname, 'sandbox');
var NEW_PID_FILE = path.join(SANDBOX, 'pid0');
var EXISTING_PID_FILE = path.join(SANDBOX, 'pid1');

var CHIlD_HELPER = path.join(__dirname, 'helpers/sub.js');

exports["npid"] = {
    setUp: function(callback) {
        rmdirSync(SANDBOX);
        fs.mkdirSync(SANDBOX);
        fs.writeFileSync(EXISTING_PID_FILE, '1234');
        callback();
    },

    tearDown: function(callback) {
        rmdirSync(SANDBOX);
        callback();
    },

    "pid files should contain the process id": function(test) {
        npid.create(NEW_PID_FILE);
        var pid = fs.readFileSync(NEW_PID_FILE, 'utf8');
        test.equal(pid, process.pid);
        test.done();
    },

    "existing pid file should not be overwritten": function(test) {
        test.throws(function() {
            npid.create(EXISTING_PID_FILE);
        }, npid.PidFileExists);
        test.done();
    },

    "existing pid file content should not be overwritten": function(test) {
        var originalContent = fs.readFileSync(EXISTING_PID_FILE, 'utf8');

        try {
            npid.create(EXISTING_PID_FILE);
        } catch (err) {}

        var finalContent = fs.readFileSync(EXISTING_PID_FILE, 'utf8');

        test.equal(originalContent, finalContent);
        test.done();
    },

    "existing pid file should be overwritten when force is true": function(test) {
        var original = fs.readFileSync(EXISTING_PID_FILE, 'utf8');
        npid.create(EXISTING_PID_FILE, true);
        var finalContent = fs.readFileSync(EXISTING_PID_FILE, 'utf8');
        test.notEqual(original, finalContent);
        test.equal(finalContent, process.pid);
        test.done();
    },

    "calling remove on the handle should remove the pid file": function(test) {
        var pid = npid.create(NEW_PID_FILE);
        test.ok(fs.existsSync(NEW_PID_FILE));
        pid.remove();
        test.ok(!fs.existsSync(NEW_PID_FILE));
        test.done();
    },

    "the pidfile should be deleted on normal exit": function(test) {
        var child = cp.fork(__dirname + '/helpers/sub.js', [NEW_PID_FILE]);

        child.on('message', function(m) {
            test.ok(fs.existsSync(NEW_PID_FILE));
            child.send('stop');
        });

        child.on('exit', function(code, signal) {
            test.ok(!fs.existsSync(NEW_PID_FILE));
            test.done();
        });
    }
};
