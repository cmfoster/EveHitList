require 'resque/tasks'

task "resque:setup" => :environment

namespace :queue do
  task :restart_workers => :environment do
    pids = Array.new
    
    Resque.workers.each do |worker|
      pids << worker.to_s.split(/:/).second
    end
    
    if pids.size > 0
      system("kill -QUIT #{pids.join(' ')}")
    end
    
    :environment == "production" ? system("rm /home/n0de/.god/pids/resque-*.pid") : system("rm /Users/curtis/.god/pids/resque-*.pid")
  end
end

