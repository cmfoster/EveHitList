Resque::Server.use(Rack::Auth::Basic) do |user, password|
  rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
  resque_login_config = YAML.load_file(rails_root + '/config/resque_secrets.yml')
  user == resque_login_config['login']
  password == resque_login_config['password']
end  