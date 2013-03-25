desc 'Create Puma configuration file'
task :'puma:config' do
  config = %{
    environment     "production"
    daemonize       true
    directory       "#{deploy_to}/#{current_path}"
    rackup          "#{deploy_to}/#{current_path}/config.ru"
    pidfile         "#{puma_pidfile}"
    stdout_redirect "#{puma_access_log_path}", "#{puma_error_log_path}", true
    bind            "#{puma_bind_address}"
    threads         #{puma_min_threads}, #{puma_max_threads}
  }
  queue! "echo '-----> Creating puma configuration file'"
  queue  "echo '#{config}' > #{puma_config_file_path}"
  queue! "echo '-----> Done.'"
end

desc 'Start Puma'
task :'puma:start' => :environment do
  queue! "cd #{deploy_to}/#{current_path} && puma --config ./config/puma.rb"
end

task :'puma:stop' => :environment do
  queue! "kill -s TERM `cat #{puma_pidfile}`"
end

task :'puma:restart' => :environment do
  invoke :'puma:stop'
  invoke :'puma:start'
end
