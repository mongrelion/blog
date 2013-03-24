desc 'Create Puma configuration file'
task :'puma:config' do
  config = %{
    environment     = :production
    daemonize       true
    directory       '#{current_path}'
    rackup          '#{current_path}/config.ru'
    pidfile         '#{shared_path}/tmp/pids/puma.pid'
    #state_path     '#{shared_path}/tmp/pids/puma.state'
    stdout_redirect '#{shared_path}/log/access.log', '#{shared_path}/log/error.log', true
    bind            '#{puma_bind_address}'
    threads         #{puma_min_threads}, #{puma_max_threads}
  }
  queue! "echo '-----> Creating puma configuration file'"
  queue  "echo '#{config}' > #{puma_config_file_path}"
  queue! "echo '-----> Done.'"
end

desc 'Install Puma'
task :'puma:install' => :environment do
  queue! "gem install puma --version #{puma_version}"
end

desc 'Run Puma server'
task :'puma:start' => :environment do
  queue "puma -C #{puma_config_file_path}"
end
