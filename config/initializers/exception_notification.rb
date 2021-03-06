if Rails.env.production?
  #Exception Notification
  Rails.application.config.middleware.use ExceptionNotifier,
      :email_prefix => APP_CONFIG[:exception_email_prefix],
      :sender_address => APP_CONFIG[:exception_sender_address],
      :exception_recipients => APP_CONFIG[:exception_recipients]
end
