# History

## v3.2.2 2016 June 19
- Re-added node 0.10 compatibility (regression since v3.0.0)
  - Albeit implicit/untested compat as dev deps require node >=0.12

## v3.2.1 2016 June 16
- Re-added missing engines property (regression since v3.2.0)
- Removed unused editions syntax

## v3.2.0 2016 May 27
- **UNPUBLISHED:** due to missing engines field, replacement is v3.2.1
- Updated internal conventions
  - Moved from [ESNextGuardian](https://github.com/bevry/esnextguardian) to [Editions](https://github.com/bevry/editions)

## v3.1.0 2015 December 9
- Updated internal conventions

## v3.0.1 2015 September 21
- Updated dependencies

## v3.0.0 2015 September 11
- Moved from CoffeeScript to ES6+
- Rewrote to ensure reference consistency
  - `clone` has been "removed", as `deepClone` is now `clone`, as a shallow clone doesn't make sense
  - `deepExtend` is now `deep`
  - `shallowExtendPlainObjects` is now `extend`
  - `safeShallowExtendPlainObjects` is now `defaults`
  - `deepExtendPlainObjects` is now `deep`
  - `safeDeepExtendPlainObjects` is now `deepDefaults`
  - `dereference` is now `dereferenceJSON`

## v2.1.0 2013 June 29
- Arrays now correctly deep extend

## v2.0.1 2013 March 28
- Added `deepExtend` alias for `deepExtendPlainObjects`

## v2.0.0 2013 March 28
- Split away from [bal-util](https://github.com/balupton/bal-util)
