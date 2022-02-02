# frozen_string_literal: true

module Api
  module V1
    class ArchivesController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_request
      before_action :load_person
      before_action :load_archive, only: %i[update destroy show]

      resource_description do
        short 'Архив'
      end

      def_param_group :archive do
        property :id, Integer, desc: ''
        param_group :archive_short
        property :created_at, DateTime, desc: ''
        property :updated_at, DateTime, desc: ''
      end

      def_param_group :archive_short do
        param :person_id,    Integer, required: true
        param :date,         String
        param :info,         String
        param :location,     String
        param :url,          String
        param :filename,     String
        param :content_type, String
        param :attachment,   ActionDispatch::Http::UploadedFile
      end

      api :GET, '/v1/person/:person_id/archives/:id'
      returns code: 200, desc: '' do
        property :archive, Hash, desc: '' do
          param_group :archive
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
        render json: { fact: @archive, versions: Version.changes(@archive) }, status: @person ? :ok : :not_found
      end

      api :POST, '/v1/person/:person_id/archives'
      returns code: 200, desc: '' do
        property :archive, Hash, desc: '' do param_group :archive_short end
      end
      def create
        @archive = @person.archives.new(archive_params)
        saved = @archive.save
        @archive.update(url: @archive.attachment_url, content_type: @archive.attachment.content_type, filename: @archive.attachment.filename.to_s)
        Version.prepare(method_name(caller(0)), @archive.person.family_tree.id, current_user, @archive, archive_params).add if saved
        render_json(saved, @archive.attributes)
      end

      api :PATCH, '/v1/person/:person_id/archives/:id'
      returns code: 200, desc: '' do
        property :archive, Hash, desc: '' do param_group :archive_short end
      end
      def update
        Version.prepare(method_name(caller(0)), @archive.person.family_tree.id, @current_user, @archive, archive_params).add
        saved = @archive.update(archive_params)
        @archive.update(url: @archive.attachment_url, content_type: @archive.attachment.content_type, filename: @archive.attachment.filename.to_s)
        render_json(saved, @archive.attributes)
      end

      api :DELETE, '/v1/person/:person_id/archives/:id'
      returns code: 200, desc: ''
      def destroy
        params = { deleted_at: Time.now }
        @archive.update(params)
        Version.prepare(method_name(caller(0)), @archive.person.family_tree.id, @current_user, @archive, params).add
        render json: { status: :deleted }, status: :ok
      end

      private

      def load_archive
        @archive = Archive.find_by(id: params[:id])
        render(json: { error: "archive: #{params[:id]} - access denied" }, status: :unprocessable_entity) and return unless @archive
      end

      def archive_params
        params.require(:archive).permit(:date, :info, :location, :attachment)
      end

      def load_person
        @person = Person.find_by(family_tree_id: current_user.family_tree_users(&:family_tree_id).map(&:family_tree_id), id: params[:person_id])
        render(json: { error: "person: #{params[:person_id]} - access denied" }, status: :unprocessable_entity) and return unless @person
      end
    end
  end
end
