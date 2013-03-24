desc 'Load ruby in shell'
task :'rbenv:local' do
  queue! "rbenv local #{rbenv_ruby_version}"
end

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

desc '[Re]create shims'
task :'rbenv:rehash' do
  queue! 'rbenv rehash'
end

desc 'List current ruby versions installed.'
task :'rbenv:versions' do
  invoke :'rbenv:load'
  queue! 'rbenv versions'
end
