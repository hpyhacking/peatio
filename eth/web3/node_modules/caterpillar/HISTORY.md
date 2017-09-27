# History

## v3.0.1 2016 October 20
- Fixed flow type errors with newer flow versions

## v3.0.0 2016 May 4
- Converted from CoffeeScript to JavaScript
- `.createLogger()` and `.createTransform()` now removed in favour of `Logger.create()` and `Transform.create()`
- `require('caterpillar').create()` alias added
- Logger no longer inherits from Transform

## v2.0.9 2015 February 18
- Fixed an issue when fetching `(new Error()).stack` would fail
- More robust stack parsing

## v2.0.8 2015 February 7
- Updated dependencies

## v2.0.7 2013 December 12
- Use native streams if available, otherwise fallback to [readable-stream](https://npmjs.org/package/readable-stream)
- Repackaged

## v2.0.6 2013 October 23
- `Logger:log` is now permantely bound to the logger instance, for easy passing around

## v2.0.5 2013 October 23
- Added `create` API to make life easier when doing one liners
- Project meta data files are now maintained by [Projectz](https://github.com/bevry/projectz)
- Updated dependencies

## v2.0.4 2013 July 23
- Added `lineOffset` configuration offset to allow you to detect the correct line of the reporting when using wrappers
- Updated dependencies

## v2.0.3 2013 May 19
- iOS support (iOS devices do not have `new Error().stack`)

## v2.0.2 2013 May 7
- Fixed defaulting the log level
	- Closes [issue #6](https://github.com/bevry/caterpillar/issues/6) reported by [Erik Dasque](https://github.com/edasque)

## v2.0.1 2013 April 25
- Node 0.8 support

## v2.0.0 2013 April 25
- Rewrote using streams

## v1.1.4 2013 March 25
- Repackaged

## v1.1.3 2012 October 18
- Updated cli-color from 0.1 to 0.2
- Make cli-color an optional dependency

## v1.1.2 2012 August 10
- Rejigged directory structure
- Re-added markdown files to npm distribution as they are required for the npm website

## v1.1.1 2012 May 4
- Fixed dependency overwrite

## v1.1.0 2012 May 4
- Caterpillar now pre-compiles, so the coffee-script dependency is no longer needed

## v1.0.0 2012 February 11
- Modularised
- Added [docco](http://jashkenas.github.com/docco/) docs
- Debug line is now only outputted if the log level is 7
- Added `setLevel(level)`
- Added `History.md`
- Added new screenshots
- `cli-color` dependency now accepts revisions

## v0.1 2011 September 5
- Initial commit
