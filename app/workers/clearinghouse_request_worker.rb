class ClearinghouseRequestWorker
  include Sidekiq::Worker

  def perform(clearinghouse_request_id, file_path)
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        request = ClearinghouseRequest.find(clearinghouse_request_id)
        request.log "Processing request file"
        request.process_detail_file(file_path)
        request.log "Done."
        request.store_log_file_permanently!
      end
    rescue => e
      request.log "ERROR: #{e.message}", :error
      Rollbar.error(e, :clearinghouse_request_id => clearinghouse_request_id)
    end
  end

end
