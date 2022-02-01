# frozen_string_literal: true

module Api::V1
  class RelationshipsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :load_persons_ids

    resource_description do
      short 'Отношения (связи)'
    end

    def_param_group :relation do
      param :first_person_id,        Integer, required: true
      param :second_person_id,       Integer, required: true
      param :relationship_type_id,   Integer, required: true
    end

    api :POST, '/v1/relationships'
    returns code: 200, desc: '' do
      param_group :relation
    end
    def create
      if load_persons_ids.map { |x| relationship_params.slice(:first_person_id, :second_person_id).values - x }.find(&:empty?)
        resp = case RelationshipType.cached_by_id[relationship_params[:relationship_type_id]]&.code
        when 'husband'
          relation_params = { person_id: relationship_params[:second_person_id], persona_id: relationship_params[:first_person_id]}
          relation = Relation.new(relation_params.merge(relation_type_id: 1))
          saved = relation.save
          if saved
            Version.prepare(method_name(caller(0)), relation.person.family_tree.id, current_user, relation, relation_params).add
            persons = Person.where(mother_id: relation.persona_id)
            model_changes = { father_id: relation.person_id }
            persons.each { |p| p.update_with_version(:update, current_user, model_changes) if p.father_id.nil? }
          end
          saved
        when 'wife'
          relation_params = { person_id: relationship_params[:first_person_id], persona_id: relationship_params[:second_person_id]}
          relation = Relation.new(relation_params.merge(relation_type_id: 1))
          saved = relation.save
          if saved
            Version.prepare(method_name(caller(0)), relation.person.family_tree.id, current_user, relation, relation_params).add
            persons = Person.where(father_id: relation.person_id)
            model_changes = { mother_id: relation.persona_id }
            persons.each { |p| p.update_with_version(:update, current_user, model_changes) if p.mother_id.nil? }
          end
          saved
        when 'son', 'daughter'
          parent = Person.find_by_id(relationship_params[:first_person_id])
          person = Person.find_by_id(relationship_params[:second_person_id])
          person_params = if parent.sex_id == Sex[:male].id
                            { father_id: parent.id, mother_id: Relation.find_by(person_id: parent.id)&.persona_id }
                          else
                            { father_id: Relation.find_by(persona_id: parent.id)&.person_id, mother_id: parent.id }
                          end
          person.update_with_version('update', @current_user, person_params)
          true
        when 'brother', 'sister'
          person1 = Person.find_by_id(relationship_params[:first_person_id])
          person2 = Person.find_by_id(relationship_params[:second_person_id])
          if person1.father_id.nil? && person1.mother_id.nil?
            parent = Person.create(last_name: 'Неизвестно',
                                   first_name: 'Неизвестно',
                                   sex_id: Sex[:female].id,
                                   confirmed_last_name: false,
                                   confirmed_first_name: false,
                                   confirmed_middle_name: false,
                                   confirmed_maiden_name: false,
                                   confirmed_birthdate: false,
                                   confirmed_deathdate: false)
            person1.update_with_version('update', @current_user, {mother_id: parent.mother_id})
          end
          person2.update_with_version('update', @current_user, {father_id: person1.father_id}) if person2.father_id.nil? && !person1.father_id.nil?
          person2.update_with_version('update', @current_user, {mother_id: person1.mother_id}) if person2.mother_id.nil? && !person1.mother_id.nil?
          true
        when 'father'
          person = Person.find_by_id(relationship_params[:first_person_id])
          person.update_with_version('update', @current_user, {father_id: relationship_params[:second_person_id]})
          if person.mother_id.present?
            relation_params = { person_id: person.father_id, persona_id: person.mother_id, relation_type_id: 1 }
            relation = Relation.new(relation_params)
            saved = relation.save
            Version.prepare(method_name(caller(0)), relation.person.family_tree.id, current_user, relation, relation_params).add if saved
          end
          true
        when 'mother'
          person = Person.find_by_id(relationship_params[:first_person_id])
          person.update_with_version('update', @current_user, {mother_id: relationship_params[:second_person_id]})
          if person.father_id.present?
            relation_params = { person_id: person.father_id, persona_id: person.mother_id, relation_type_id: 1 }
            relation = Relation.new(relation_params)
            saved = relation.save
            Version.prepare(method_name(caller(0)), relation.person.family_tree.id, current_user, relation, relation_params).add if saved
          end
          true
        else
          nil
        end
        render_json(!resp.nil?, {created: RelationshipType.cached_by_id[relationship_params[:relationship_type_id]]&.name})
      else
        render json: { error: 'persons_ids not in one family_tree - access denied' }, status: :unprocessable_entity
      end
    end

    private

    def relationship_params
      params.permit(:first_person_id, :second_person_id, :relationship_type_id)
    end

    def load_persons_ids
      current_user.family_tree_users(&:family_tree_id).map { |x| x.family_tree.person_ids }
    end
  end
end
