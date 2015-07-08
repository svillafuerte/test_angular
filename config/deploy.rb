# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'test_angular'
set :repo_url, 'git@github.com:svillafuerte/test_angular.git'

set :linked_dirs, %w{node_modules app/bower_components}

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/test_angular'

#after 'deploy:update_code', 'deploy:build:precompile'

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      
    end
  end

  task :build do 
    on roles(:app) do
      run_locally('gulp clean')
      run_locally('gulp build')

      upload("dist")
    end
  end

  def upload(directory)
    # Uploads a subdirectory of public/ to the shared directory on the server
    run_locally("tar -jcf #{directory}.tar.bz2 #{directory}")
    top.upload("#{directory}.tar.bz2", "#{current_path}", via: :scp)
    run("cd #{current_path} && tar -jxf #{directory}.tar.bz2 && rm #{directory}.tar.bz2")
    # run_locally("rm -rf public/#{directory}/")
    run_locally("rm #{directory}.tar.bz2")
  end

  after :publishing, :restart
  after :published, :build
end
