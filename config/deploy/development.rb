set :scm, :none
set :hipchat_alert, false
set :repository, "."
set :deploy_via, :copy

server '54.89.1.103', :app, :web, primary: true
