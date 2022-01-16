# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "admin@#{ENV['HOST']}"
  layout 'mailer'
end
