# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_request, except: [:login, :check, :registration, :registration_call, :callcheck]

      resource_description do
        short 'Пользователи'
        # formats ['json']
        # meta author: {name: 'John', surname: 'Doe'}
      end

      def_param_group :user do
        param :phone,    String, required: true
        param :provider, String
        param :smscode,  String
        param :uid,      String
      end

      api :GET, '/v1/users/check'
      returns code: 200, desc: 'token' do
        property :user_exist, [true, false], desc: ''
      end
      def check
        phone = to_phone(params[:phone])
        user = User.where(phone: phone, provider: :phone).first
        render json: { user_exist: user.present? }
      end

      api :POST, '/v1/users/registration', 'Регистрация (отправка смс на номер)'
      param :phone, String, required: true
      returns code: 200, desc: 'status'
      def registration
        phone = to_phone(params[:phone])
        render(json: { error: 'The phone number must be a 10 digits (example: 999-111-22-33, 9991112233, 999 111 2233)' }, status: :unauthorized) and return unless phone

        user = User.where(provider: :phone, phone: phone).first
        render(json: { error: "User with phone: #{phone} not found" }, status: :unauthorized) and return unless user&.persisted?

        code = phone == '+79990000000' ? '000000' : rand(100_000...1_000_000)
        user.update(smscode: "#{Time.now.to_i}-#{code}")
        if code != '000000'
          smsru = RestClient.get("https://sms.ru/sms/send?api_id=#{ENV['SMS_API_KEY']}&to=#{phone}&msg=#{code}&json=1")
          render(json: { error: "SMS service status: #{smsru.code}" }, status: :unauthorized) and return if smsru.code != 200

          # {"status"=>"OK", "status_code"=>100, "balance"=>120, "sms"=>
          # {"79191087399"=>{"status"=>"OK", "status_code"=>100, "sms_id"=>"202136-1000001", "cost"=>"0.00"}}}
          resp = JSON.parse(smsru.body).with_indifferent_access
          status = resp[:sms][phone.gsub(/[^\d]/, '')] if resp[:status_code] == 100

          if status.nil? || resp[:status] != 'OK' || status[:status] != 'OK'
            render(json: { error: "SMS service status error: #{status ? status[:status_text] : resp[:status_text]}" }, status: :unauthorized) and return
          end
        end

        render json: { status: "sms code send to #{phone}" }
      end

      api :POST, '/v1/users/registration_call', 'Регистрация (отправка смс на номер)'
      param :phone, String, required: true
      returns code: 200, desc: 'status'
      def registration_call
        phone = to_phone(params[:phone])
        render(json: { error: 'The phone number must be a 10 digits (example: 999-111-22-33, 9991112233, 999 111 2233)' }, status: :unauthorized) and return unless phone

        user = User.where(provider: :phone, phone: phone).first
        render(json: { error: "User with phone: #{phone} not found" }, status: :unauthorized) and return unless user&.persisted?

        if phone == '+79990000000'
          user.update(callcheck: "#{Time.now.to_i}/true")
          render json: { status: :ok, call_phone: 0, call_phone_html: 0 } and return
        end
        smsru = RestClient.get("https://sms.ru/callcheck/add?api_id=#{ENV['SMS_API_KEY']}&phone=#{phone}&json=1")
        # { "status": "OK", "status_code": 100, "check_id": "202136-8704838", "call_phone": "+74951206695",
        #   "call_phone_pretty": "+7 (495) 120-6695", "call_phone_html": "<a href=\"callto:+74951206695\">+7 (495) 120-6695</a>" }
        render(json: { error: "SMS service status: #{smsru.code}" }, status: :unauthorized) and return if smsru.code != 200

        resp = JSON.parse(smsru.body).with_indifferent_access
        if resp[:status_code] == 100
          user.update(callcheck: resp[:check_id])
          render json: { status: :ok, call_phone: resp[:call_phone], call_phone_html: resp[:call_phone_html] }
        else
          render json: { status: :error, code: resp[:status_code] }
        end
      end

      api :POST, '/v1/users/login', 'получение токена'
      param_group :user
      returns code: 200, desc: 'token' do
        property :auth_token, String, desc: 'token with expired date'
        property :role, String, desc: 'role'
      end
      def login
        phone = to_phone(params[:user][:phone])
        email = "#{phone}@phone"
        user = User.where(provider: :phone, phone: phone).first
        params[:user][:provider] ||= 'phone'
        params[:user][:uid]      ||= email
        params[:user][:email]    ||= email
        render(json: { error: 'Not Authorized' }, status: :unauthorized) and return unless user&.persisted?

        code = user.callcheck.split('/') if user.callcheck.present?
        if !code.nil? && code.size == 2 && (Time.now.to_i - code.first.to_i) < ENV['CALL_CHECK_TIMEOUT'].to_i && code.last == 'true'
          @user = User.find_for_oauth(params[:user])
        end

        if @user.nil?
          smscode = user.smscode.split('-') if user.smscode
          render(json: { error: 'user not verified via phone or sms' }, status: :unauthorized) and return unless smscode.present? && smscode.size == 2

          sms_time_ago = (Time.now.to_i - smscode.first.to_i) - ENV['SMS_CODE_TIMEOUT'].to_i
          if sms_time_ago.positive?
            render(json: { error: "sms code verification time ended #{sms_time_ago} seconds ago" }, status: :unauthorized) and return
          end
          if smscode.last != params[:smscode]
            render(json: { error: 'sms code not valid' }, status: :unauthorized) and return
          end

          @user = User.find_for_oauth(params[:user])
        end

        render(json: { error: 'Not Authorized' }, status: :unauthorized) and return unless @user&.persisted?

        sign_in @user, event: :authentication

        family_tree_user = FamilyTreeUser.find_by(user_id: @user.id)
        role = Role.cached_by_id[family_tree_user.role_id].code if family_tree_user
        render json: { id: current_user.id, auth_token: JsonWebToken.encode(user_id: current_user.id), role: role }
      end

      api :POST, '/v1/users/callcheck', 'колбэк после подтверждения звонка'
      returns code: 200
      def callcheck
        params['data'].each_value do |val|
          resp = val.split("\n")
          if resp[0] == 'callcheck_status'
            user = User.where(callcheck: resp[1], provider: :phone).first
            user&.update(callcheck: "#{resp[3]}/#{resp[2] == '401'}")
          end
        end
        render json: { text: 100, status: :ok }
      end
    end
  end
end
