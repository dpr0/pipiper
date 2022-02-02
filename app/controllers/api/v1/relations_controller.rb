# frozen_string_literal: true

class Api::V1::RelationsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_request
  before_action :load_persons_ids

  resource_description do
    short 'Отношения (связи)'
  end

  def_param_group :relation do
    param :person_id,        Integer, required: true
    param :persona_id,       Integer, required: true
    param :relation_type_id, Integer, required: true
  end

  api :POST, '/v1/relations'
  returns code: 200, desc: '' do
    param_group :relation
  end
  def create
    if load_persons_ids.map { |x| relation_params.slice(:person_id, :persona_id).values - x }.find(&:empty?)
      @relation = Relation.new(relation_params)
      saved = @relation.save
      Version.prepare(method_name(caller(0)), @relation.person.family_tree.id, current_user, @relation, relation_params).add if saved
      render_json(saved, @relation.attributes)
    else
      render json: { error: 'persons_ids not in one family_tree - access denied' }, status: :unprocessable_entity
    end
  end

  api :DELETE, '/v1/relations/:id'
  returns code: 200, desc: ''
  def destroy
    persons_ids = load_persons_ids.flatten
    @relation = Relation.where(person_id: persons_ids).or(Relation.where(persona_id: persons_ids)).find_by(id: params[:id])
    if @relation
      @relation.destroy
      Version.prepare(method_name(caller(0)), @relation.person.family_tree.id, @current_user, @relation, { status: :deleted }).add
      render json: { status: :deleted }, status: :ok
    else
      render json: { error: "relation: #{params[:id]} - access denied" }, status: :unprocessable_entity
    end
  end

  private

  def relation_params
    params.permit(:person_id, :persona_id, :relation_type_id)
  end

  def load_persons_ids
    current_user.family_tree_users(&:family_tree_id).map { |x| x.family_tree.person_ids }
  end
end
