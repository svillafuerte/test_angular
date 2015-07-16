# config valid only for current version of Capistrano
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

set :deploy_to, "/var/www/#{fetch(:application)}"

set :local_app_path, Pathname.new(File.dirname(__FILE__)).join('../')
set :local_dist_path, fetch(:local_app_path).join('dist')

after "deploy:update_code", "deploy:copy_assets:precompile"
before "deploy:copy_assets:precompile", "deploy:compile_assets"
after "deploy:copy_assets:precompile", "deploy:copy_assets:symlink"

namespace :deploy do

  desc 'Run gulp to compile the static site'
  task :compile_assets, roles: :web do
    run_locally("gulp build")
  end

  namespace :copy_assets do

    desc 'Uploads a dist/ directory to the shared directory on the server'
    task :precompile do
      run_locally("tar -jcf dist.tar.bz2 dist")
      run("cd #{shared_path} && rm -rf dist")
      top.upload("dist.tar.bz2", "#{shared_path}", via: :scp)
      run("cd #{shared_path} && tar -jxf dist.tar.bz2 && rm dist.tar.bz2")
      run_locally("gulp clean")
      run_locally("rm dist.tar.bz2")
    end

    desc 'Symlink dist/ directory'
    task :symlink, roles: :web do
      run("rm -rf #{latest_release}/dist &&
           ln -s #{shared_path}/dist #{latest_release}/dist")
        # run("rm -rf #{latest_release}/public/swagger &&
        #      mkdir -p #{latest_release}/public &&
        #      mkdir -p #{shared_path}/swagger &&
        #      ln -s #{shared_path}/swagger #{latest_release}/public/swagger")
    end
  end

  desc 'Restart application'
  task :restart, roles: :app, in: :sequence, wait: 5 do
    #nothing here, because there's no app server for this static site.
  end
end 
