class ReportJob < ApplicationJob
  queue_as :default

  def perform(report_type, params, tenant)
    report = report_type.constantize.new(params, tenant)
    report.generate!
  end

end
