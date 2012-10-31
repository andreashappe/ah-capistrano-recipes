Capistrano::Configuration.instance(:must_exist).load do
  namespace :postgres do

    # TODO: should be run as root
    task :install, roles: :db do
      run "add-apt-repository ppa:pitti/postgresql"
      run "apt-get -y update"
      run "apt-get -y install postgresql libpq-dev"
      generate_from_template "postgresql/grant_access_to_db", "/usr/local/bin/grant_access_to_db"
      generate_from_template "postgresql/add_db_access_to_user", "/etc/sudoers.d/add_db_access_to_#{user}"
    end
    after "deploy:install", "postgres:install"

    # read database config
    def get_db_config
      config = YAML.load_file("config/database.yml")

      if config[stage.to_s]["adapter"] != "postgresql"
        raise "cannot configure database as it is not using postgres adapter"
      end

      return config[stage.to_s]
    end

    # if host+username+password was supplied assume that we have a network setup
    # where we need to connect to a TCP server. Otherwise try local Unix Domain
    # Socket connectivity with local user
    def is_network_setup?(config)
      config.include?("host") && config.include?("username") && config.include?("password")
    end

    task :create_database, :roles => [:db] do
      config = get_db_config()
      username = config["username"]
      password = config["password"]

      if is_network_setup?(config)
        # asume network based setup
        run %Q{#{sudo} -u postgres psql -h #{config["host"]} -c "create user #{username} with password '#{password}';"}
        run %Q{#{sudo} -u postgres psql -h #{config["host"]} -c "create database #{database} owner #{username};"}
      else
        # asume udp based setup
        run "#{sudo} -u postgres createuser #{username}"
        run "#{sudo} -u postgres createdb #{database}"
      end

      run "#{sudo} mkdir -p #{shared_path}/db_backups" 
      run "#{sudo} chown postgres:postgres #{shared_path}/db_backups"
    end
    after "deploy:setup", "postgres:create_database"

    desc "Dumps target database db into an file"
    task :backup_database do
      config = get_db_config()
      output_file = "#{shared_path}/db_backups/dump-#{Time.now.strftime("%Y%m%d-%H%M")}.sql"

      if is_network_setup?(config)
        # asume network/tcp setup
        # TODO: can I automatically supply the password somehow?
        run "#{sudo} -u postgres pg_dump #{config["database"]} -f #{output_file} -h #{config["host"]} -U #{config["username"]}"
      else
        # asume local udp setup
        run "#{sudo} -u postgres pg_dump #{config["database"]} -f #{output_file}"
      end
    end
    before 'deploy:migrate', 'postgres:backup_database'
  end
end
