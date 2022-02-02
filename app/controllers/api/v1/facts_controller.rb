# frozen_string_literal: true

module Api
  module V1
    class FactsController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_request
      before_action :load_person
      before_action :load_fact, only: %i[update destroy show]

      resource_description do
        short 'Факты (Биография)'
      end

      def_param_group :fact do
        property :id, Integer, desc: ''
        param_group :fact_short
        property :created_at, DateTime, desc: ''
        property :updated_at, DateTime, desc: ''
      end

      def_param_group :fact_short do
        param :person_id,    Integer, required: true
        param :date,         String
        param :info,         String
        param :location,     String
        param :fact_type_id, Integer
        param :attachment,   ActionDispatch::Http::UploadedFile
      end

      api :GET, '/v1/person/:person_id/facts/:id'
      returns code: 200, desc: '' do
        property :fact, Hash, desc: '' do
          param_group :fact
        end
        property :versions, array_of: Hash, desc: '' do
          property :id,         Integer,  desc: ''
          property :model,      String,   desc: ''
          property :model_id,   Integer,  desc: ''
          property :changes,    Hash,     desc: ''
          property :created_at, DateTime, desc: ''
          property :updated_at, DateTime, desc: ''
        end
      end
      def show
        render json: { fact: @fact, versions: Version.changes(@fact) }, status: @person ? :ok : :not_found
      end

      api :POST, '/v1/person/:person_id/facts'
      returns code: 200, desc: '' do
        property :fact, Hash, desc: '' do param_group :fact_short end
      end
      def create
        @fact = @person.facts.new(fact_params)
        saved = @fact.save
        if saved
          @person.update(birthdate: fact_params[:date]) if @fact.fact_type_id == FactType[:birth].id
          @person.update(deathdate: fact_params[:date]) if @fact.fact_type_id == FactType[:death].id
          Version.prepare(method_name(caller(0)), @fact.person.family_tree.id, current_user, @fact, fact_params).add
        end
        render_json(saved, @fact.attributes.merge(attachment_url: @fact.attachment_url))
      end

      api :PATCH, '/v1/person/:person_id/facts/:id'
      returns code: 200, desc: '' do
        property :fact, Hash, desc: '' do param_group :fact_short end
      end
      def update
        @fact.person.update(birthdate: fact_params[:date]) if fact_params[:fact_type_id] == FactType[:birth].id && fact_params[:date] != @fact.date
        @fact.person.update(deathdate: fact_params[:date]) if fact_params[:fact_type_id] == FactType[:death].id && fact_params[:date] != @fact.date
        Version.prepare(method_name(caller(0)), @fact.person.family_tree.id, @current_user, @fact, fact_params).add
        render_json(@fact.update(fact_params), @fact.attributes.merge(attachment_url: @fact.attachment_url))
      end

      api :DELETE, '/v1/person/:person_id/facts/:id'
      returns code: 200, desc: ''
      def destroy
        params = { deleted_at: Time.now }
        @fact.update(params)
        Version.prepare(method_name(caller(0)), @fact.person.family_tree.id, @current_user, @fact, params).add
        render json: { status: :deleted }, status: :ok
      end

      private

      def load_fact
        @fact = Fact.find_by(id: params[:id])
        render(json: { error: "fact: #{params[:id]} - access denied" }, status: :unprocessable_entity) and return unless @fact
      end

      def fact_params
        params.require(:fact).permit(:date, :info, :fact_type_id, :location, :attachment)
      end

      def load_person
        @person = Person.find_by(family_tree_id: current_user.family_tree_users(&:family_tree_id).map(&:family_tree_id), id: params[:person_id])
        render(json: { error: "person: #{params[:person_id]} - access denied" }, status: :unprocessable_entity) and return unless @person
      end
    end
  end
end
