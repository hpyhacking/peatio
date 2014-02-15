Developing under OS X
---------------------

The Peatio installation consists of setting up the following components:

1. Requirements
2. Bitcoind
3. Peatio


## 1. Requirements

* XCode and/or the XCode Command Line Tools.
* Homebrew
* Ruby 2.1.0, using [RVM](http://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv)
* MySQL
* Redis
* PhatomJS

** More details are in the [requirements](doc/install/requirements.md)

## 2. Bitcoind

##### install bitcoind

	TODO

##### Start Bitcoind

    bitcoind


## 3. Peatio

##### Clone the project

    git clone git@github.com:peatio/peatio.git
    cd peatio
    bundle install


##### Configuration

**Database:**

    vim config/database.yml

    # Initialize the database
    bundle exec rake db:setup

**E-mail:**

    TODO

#### Run Peatio

**Resque:**

    rake environment resque:work QUEUE=* PIDFILE=/home/deploy/www/peatio/tmp/pids/resque.pid
    rails server



