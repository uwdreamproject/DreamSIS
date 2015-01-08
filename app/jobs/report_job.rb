class ReportJob
  include SuckerPunch::Job

  def perform(report_id)
    begin
      pause 60
      ActiveRecord::Base.connection_pool.with_connection do
        report = Report.find(report_id)
        Rails.logger.info { "[Report #{report_id.to_s}] Generating report id #{report.id.to_s}" }
        Report.transaction do
          report.generate!
        end
        Rails.logger.info { "[Report #{report_id.to_s}] Done." }
      end
    rescue => e
      Rails.logger.error { "[Report #{report_id.to_s}] ERROR: #{e.message}" }
    end
  end
end
