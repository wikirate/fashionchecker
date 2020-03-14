set :stage,  :production
set :branch, 'master'

role :app, %w{kasper}
role :web, %w{kasper}
role :db,  %w{kasper}

server 'kasper', user: 'deploy'

