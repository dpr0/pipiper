# frozen_string_literal: true

class FsinController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    send_data(FsinService.new(params[:id]).call, filename: 'response.csv', type: 'text/csv')
  end
end
