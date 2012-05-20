class AdminMailer < ActionMailer::Base
  default from: "ehl@evehitlist.com"
  
  def error_mail(error_msg=nil)
    @error_msg = error_msg || "No message came through"
    mail(:to =>"curtismfoster@gmail.com", :subject => "EHL ERROR OCCURRED")
  end
  
  def payout(record, payout) #list = [[evename, isk]]
    @payout = payout
    @record = record
    mail(:to => "curtismfoster@gmail.com", :subject => "EHL PAYOUT, #{Time.now}")
  end
end
