desc 'Create Puma configuration file'
task :'puma:config' do
  full_current_path = "#{deploy_to}/#{current_path}"
  full_shared_path  = "#{deploy_to}/#{shared_path}"
  config = %{
    environment     = :production
    daemonize       true
    directory       "#{full_current_path}"
    rackup          "#{full_current_path}/config.ru"
    pidfile         "#{full_shared_path}/tmp/pids/puma.pid"
    #state_path     "#{full_shared_path}/tmp/pids/puma.state"
    stdout_redirect "#{full_shared_path}/log/access.log", "#{full_shared_path}/log/error.log", true
    bind            "#{puma_bind_address}"
    threads         #{puma_min_threads}, #{puma_max_threads}
  }
  queue! "echo '-----> Creating puma configuration file'"
  queue  "echo '#{config}' > #{puma_config_file_path}"
  queue! "echo '-----> Done.'"
end

desc 'Run Puma server'
task :'puma:start' => :environment do
  queue "puma -C #{puma_config_file_path}"
end
