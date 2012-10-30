= ah-capistrano-recipes

This gem holds some common capistrano recipes that I'm using to deploy rails to virtual debian servers.

The automatically installed and configured tool-chain includes

* rbenv and ruby 1.9.3-p286
* bundler
* various debian dev libraries rmagick
* nginx
* unicorn
* monit (with configuration multi-worker monitoring)

== Howto use this

capify your project and include the gem. Fix your config/deploy.rb to look something like this:

	require "bundler/capistrano"

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

	set :stages, %w(production staging my-custom-provider-setup)

== HOWTO SETUP A NEW SERVER

	$ ssh-copy-id root@new-server
	$ create a config/deploy/new-server.rb
	$ cap new-server base_setup:prepare_root_stuff
	$ cap new-server deploy:install

Note: monit has to be configured by hand. Also postgres' access rights must be configured manually.

== HOWTO SETUP A NEW APPLICATION

	$ cap new-server deploy:setp
	# copy database and assets manually
	$ cap new-server deploy

== BUGS/TODO

* database creation script is kinda shaky (it cannot destroy stuff, but I'm not sure that it will work in too many cases)
* automatic database backup is disabled for now
* automatic database backup before migrations is disabled for now
* conditionally asset compilation is disabled for now
* create a better default nginx config
* enable monit automatically
* do not deploy stuff as root (this hasn't the highest priority for me as I'm always deploying to virtual servers)
* automatically fix postgre' pg_hba.conf
* automatically create new database role
* unicorn restart script should check if unicorn is actually running, if not start unicorn app server
* when restarting first minimize app worker count to make continuous deployment on low-memory hosts possible
* automatically configure postgres backup script

== HINT

If you have installed a postgres database and need to change the owner of all tables use the following script:

	for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" $DATABASE` ; do  psql -c "alter table $tbl owner to $NEW_OWNER" $DATABASE ; done

== Copyright
Copyright (c) 2012 Andreas Happe, See LICENSE for details
