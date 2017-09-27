/* @flow */
const {extend, deep} = require('extendr')
const {PassThrough} = require('stream')

/* ::
declare class LongError extends Error {
  __previous: ?LongError;
  __previous__: ?LongError;
}
type levelInfo = {
	levelNumber: number,
	levelName: string
};
type lineInfo = {
	line: number,
	method: string,
	file: string
};
type logEntry = {
	date: string,
	args: Array<any>
};
*/

/**
Logger.
This is what we write to.
It extends from PassThrough and not transform.
If you are piping / writing directly to the logger, make sure it corresponds to the correct entry format (as described in `log`).

@example <caption>Creation</caption>
// Via class
const Logger = require('caterpillar').Logger
const logger = new Logger()
// Via create helper
const logger = Logger.create()
// Via create alias
const logger = require('caterpillar').create()

@extends stream.PassThrough
*/
class Logger extends PassThrough {

	// ===================================
	// Generic Differences
	// This code is shared but different between Logger and Transform

	/**
	Get the initial configuration option.
	Default log levels are compliant with http://www.faqs.org/rfcs/rfc3164.html
	@returns {Object}
	*/
	getInitialConfig () {
		return {
			lineOffset: 0,
			levels: {
				emergency: 0,
				alert: 1,
				critical: 2,
				error: 3,
				warning: 4,
				notice: 5,
				info: 6,
				debug: 7,

				emerg: 0,
				crit: 2,
				err: 3,
				warn: 4,
				note: 5,

				'default': 6
			}
		}
	}

	/**
	Alternative way of creating an instance of the class without having to use the `new` keyword.
	Useful when creating the class directly from `require` statements.
	@static
	@param {...*} args
	@returns {Logger}
	*/
	static create (...args) {
		return new this(...args)
	}

	// ===================================
	// Generic
	// This code is shared between Logger and Transform

	/**
	Construct our class and pass the arguments over to `setConfig`
	@params {...*} args
	*/
	constructor (...args /* :Array<any> */ ) {
		super(...args)
		this._config = this.getInitialConfig()
		this.setConfig(...args)
	}

	/**
	Internal configuration object
	@property {Object} _config
	@private
	*/
	/* :: _config:Object; */

	/**
	Get the current configuration object for this instance.
	@returns {Object}
	*/
	getConfig () /* :Object */ {
		return this._config
	}

	/**
	Apply the specified configurations to this instance's configuration via deep merging.
	@example
	setConfig({a: 1}, {b: 2})
	getConfig()  // {a: 1, b: 2}
	@param {...Array<Object>} configs
	@returns {this}
	*/
	setConfig (...configs /* :Array<Object> */ ) /* :this */ {
		deep(this._config, ...configs)
		this.emit('config', ...configs)
		return this
	}

	/**
	Pipe this data to some other writable stream.
	If the child stream also has a `setConfig` method, we will ensure the childs configuration is kept consistent with parents.
	@param {stream.Writable} child stream to be piped to
	@returns {stream.Writable} the result of the pipe operation
	*/
	pipe (child /* :Object */ ) /* :any */ {
		if ( child.setConfig ) {
			child.setConfig(this.getConfig())
			const listener = child.setConfig.bind(child)
			this.on('config', listener)
			child.once('close', () => this.removeListener('config', listener))
		}
		return super.pipe(child)
	}

	// ===================================
	// Logger

	/**
	Receive a level name and return the level number
	@param {string} name
	@returns {number}
	@throws {Error} will throw an error if no result was found
	*/
	getLevelNumber (name /* :string */) /* :number */ {
		const {levels} = this.getConfig()
		if ( levels[name] == null ) {
			throw new Error(`No level number was found for the level name: ${name}`)
		}
		else {
			return levels[name]
		}
	}

	/**
	Receive a level number and return the level name
	@param {number} number
	@returns {string}
	@throws {Error} will throw an error if returned empty handed
	*/
	getLevelName (number /* :number */) /* :string */ {
		const {levels} = this.getConfig()

		// Try to return the levelName
		for ( const name in levels ) {
			if ( levels.hasOwnProperty(name) ) {
				const value = levels[name]
				if ( value === number ) {
					return name
				}
			}
		}

		// Return
		throw new Error(`No level name was found for the level number: ${number}`)
	}

