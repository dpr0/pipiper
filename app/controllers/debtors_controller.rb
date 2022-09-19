# frozen_string_literal: true

class DebtorsController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    send_data(DebtorsService.new(params[:id]).call, filename: 'response.csv', type: 'text/csv')
  end
end
