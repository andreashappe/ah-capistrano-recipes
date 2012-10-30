# TODO: those commands should be run as root instead of the configured user
# TODO: automatically activate support for /etc/sudoers.d/
Capistrano::Configuration.instance(:must_exist).load do
  namespace :base_setup do

    task :prepare_root_stuff do
      # update package database
      run "apt-get update"

      copy_add_apt_repository
      install_sudo
      install_base_gem_dependencies
    end

    task :copy_add_apt_repository do
      generate_from_template 'add-apt-repository', '/usr/local/bin/add-apt-repository'
      run "chmod +x /usr/local/bin/add-apt-repository"
    end

    task :install_sudo do
      run "apt-get -y install sudo"

      # for now give the defined user unlimited rights
      # TODO: limit rights to some specially given commands in /usr/local/sbin/
      generate_from_template 'root_rights_for_user', "/etc/sudoers.d/root_rights_for_#{user}"
    end

    task :install_base_gem_dependencies do
      run "apt-get -y install libmagickwand-dev libsqlite3-dev"
    end
  end
end