	/**
	Receive either the level name or number and return the combination.
	@example <caption>Input</caption>
	logger.getLevelInfo('note')
	@example <caption>Result</caption>
	{
		"levelNumber": 5,
		"levelName": "notice"
	}
	@param {string|number} level
	@returns {Object}
	@throws {Error} will throw an error if returned empty handed
	*/
	getLevelInfo (level /* :string|number */) /* :levelInfo */ {
		if ( typeof level === 'string' ) {
			const levelNumber = this.getLevelNumber(level)  // will throw if not found
			const levelName = this.getLevelName(levelNumber)  // name could be shortened, so get the expanded name
			return {levelNumber, levelName}
		}
		else if ( typeof level === 'number' ) {
			const levelName = this.getLevelName(level)  // will throw if not found
			return {levelNumber: level, levelName}
		}
		else {
			throw new Error(`Unknown level type: ${typeof level} for ${level}`)
		}
	}

	/**
	The current line info of whatever called this.
	@example <caption>Input</caption>
	logger.getLineInfo()
	@example <caption>Result</caption>
	{
		"line": "60",
		"method": "Object.<anonymous>",
		"file": "/Users/balupton/some-project/calling-file.js"
	}
	@returns {Object}
	@throws {Error} will throw an error if returned empty handed
	*/
	getLineInfo () /* :lineInfo */ {
		// Prepare
		let offset = this.getConfig().lineOffset
		const result = {
			line: -1,
			method: 'unknown',
			file: 'unknown'
		}

		try {
			// Create an error
			const err /* :LongError */ = (new Error() /* :any */)
			let stack, lines

			// And attempt to retrieve it's stack
			// https://github.com/winstonjs/winston/issues/401#issuecomment-61913086
			try {
				stack = err.stack
			}
			catch (error1) {
				try {
					const previous = err.__previous__ || err.__previous
					stack = previous && previous.stack
				}
				catch (error2) {
					stack = null
				}
			}

			// Handle different stack formats
			if ( stack ) {
				if ( Array.isArray(stack) ) {
					lines = Array(stack)
				}
				else {
					lines = stack.toString().split('\n')
				}
			}
			else {
				lines = []
			}

			// Handle different line formats
			lines = lines
				// Ensure each line item is a string
				.map((line) => (line || '').toString())
				// Filter out empty line items
				.filter((line) => line.length !== 0)

			// Parse our lines
			for ( const line of lines ) {
				if ( line.indexOf(__dirname) !== -1 || line.indexOf(' at ') === -1 ) {
					continue
				}

				if ( offset !== 0 ) {
					--offset
					continue
				}

				const parts = line.split(':')
				if ( parts.length >= 2 ) {
					if ( parts[0].indexOf('(') === -1 ) {
						result.method = 'unknown'
						result.file = parts[0].replace(/^.+?\s+at\s+/, '')
					}
					else {
						result.method = parts[0].replace(/^.+?\s+at\s+/, '').replace(/\s+\(.+$/, '')
						result.file = parts[0].replace(/^.+?\(/, '')
					}
					result.line = Number(parts[1])
					break
				}
			}
		}
		catch ( err ) {
			throw new Error(`Caterpillar.getLineInfo: Failed to parse the error stack: ${err}`)
		}

		// Return
		return result
	}

	/**
	Log the arguments into the logger stream as formatted data with debugging information.

	@example <caption>Inputs</caption>
	logger.log('note', 'this is working swell')
	logger.log('this', 'worked', 'swell')

	@example <caption>Results</caption>
	{
		"args": ["this is working swell"],
		"date": "2013-04-25T10:18:25.722Z",
		"levelNumber": 5,
		"levelName": "notice",
		"line": "59",
		"method": "Object.<anonymous>",
		"file": "/Users/balupton/some-project/calling-file.js"
	}
	{
		"args": ["this", "worked", "well"],
		"date": "2013-04-25T10:18:26.539Z",
		"levelNumber": 6,
		"levelName": "info",
		"line": "60",
		"method": "Object.<anonymous>",
		"file": "/Users/balupton/some-project/calling-file.js"
	}

	@param {...*} args
	@returns {Object}
	*/
	log (...args /* :Array<any> */ ) /* :this */ {
		const date = new Date().toISOString()
		const lineInfo = this.getLineInfo()

		const level /* :string|number */ = args.shift()
		let levelInfo
		try {
			levelInfo = this.getLevelInfo(level)
		}
		catch (err) {
			// if it threw (level was not a valid name or number), then use the default level
			levelInfo = this.getLevelInfo('default')
			args.unshift(level)
		}

		// Create the entry by mashing them together
		const entry /* :logEntry */ = extend({date, args}, levelInfo, lineInfo)

		// Write the arguments as an entry to be transformed by our format
		this.write(JSON.stringify(entry))

		// Chain
		return this
	}
}

// Export
module.exports = Logger
