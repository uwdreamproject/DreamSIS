class ClearinghouseRequestWorker
  include Sidekiq::Worker

  def perform(clearinghouse_request_id, file_path)
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        request = ClearinghouseRequest.find(clearinghouse_request_id)
        request.logger.info { "[ClearinghouseRequest #{clearinghouse_request_id.to_s}] Processing request file" }
        request.process_detail_file(file_path)
        request.logger.info { "[ClearinghouseRequest #{clearinghouse_request_id.to_s}] Done." }
        request.store_permanently!(request.logger.instance_variable_get(:@logdev).filename)
      end
    rescue => e
      request.logger.error { "[ClearinghouseRequest #{clearinghouse_request_id.to_s}] ERROR: #{e.message}" }
      Rollbar.error(e, :clearinghouse_request_id => clearinghouse_request_id)
    end
  end

end
