set :stage,  :staging
set :branch, 'master'

role :app, %w{johannes}
role :web, %w{johannes}
role :db,  %w{johannes}

server 'johannes', user: 'deploy'

