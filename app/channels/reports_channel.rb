class ReportsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "report:#{params[:report_id]}"
  end
end
