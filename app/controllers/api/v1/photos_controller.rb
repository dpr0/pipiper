# frozen_string_literal: true

class Api::V1::PhotosController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_request
  before_action :load_person
  before_action :load_photo, only: %i[update destroy show]

  resource_description do
    short 'Фото (Галерея)'
  end

  def_param_group :photo do
    property :id, Integer, desc: ''
    param_group :photo_short
    property :created_at, DateTime, desc: ''
    property :updated_at, DateTime, desc: ''
  end

  def_param_group :photo_short do
    param :date,         String
    param :info,         String
    param :location,     String
    param :url,          String
    param :attachment,   ActionDispatch::Http::UploadedFile
  end

  api :GET, '/v1/person/:person_id/photos/:id'
  returns code: 200, desc: '' do
    property :photo, Hash, desc: '' do
      param_group :photo
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
    render json: { fact: @photo, versions: Version.changes(@photo) }, status: @person ? :ok : :not_found
  end

  api :POST, '/v1/person/:person_id/photos'
  returns code: 200, desc: '' do
    property :photo, Hash, desc: '' do param_group :photo_short end
  end
  def create
    @photo = @person.photos.new(photo_params)
    saved = @photo.save
    @photo.update(url: @photo.attachment_url)
    if params[:avatar] == 'true'
      hash = { avatar_url: @photo.attachment_url }
      @person.update(hash)
      Version.prepare(:update, @photo.person.family_tree.id, current_user, @person, hash).add
    end
    Version.prepare(method_name(caller(0)), @photo.person.family_tree.id, current_user, @photo, photo_params).add if saved
    render_json(saved, @photo.attributes)
  end

  api :PATCH, '/v1/person/:person_id/photos/:id'
  returns code: 200, desc: '' do
    property :photo, Hash, desc: '' do param_group :photo_short end
  end
  def update
    Version.prepare(method_name(caller(0)), @photo.person.family_tree.id, @current_user, @photo, photo_params).add
    saved = @photo.update(photo_params)
    @photo.update(url: @photo.attachment_url)
    @person.update(avatar_url: @photo.attachment_url) if params[:avatar] == 'true'
    render_json(saved, @photo.attributes)
  end

  api :DELETE, '/v1/person/:person_id/photos/:id'
  returns code: 200, desc: ''
  def destroy
    params = { deleted_at: Time.now }
    @photo.update(params)
    Version.prepare(method_name(caller(0)), @photo.person.family_tree.id, @current_user, @photo, params).add
    render json: { status: :deleted }, status: :ok
  end

  private

  def load_photo
    @photo = Photo.find_by(id: params[:id])
    render(json: { error: "photo: #{params[:id]} - access denied" }, status: :unprocessable_entity) and return unless @photo
  end

  def photo_params
    params.require(:photo).permit(:date, :info, :info_type_id, :location, :attachment)
  end

  def load_person
    @person = Person.find_by(family_tree_id: current_user.family_tree_users(&:family_tree_id).map(&:family_tree_id), id: params[:person_id])
    render(json: { error: "person: #{params[:person_id]} - access denied" }, status: :unprocessable_entity) and return unless @person
  end
end
