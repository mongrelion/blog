desc 'Install gems'
task :'gems:install' => :environment do
  gems.each do |gem, version|
    queue echo_cmd "gem install #{gem} --version #{version}"
  end
end
