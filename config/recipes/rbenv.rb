set :rbenv_ruby_version, '2.0.0-p0'
desc 'Install rbenv.'
task :'rbenv:install' do
  queue %[
    echo "-----> Installing rbenv"
    git clone git://github.com/sstephenson/rbenv.git #{rbenv_path}
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
    echo 'eval "$(rbenv init -)"' >> ~/.profile
    echo "-----> Done installing rbenv"
    mkdir -p #{rbenv_path}/plugins
    echo "-----> Installing ruby-build"
    git clone git://github.com/sstephenson/ruby-build.git #{rbenv_path}/plugins/ruby-build
    echo "-----> Done installing ruby-build"
  ]
end

desc 'Install ruby'
task :'rbenv:install_ruby' do
  invoke :'rbenv:load'
  queue! "rbenv install #{rbenv_ruby_version}"
end

desc 'List current ruby versions installed.'
task :'rbenv:versions' do
  invoke :'rbenv:load'
  queue! 'rbenv versions'
end
