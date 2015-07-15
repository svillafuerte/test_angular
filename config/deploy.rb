# config valid only for current version of Capistrano
#lock '3.4.0'

default_run_options[:pty] = true

set :stages, Dir['config/deploy/*.rb'].map { |f| File.basename(f, '.rb') }
set :default_stage, "development"
set :application, 'test_angular'
set :repository, 'git@github.com:svillafuerte/test_angular.git'
set :branch, :master
set :user, 'deploy'
set :group, 'deploy'
set :ssh_options, { forward_agent: true }
set :scm, "git"
set :use_sudo, false

set :linked_dirs, %w{node_modules app/bower_components}

# Default deploy_to directory is /var/www/my_app_name
#set :deploy_to, '/var/www/test_angular'
set :deploy_to, "/var/www/#{fetch(:application)}"

#after 'deploy:update_code', 'deploy:build:precompile'

# set :theme_path, Pathname.new('web/app/themes/mytheme')
# #set :local_app_path, Pathname.new('/Users/satcha/Projects/test_angular')
set :local_app_path, Pathname.new(File.dirname(__FILE__)).join('../')
set :local_dist_path, fetch(:local_app_path).join('dist')
# set :local_theme_path, fetch(:local_app_path).join(fetch(:theme_path))

after "deploy:update_code", "deploy:copy_assets"
before "deploy:copy_assets", "deploy:compile_assets"
before "deploy:finalize_update", "deploy:symlink"

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
  task :compile_assets, roles: :web do
    run_locally("gulp build")
  end

  desc 'Uploads a dist/ directory to the shared directory on the server'
  task :copy_assets do
    run_locally("tar -jcf dist.tar.bz2 dist")
    top.upload("dist.tar.bz2", "#{shared_path}", via: :scp)
    run("cd #{shared_path} && tar -jxf dist.tar.bz2 && rm dist.tar.bz2")
    run_locally("gulp clean")
    run_locally("rm dist.tar.bz2")

    # on roles(:web) do
    #   #upload! fetch(:local_app_path).join('dist').to_s, release_path, recursive: true
    #   #upload("dist")
    #   #run_locally "cd #{local_app_path}/dist && tar -jcf dist.tar.bz2 dist"
    #   #top.upload("dist/dist.tar.bz2", "#{shared_path}", via: :scp)
    #   #run("cd #{shared_path} && tar -jxf dist.tar.bz2 && rm dist.tar.bz2")
    #   upload(fetch(:local_app_path).join('dist.tar.bz2').to_s, shared_path)
    #   #top.upload("dist.tar.bz2", "#{shared_path}", via: :scp)
    #   #execute "cd #{shared_path} && tar -jxf dist.tar.bz2 && rm dist.tar.bz2"
    # end
  end

  task :symlink, roles: :web do
    run("rm -rf #{latest_release}/dist &&
         mkdir -p #{latest_release}/dist") #&&
         # mkdir -p #{shared_path}/dist &&
         # ln -s #{shared_path}/dist #{latest_release}/dist")
      # run("rm -rf #{latest_release}/public/swagger &&
      #      mkdir -p #{latest_release}/public &&
      #      mkdir -p #{shared_path}/swagger &&
      #      ln -s #{shared_path}/swagger #{latest_release}/public/swagger")
  end

  desc 'Restart application'
  task :restart, roles: :app, in: :sequence, wait: 5 do
    #nothing here, because there's no app server for this static site.
  end

  # def upload(directory)
  #   info "****EN UPLOAD"
  #   # Uploads a subdirectory of public/ to the shared directory on the server
  #   run_locally("cd dist && tar -jcf #{directory}.tar.bz2 #{directory}")
  #   top.upload("dist/#{directory}.tar.bz2", "#{shared_path}", via: :scp)
  #   run("cd #{shared_path} && tar -jxf #{directory}.tar.bz2 && rm #{directory}.tar.bz2")
  #   #run_locally("rm -rf dist/#{directory}/")
  #   #run_locally("rm dist/#{directory}.tar.bz2")
  # end

  # before :deploy, 'deploy:gulp_build'
  #before "deploy:updated", "deploy:copy_assets"
  #before "deploy:publishing", "deploy:symlink"
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
