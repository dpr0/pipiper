# frozen_string_literal: true

class UsersController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :doorkeeper_authorize! # -> { doorkeeper_authorize! :read, :write }

  def index
    head(:ok)
  end

  def show; end

  def unlink
    render_status({})
  end

  def devices
    render_status(user_id: current_user.id.to_s, devices: Device.user_devices(current_user.id))
  end

  def query
    render_status(devices: Device.user_query(current_user.id))
  end

  def action
    response = ActionService.new(current_user.id, params.dig(:payload, :devices)).call if params.dig(:payload, :devices).present?
    render_status(user_id: current_user.id.to_s, devices: response || [])
  end

  private

  def current_user
    @user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def render_status(payload = {})
    json = { request_id: request.headers['X-Request-Id'], payload: payload }
    Rails.logger.info JSON.pretty_generate(json)
    render status: :ok, json: json
  end
end
