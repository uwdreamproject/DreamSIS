class ReportJob
  include SuckerPunch::Job
  workers 4

  def perform(report_id)
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        report = Report.find(report_id)
        Rails.logger.info { "[Report #{report_id.to_s}] Generating report id #{report.id.to_s}" }
        report.generate!
        Rails.logger.info { "[Report #{report_id.to_s}] Done." }
      end
    rescue => e
      Rails.logger.error { "[Report #{report_id.to_s}] ERROR: #{e.message}" }
      Rollbar.error(e, :report_id => report_id)
    end
  end
end
