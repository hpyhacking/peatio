# Change Log

## [v0.2.4](https://github.com/rubykube/peatio/tree/v0.2.4) (2017-12-18)
[Full Changelog](https://github.com/rubykube/peatio/compare/0.2.3...v0.2.4)

**Fixed bugs:**

- Generation of new deposit address is broken [\#101](https://github.com/rubykube/peatio/issues/101)
- Several specs are failing \(seed 63928\) [\#86](https://github.com/rubykube/peatio/issues/86)
- Invalid link to Peatio GitHub repository at API Tokens page  [\#85](https://github.com/rubykube/peatio/issues/85)
- Layout issue when window is less than ~ 1000px [\#84](https://github.com/rubykube/peatio/issues/84)
- Missing translations when replying to ticket with empty message [\#82](https://github.com/rubykube/peatio/issues/82)
- Invalid paths in stylesheet when creating new document in admin panel [\#81](https://github.com/rubykube/peatio/issues/81)
- Duplicate item in "Deposits" menu in admin panel [\#80](https://github.com/rubykube/peatio/issues/80)
- No E-Mail is sent when manually registering on Peatio \(via sign up form\) [\#79](https://github.com/rubykube/peatio/issues/79)
- Outdated README: PhantomJS & ChromeDriver [\#78](https://github.com/rubykube/peatio/issues/78)
- Invalid E-Mail \(peatio.com\) in README [\#77](https://github.com/rubykube/peatio/issues/77)
- There are no headings & texts on main page when language is set to non-English  [\#76](https://github.com/rubykube/peatio/issues/76)
- When submitting invalid data to KYC form layout of date of birth input becomes broken [\#75](https://github.com/rubykube/peatio/issues/75)
- When you set phone number it actually allows to set password [\#74](https://github.com/rubykube/peatio/issues/74)
- "Funds" page doesn't work because of JS errors \(deposit & withdraw are broken\) [\#72](https://github.com/rubykube/peatio/issues/72)
- Application is shipped with different binaries than Rails defaults [\#71](https://github.com/rubykube/peatio/issues/71)
- Something strange occurs when exiting Rails application [\#70](https://github.com/rubykube/peatio/issues/70)
- Specs are failing due to missing ID in document [\#50](https://github.com/rubykube/peatio/issues/50)
- Specs are failing due to possible changes how capybara matches text \(after gem update\) [\#49](https://github.com/rubykube/peatio/issues/49)
- Spec features/sign\_up\_spec.rb fails when "Sign in with Google" & "Sign in with Auth0" are enabled [\#39](https://github.com/rubykube/peatio/issues/39)
- Add 'responders' gem [\#120](https://github.com/rubykube/peatio/pull/120) ([dkkoval](https://github.com/dkkoval))
- Fix binaries [\#110](https://github.com/rubykube/peatio/pull/110) ([dkkoval](https://github.com/dkkoval))

**Closed issues:**

- Test failing with seed 17488 [\#58](https://github.com/rubykube/peatio/issues/58)
- Create complete kubernetes install documentation [\#57](https://github.com/rubykube/peatio/issues/57)
- Generic JWT support [\#31](https://github.com/rubykube/peatio/issues/31)

**Merged pull requests:**

- Send CORS headers for API [\#124](https://github.com/rubykube/peatio/pull/124) ([yivo](https://github.com/yivo))
- Fix assets in production [\#122](https://github.com/rubykube/peatio/pull/122) ([dkkoval](https://github.com/dkkoval))
- Added translation for welcome page [\#119](https://github.com/rubykube/peatio/pull/119) ([emasiuk](https://github.com/emasiuk))
- Make amqp.yml static \(same as database.yml\) [\#112](https://github.com/rubykube/peatio/pull/112) ([dkkoval](https://github.com/dkkoval))
- Pass authenticity\_token as param \#101 [\#109](https://github.com/rubykube/peatio/pull/109) ([gfedorenko](https://github.com/gfedorenko))
- updated readme [\#106](https://github.com/rubykube/peatio/pull/106) ([emasiuk](https://github.com/emasiuk))
- return broken styles for date form on update page [\#105](https://github.com/rubykube/peatio/pull/105) ([emasiuk](https://github.com/emasiuk))
- fixed comment\_fail [\#102](https://github.com/rubykube/peatio/pull/102) ([emasiuk](https://github.com/emasiuk))
- Changed size of window for tests \#39 [\#100](https://github.com/rubykube/peatio/pull/100) ([gfedorenko](https://github.com/gfedorenko))
- changed email in readme docs [\#99](https://github.com/rubykube/peatio/pull/99) ([emasiuk](https://github.com/emasiuk))
- Flexible redirect URL for sign in with Auth0|Google [\#98](https://github.com/rubykube/peatio/pull/98) ([yivo](https://github.com/yivo))
- Invalid paths in stylesheet [\#97](https://github.com/rubykube/peatio/pull/97) ([yssavchuk](https://github.com/yssavchuk))
- Set correct name and description for Change Password setting [\#95](https://github.com/rubykube/peatio/pull/95) ([gfedorenko](https://github.com/gfedorenko))
- Changed angularjs version to 1.3.15 [\#93](https://github.com/rubykube/peatio/pull/93) ([gfedorenko](https://github.com/gfedorenko))
- Layout issue when window is less than [\#92](https://github.com/rubykube/peatio/pull/92) ([emasiuk](https://github.com/emasiuk))
- correct name deposits field [\#90](https://github.com/rubykube/peatio/pull/90) ([emasiuk](https://github.com/emasiuk))
- Fixed link to Peatio GitHub repository at API Tokens page [\#89](https://github.com/rubykube/peatio/pull/89) ([emasiuk](https://github.com/emasiuk))
- Specs are failing due to missing ID in document [\#87](https://github.com/rubykube/peatio/pull/87) ([yssavchuk](https://github.com/yssavchuk))
- Fix CI badge in the README [\#69](https://github.com/rubykube/peatio/pull/69) ([dkkoval](https://github.com/dkkoval))
- Add k8s deployment documentation [\#68](https://github.com/rubykube/peatio/pull/68) ([dkkoval](https://github.com/dkkoval))
- Add more generic way to configure k8s deployment [\#63](https://github.com/rubykube/peatio/pull/63) ([dkkoval](https://github.com/dkkoval))
- Test failing with seed 17488 [\#59](https://github.com/rubykube/peatio/pull/59) ([yssavchuk](https://github.com/yssavchuk))
- Support for generic JWT [\#56](https://github.com/rubykube/peatio/pull/56) ([yivo](https://github.com/yivo))

## [0.2.3](https://github.com/rubykube/peatio/tree/0.2.3) (2017-12-07)
[Full Changelog](https://github.com/rubykube/peatio/compare/v0.1.1...0.2.3)

**Fixed bugs:**

- Remove hardcoded secrets in config/initializers/secret\_token.rb [\#42](https://github.com/rubykube/peatio/issues/42)
- Signatures randomly don't match when using keypair token authentication [\#41](https://github.com/rubykube/peatio/issues/41)

**Closed issues:**

- assets.config.precompile is missing some assets [\#61](https://github.com/rubykube/peatio/issues/61)
- Resolve warnings after update to ruby 2.4 & gems update  [\#51](https://github.com/rubykube/peatio/issues/51)
- SocketError [\#36](https://github.com/rubykube/peatio/issues/36)
- Sign up via Auth0 \(should be optional\) [\#18](https://github.com/rubykube/peatio/issues/18)
- Sign up via Google [\#17](https://github.com/rubykube/peatio/issues/17)
- Remove 2-way authentification [\#15](https://github.com/rubykube/peatio/issues/15)

**Merged pull requests:**

- Add ability to set password for rabbitmq and redis [\#66](https://github.com/rubykube/peatio/pull/66) ([dkkoval](https://github.com/dkkoval))
- Update binstubs [\#65](https://github.com/rubykube/peatio/pull/65) ([dkkoval](https://github.com/dkkoval))
- Fix \#61 [\#62](https://github.com/rubykube/peatio/pull/62) ([yivo](https://github.com/yivo))
- Fix \#41 [\#60](https://github.com/rubykube/peatio/pull/60) ([yivo](https://github.com/yivo))
- Fix typo: expire\_at -\> expires\_at [\#55](https://github.com/rubykube/peatio/pull/55) ([yivo](https://github.com/yivo))
- Resolve warnings [\#54](https://github.com/rubykube/peatio/pull/54) ([yivo](https://github.com/yivo))
- Update grape to 1.0.1, grape-entity to 0.5.2, grape-swagger to 0.27.3 [\#53](https://github.com/rubykube/peatio/pull/53) ([yivo](https://github.com/yivo))
- Remove hardcoded cookies secret key \(fixes \#42\) [\#48](https://github.com/rubykube/peatio/pull/48) ([yivo](https://github.com/yivo))
- Update grape to 0.15.0 [\#46](https://github.com/rubykube/peatio/pull/46) ([yivo](https://github.com/yivo))
- Update grape to 0.9.0 [\#44](https://github.com/rubykube/peatio/pull/44) ([yivo](https://github.com/yivo))
- Preparations for JWT auth [\#38](https://github.com/rubykube/peatio/pull/38) ([yivo](https://github.com/yivo))
- Run tests on push [\#37](https://github.com/rubykube/peatio/pull/37) ([dkkoval](https://github.com/dkkoval))
- Optional sign in with Auth0 [\#29](https://github.com/rubykube/peatio/pull/29) ([yivo](https://github.com/yivo))
- Optional sign in with Google account [\#28](https://github.com/rubykube/peatio/pull/28) ([yivo](https://github.com/yivo))
- Fixed QR code [\#27](https://github.com/rubykube/peatio/pull/27) ([spavlishak](https://github.com/spavlishak))
- Minor fixes [\#12](https://github.com/rubykube/peatio/pull/12) ([spavlishak](https://github.com/spavlishak))
- Lock ruby version [\#11](https://github.com/rubykube/peatio/pull/11) ([yivo](https://github.com/yivo))
- Add ripple support [\#9](https://github.com/rubykube/peatio/pull/9) ([dkkoval](https://github.com/dkkoval))
- Cleanup [\#7](https://github.com/rubykube/peatio/pull/7) ([dkkoval](https://github.com/dkkoval))
- Make it work on k8s [\#6](https://github.com/rubykube/peatio/pull/6) ([dkkoval](https://github.com/dkkoval))
- Fix Pusher [\#4](https://github.com/rubykube/peatio/pull/4) ([dkkoval](https://github.com/dkkoval))
- Deployment [\#3](https://github.com/rubykube/peatio/pull/3) ([ashanaakh](https://github.com/ashanaakh))
- updated gem file and added mysql adapter [\#2](https://github.com/rubykube/peatio/pull/2) ([zakusha](https://github.com/zakusha))

## [v0.1.1](https://github.com/rubykube/peatio/tree/v0.1.1) (2015-09-25)
