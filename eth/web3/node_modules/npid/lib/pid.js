/*
 * Copyright (c) 2012 Mathieu Turcotte
 * Licensed under the MIT license.
 */

var fs = require('fs');

/**
 * Pid file handle which can be used to remove the pid file.
 * @param path The pid file's path.
 */
function Pid(path) {
    this.path_ = path;
}

/** Removes the PID file synchronously. Does not throw. */
Pid.prototype.remove = function() {
    return module.exports.remove(this.path_);
};

/** Removes the PID file on normal process exit. */
Pid.prototype.removeOnExit = function() {
    process.on('exit', this.remove.bind(this));
};

/**
 * Creates a pid file synchronously.
 * @param path Path to the pid file.
 * @param force Whether and existing pid file should be overwritten.
 */
function create(path, force) {
    var pid = new Buffer(process.pid + '\n');
    var fd = fs.openSync(path, force ? 'w' : 'wx');
    var offset = 0;

    while (offset < pid.length) {
        offset += fs.writeSync(fd, pid, offset, pid.length - offset);
    }

    fs.closeSync(fd);

    return new Pid(path);
}

/**
 * Removes a pid file synchronously. Does not throw.
 * @param path The pid file's path.
 */
function remove(path) {
    try {
        fs.unlinkSync(path);
        return true;
    } catch (err) {
        return false;
    }
}

module.exports.create = create;
module.exports.remove = remove;
