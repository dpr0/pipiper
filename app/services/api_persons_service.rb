# frozen_string_literal: true

class ApiPersonsService

  attr_reader :persons

  def initialize(persons)
    @persons = persons
    @top_relations = []
    @bottom_relations = []
  end

  def find(id)
    @root_id = id
    add_parents(id)
    add_childs(id)
    @top_ids = @top_relations.map { |x| [x[:from], x[:to]] }.flatten.uniq - [id]
    relations = Relation.where(person_id: @top_ids).or(Relation.where(persona_id: @top_ids)).all
    relations_ids = relations.map { |x| [x.person_id, x.persona_id] }.flatten.uniq
    @top_relations += (relations.map { |relation| { from: relation.person_id, to: relation.persona_id, horizontal: true } })
    root = @persons.find { |x| x.id == id }
    para = []
    if root.sex_id == Sex[:male].id
      relation = Relation.find_by(person_id: root.id)
      @top_relations << { from: relation.person_id, to: relation.persona_id, horizontal: true } if relation
      para << relation.persona_id if relation
    else
      relation = Relation.find_by(persona_id: root.id)
      @top_relations << { from: relation.persona_id, to: relation.person_id, horizontal: true } if relation
      para << relation.person_id if relation
    end
    @top_ids = (@top_ids + relations_ids + [id]).uniq

    @bottom_ids = (@bottom_relations.map { |x| [x[:from], x[:to]] } + para).flatten.uniq
    persons = @persons.select { |p| (@top_ids + @bottom_ids).include? p.id }
    {
      root_person_id: id,
      top_relations: @top_relations.uniq,
      bottom_relations: @bottom_relations.uniq,
      persons: persons.map { |pp| person_info(pp) }
    }
  end

  private

  def add_parents(id)
    pp = @persons.find { |x| x.id == id }
    return unless pp

    father = @persons.find { |x| x.id == pp.father_id } if pp.father_id
    mother = @persons.find { |x| x.id == pp.mother_id } if pp.mother_id
    @top_relations << { from: id, to: father.id, horizontal: false } if father
    @top_relations << { from: id, to: mother.id, horizontal: false } if mother
    add_parents(father.id) if father
    add_parents(mother.id) if mother
  end

  def add_childs(id)
    pp = @persons.find { |x| x.id == id }
    return unless pp

    chs = @persons.select { |x| (pp.sex_id == Sex[:male].id ? x.father_id : x.mother_id) == pp.id }
    chs.each do |ch|

      if ch.sex_id == Sex[:male].id
        relation = Relation.find_by(person_id: ch.id)
        @bottom_relations << { from: relation.person_id, to: relation.persona_id, horizontal: true } if relation
      else
        relation = Relation.find_by(persona_id: ch.id)
        @bottom_relations << { from: relation.persona_id, to: relation.person_id, horizontal: true } if relation
      end

      @bottom_relations << { from: id, to: ch.id, horizontal: false }
      add_childs(ch.id)
    end
  end

  def person_info(pp)
    person = pp.slice(:id, :last_name, :first_name, :middle_name, :maiden_name, :sex_id, :birthdate, :deathdate, :avatar_url).symbolize_keys
    confirmed_data = pp.confirmed_last_name && pp.confirmed_first_name && pp.confirmed_middle_name && pp.confirmed_birthdate && pp.confirmed_maiden_name
    confirmed_data = confirmed_data && pp.confirmed_deathdate if person[:deathdate].present?
    person[:confirmed_data] = confirmed_data
    person[:additional_branch] = pp.id != @root_id && additional_branch(pp)
    person
  end

  def additional_branch(pp)
    if @top_ids.include?(pp.id)
      # @persons.count { |x| pp.id != x.id && (check_branch(x, pp, :father_id) || check_branch(x, pp, :mother_id)) } > 0
      @persons.count { |x| pp.id != x.id && [x.father_id, x.mother_id].include?(pp.id) && @top_ids.exclude?(x.id) } > 0
    elsif @bottom_ids.include?(pp.id)
      (pp.father_id.present? && !(@top_ids + @bottom_ids).include?(pp.father_id)) || (pp.mother_id.present? && !(@top_ids + @bottom_ids).include?(pp.mother_id))
      # @persons.count { |x| (pp.father_id.present? || pp.mother_id.present?) && @bottom_ids.exclude?(x.id) } > 0
    end
  end

  def check_branch(x, pp, parent)
    !x.send(parent).nil? && !pp.send(parent).nil? && x.send(parent) == pp.send(parent)
  end
end
