# frozen_string_literal: true

module Api
  module V1
    class DictionaryController < ApplicationController
      protect_from_forgery with: :null_session

      resource_description do
        short 'Словари'
      end

      def_param_group :dict do
        property :id, Integer, desc: ''
        property :code, String, desc: ''
        property :name, String, desc: ''
      end

      api :GET, '/v1/dictionary/roles', 'Роли пользователей'
      returns code: 200 do param_group :dict end
      def roles
        render_json(true, Role.all_cached)
      end

      api :GET, '/v1/dictionary/fact_types', 'Типы фактов'
      returns code: 200 do
        param_group :dict
        param :for_man, String
        param :for_woman, String
      end
      def fact_types
        render_json(true, FactType.all)
      end

      api :GET, '/v1/dictionary/info_types', 'Типы инфо'
      returns code: 200 do param_group :dict end
      def info_types
        render_json(true, InfoType.all_cached)
      end

      api :GET, '/v1/dictionary/relationship_types', 'Типы отношений'
      returns code: 200 do param_group :dict end
      def relationship_types
        render_json(true, RelationshipType.all_cached)
      end

      api :GET, '/v1/dictionary/relation_types', 'Типы отношений'
      returns code: 200 do param_group :dict end
      def relation_types
        render_json(true, RelationType.all_cached)
      end

      api :GET, '/v1/dictionary/sex', 'Пол'
      returns code: 200 do param_group :dict end
      def sex
        render_json(true, Sex.all_cached)
      end
    end
  end
end
