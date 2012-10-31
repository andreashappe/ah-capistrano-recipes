ah-capistrano-recipes
=====================

This gem holds some common capistrano recipes that I'm using to deploy rails to virtual debian servers.

The automatically installed and configured tool-chain includes

* rbenv and ruby 1.9.3-p286
* bundler
* various debian dev libraries rmagick
* nginx
* unicorn
* monit (with configuration multi-worker monitoring)

Howto use this
--------------

capify your project and include the gem. Fix your config/deploy.rb to look something like this:

	require "bundler/capistrano"

	set :stages, %w(production staging my-custom-provider-setup)
        set :default_stage, "staging"
	require 'capistrano/ext/multistage'
        
	require 'recipes/common'
	require 'recipes/base_setup'
	require "recipes/nginx"
	require "recipes/unicorn"
	require "recipes/postgres"
	require "recipes/rbenv"
	require "recipes/static_files"
	require "recipes/monit"

	### actual configuration ###
	set :application, "my-wonderful-domainname.tld"
	set :domain_application, application
	set :repository,  "git@my-wonderful-git-repository.com:gitrepo.git"
	set :deploy_to, "/media/raid/managed-apps/#{application}/"
	set :domain_aliases, "some-domain-alias-1.com some-domain-alias-2.com"
	set :enable_ssl, false

HOWTO SETUP A NEW SERVER
------------------------

	$ ssh-copy-id root@new-server
	$ create a config/deploy/new-server.rb
	$ cap new-server base_setup:prepare_root_stuff
	$ cap new-server deploy:install

Note: monit has to be configured by hand. Also postgres' access rights must be configured manually.

HOWTO SETUP A NEW APPLICATION
-----------------------------

	$ cap new-server deploy:setp
	# copy database and assets manually
	$ cap new-server deploy

## NOTES

### Database

* the system tries to automatically detect network or host based setups and creates user and databases
* there's a rake tast "postgres:fix_permissions" which grants all ownership and permissions on a given database to a user. The same script can be called through /usr/local/bin/grant_access_to_db database user


BUGS/TODO
---------

* generator for example config/deploy.rb
* conditionally asset compilation is disabled for now
* create a better default nginx config
* enable monit automatically
* automatically fix postgre' pg_hba.conf
* unicorn restart script should check if unicorn is actually running, if not start unicorn app server
* when restarting first minimize app worker count to make continuous deployment on low-memory hosts possible
* automatically configure postgres backup script

WIP
---

* do not deploy stuff as root (this hasn't the highest priority for me as I'm always deploying to virtual servers) (user-separation branch)
* provide support for creating database users and tables (database branch)

HINT
----
* If you get some "namespace not found" error please use

	bundle exec cap ...

Copyright
---------
Copyright (c) 2012 Andreas Happe, See LICENSE for details
