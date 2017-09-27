/* @flow */
const Transform = require('./transform.js')
const Logger = require('./logger.js')
const create = Logger.create.bind(Logger)
module.exports = {Transform, Logger, create}
