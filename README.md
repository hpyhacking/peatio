## The World First Public Owned Exchange


[Peatio](http://en.wikipedia.org/wiki/Pixiu) (Chinese: 貔貅) is a Chinese mythical hybrid creature considered to be a very powerful protector to practitioners of Feng Shui.


* Exchange: https://peatio.com/

## Development

* Develop branch has the latest and greatest
* `brew install qrencode` before `bundle install`
* Copy sample config files and update according to your local setup `ls config/*.yml.sample | cut -f 1,2 -d '.' | xargs -I file cp file{.sample,}`
* If you want to use username `root` to access msql, [this might be helpful](http://stackoverflow.com/questions/8537531/access-denied-for-user-rootlocalhost-using-password-no)
* At this point after `rake db:setup db:test:prepare` you should be able to run tests with `rspec`

### Background jobs

* `brew install redis` and then start redis
* kick off resque: `QUEUE=* rake environment resque:work`

**Wiki**: https://github.com/peatio/peatio/wiki

Any Questions: services@peatio.com

## License

MIT: http://peatio.mit-license.org
