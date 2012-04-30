class GatherTargetRecord
  @queue = :pull_target_records_queue
  
  def self.perform(target_id)
    target = WantedToon.find_by_id(target_id)
    PullWantedToonRecord.find_new_bc_records(target)
  end
end