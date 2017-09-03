'use strict';

// Import
var typeChecker = require('typechecker');

// Internal use only: Extend with customisations
function custom(_ref, target) {
	var _ref$defaults = _ref.defaults;
	var defaults = _ref$defaults === undefined ? false : _ref$defaults;
	var _ref$traverse = _ref.traverse;
	var traverse = _ref$traverse === undefined ? false : _ref$traverse;

	if (!typeChecker.isPlainObject(target)) {
		throw new Error('extendr only supports extending plain objects, target was not a plain object');
	}

	for (var _len = arguments.length, objs = Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
		objs[_key - 2] = arguments[_key];
	}

	for (var objIndex = 0; objIndex < objs.length; ++objIndex) {
		var obj = objs[objIndex];
		if (!typeChecker.isPlainObject(obj)) {
			throw new Error('extendr only supports extending plain objects, an input was not a plain object');
		}
		for (var key in obj) {
			if (obj.hasOwnProperty(key)) {
				// if not defaults only, always overwrite
				// if defaults only, overwrite if current value is empty
				var defaultSkip = defaults && target[key] != null;

				// get the new value
				var newValue = obj[key];

				// ensure everything is new
				if (typeChecker.isPlainObject(newValue)) {
					if (traverse && typeChecker.isPlainObject(target[key])) {
						// replace current value with
						// dereferenced merged new object
						target[key] = custom({ traverse: traverse, defaults: defaults }, {}, target[key], newValue);
					} else if (!defaultSkip) {
						// replace current value with
						// dereferenced new object
						target[key] = custom({ defaults: defaults }, {}, newValue);
					}
				} else if (!defaultSkip) {
					if (typeChecker.isArray(newValue)) {
						// replace current value with
						// dereferenced new array
						target[key] = newValue.slice();
					} else {
						// replace current value with
						// possibly referenced: function, class, etc
						// possibly unreferenced: string
						// new value
						target[key] = newValue;
					}
				}
			}
		}
	}
	return target;
}

// Extend without customisations
function extend() {
	for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
		args[_key2] = arguments[_key2];
	}

	return custom.apply(undefined, [{}].concat(args));
}

// Extend +traverse
function deep() {
	for (var _len3 = arguments.length, args = Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
		args[_key3] = arguments[_key3];
	}

	return custom.apply(undefined, [{ traverse: true }].concat(args));
}

// Extend +defaults
function defaults() {
	for (var _len4 = arguments.length, args = Array(_len4), _key4 = 0; _key4 < _len4; _key4++) {
		args[_key4] = arguments[_key4];
	}

	return custom.apply(undefined, [{ defaults: true }].concat(args));
}

// Extend +traverse +defaults
function deepDefaults() {
	for (var _len5 = arguments.length, args = Array(_len5), _key5 = 0; _key5 < _len5; _key5++) {
		args[_key5] = arguments[_key5];
	}

	return custom.apply(undefined, [{ traverse: true, defaults: true }].concat(args));
}

// Extend to new object +traverse
function clone() {
	for (var _len6 = arguments.length, args = Array(_len6), _key6 = 0; _key6 < _len6; _key6++) {
		args[_key6] = arguments[_key6];
	}

	return custom.apply(undefined, [{ traverse: true }, {}].concat(args));
}

// Will not keep functions
function dereferenceJSON(source) {
	return JSON.parse(JSON.stringify(source));
}

// Export
module.exports = {
	custom: custom,
	extend: extend,
	deep: deep,
	defaults: defaults,
	deepDefaults: deepDefaults,
	clone: clone,
	dereferenceJSON: dereferenceJSON
};