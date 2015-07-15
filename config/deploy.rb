# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'test_angular'
set :repo_url, 'git@github.com:svillafuerte/test_angular.git'
set :branch, :master

set :linked_dirs, %w{node_modules app/bower_components}

# Default deploy_to directory is /var/www/my_app_name
#set :deploy_to, '/var/www/test_angular'
set :deploy_to, "/var/www/#{fetch(:application)}"

#after 'deploy:update_code', 'deploy:build:precompile'

# set :theme_path, Pathname.new('web/app/themes/mytheme')
# #set :local_app_path, Pathname.new('/Users/satcha/Projects/test_angular')
set :local_app_path, Pathname.new(File.dirname(__FILE__)).join('../')
# set :local_theme_path, fetch(:local_app_path).join(fetch(:theme_path))

# namespace :deploy do
#   #custom tasks to build via gulp
#   before :deploy, 'deploy:gulp_build_local' 

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       #nothing here, because there's no app server for this static site.
#     end
#   end

#   after :publishing, :restart
# end

namespace :deploy do
  desc 'Run gulp to compile the static site'
  task :compile_assets do
  #run_locally doesn't play nice with the 'on' directive (it's 'on' localhost)
    run_locally do
      execute :gulp, :build
    end
  end

  task :copy_assets do
    #invoke 'deploy:compile_assets' 

    on roles(:web) do
      upload! fetch(:local_app_path).join('dist').to_s, release_path, recursive: true
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      #nothing here, because there's no app server for this static site.
    end
  end

  # before :deploy, 'deploy:gulp_build'
  before "deploy:updated", "deploy:copy_assets"
end 



#####################################

# namespace :deploy do
#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       # Your restart mechanism here, for example:
#       # execute :service, :nginx, :reload
#     end
#   end
# end
 
# namespace :assets do
#   task :compile do
#     run_locally do
#       within fetch(:local_theme_path) do
#         execute :gulp, :build
#       end
#     end
#   end
 
#   task :copy do
#     on roles(:web) do
#       upload! fetch(:local_theme_path).join('dist'), release_path.join(fetch(:theme_path)), recursive: true
#     end
#   end
  
#   task deploy: %w(compile copy)
# end
 
# before 'deploy:updated', 'assets:deploy'

#############################################

# namespace :deploy do
#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
      
#     end
#   end

#   task :build do 
#     on roles(:app) do
#       run_locally('gulp clean')
#       run_locally('gulp build')

#       upload("dist")
#     end
#   end

#   def upload(directory)
#     # Uploads a subdirectory of public/ to the shared directory on the server
#     run_locally("tar -jcf #{directory}.tar.bz2 #{directory}")
#     top.upload("#{directory}.tar.bz2", "#{current_path}", via: :scp)
#     run("cd #{current_path} && tar -jxf #{directory}.tar.bz2 && rm #{directory}.tar.bz2")
#     # run_locally("rm -rf public/#{directory}/")
#     run_locally("rm #{directory}.tar.bz2")
#   end

#   after :publishing, :restart
#   after :published, :build
# end
