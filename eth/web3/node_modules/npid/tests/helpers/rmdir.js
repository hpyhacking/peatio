/*
 * Copyright (c) 2012 Mathieu Turcotte
 * Licensed under the MIT license.
 */

var fs = require('fs');
var path = require('path');

module.exports = function rmdirSync(p) {
    var stat;

    try {
        stat = fs.lstatSync(p);
    } catch (err) {
        if (err.code === "ENOENT") {
            return;
        } else {
            throw err;
        }
    }

    if (!stat.isDirectory()) {
        fs.unlinkSync(p);
    } else {
        fs.readdirSync(p).forEach(function (f) {
            rmdirSync(path.join(p, f));
        });

        fs.rmdirSync(p);
    }
};

