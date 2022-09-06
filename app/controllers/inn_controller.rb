# frozen_string_literal: true

class InnController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    json = JSON.parse RestClient.get("https://gosnalogi.ru/ajax/taxes_inn?inn=#{params[:id]}")
    render status: :ok, json: json
  end
end
