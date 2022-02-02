# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::Base
      def render_json(bool, model)
        if bool
          render json: model, status: :ok
        else
          render json: model&.errors, status: :unprocessable_entity
        end
      end

      private

      def to_phone(phone)
        tel = phone.gsub(/[^\d]/, '').last(10)
        tel.size == 10 ? "+7#{tel}" : nil
      end

      def method_name(calller)
        calller[0].split('`').pop.gsub("'", '')
      end

      def authenticate_request
        @current_user = User.auth_by_token(request.headers)
        render json: { error: 'Not Authorized' }, status: 401 unless @current_user
      end
    end
  end
end
