# frozen_string_literal: true

class DebtorsController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    send_data(DebtorsService.new.call, filename: 'response.csv', type: 'text/csv')
  end
end
