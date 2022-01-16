# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def invite_email
    mail(to: 'dvitvitskiy.pro@yandex.ru', subject: "You invited #{ENV['HOST']}")
  end
end
