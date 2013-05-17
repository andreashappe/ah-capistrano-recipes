Capistrano::Configuration.instance(:must_exist).load do
  task :log_revision do
    log = "#{deploy_to}/revisions.log"
    status_msg = "#{Time.now}: #{latest_revision}"
    run "(test -e #{log} || touch #{log} && chmod 0666 #{log}) && echo #{status_msg} >> #{log};"
  end

  after :deploy, :log_revision
end
