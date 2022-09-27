# frozen_string_literal: true

class FsinController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    render status: :ok, json: FsinService.new(params[:id]).call
  end
end
