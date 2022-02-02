# frozen_string_literal: true

class PersonsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_person, only: %i[edit show update destroy graph]
  before_action :family_trees, only: %i[new edit]
  before_action :mens_and_womens, only: %i[edit new]

  LINKS = {
      link_vk: 'fab fa-vk',
      link_fb: 'fab fa-odnoklassniki',
      link_ig: 'fab fa-facebook',
      link_ok: 'fab fa-instagram',
      link_tg: 'fab fa-telegram-plane',
      link_tw: 'fab fa-twitter',
      link_tt: 'fas fa-house-user',
      link_ch: 'fab fa-tiktok'
  }.freeze

  def show
    redirect_to family_trees_path unless @person
  end

  def graph
    (redirect_to family_trees_path and return) unless @person
    @persons = @family_tree.persons.order(:birthdate)
    @relations = Relation.where(person_id: @persons.ids).or(Relation.where(persona_id: @persons.ids)).all
    service = PersonsService.new(@persons, @relations)
    @hash = service.graph(@person)
  end

  def new; end

  def edit; end

  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        @person.images.attach(params[:person][:images])
        format.html { redirect_to family_tree_path(@person.family_tree_id), notice: 'Родственник создан.' }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @person.update(person_params)
        @person.images.attach(params[:person][:images])
        format.html { redirect_to family_tree_path(@person.family_tree_id), notice: 'Родственник обновлён.' }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @person.family_tree.user.id == current_user&.id
      @person.destroy
      respond_to do |format|
        format.html { redirect_to family_trees_url, notice: 'Родственник удалён.' }
        format.json { head :no_content }
      end
    else
      render json: { status: :not_deleted }, status: :unprocessable_entity
    end
  end

  private

  def load_person
    @person = if params[:id] == current_user&.person_id
                current_user.person
              else
                Person.where(family_tree_id: current_user.family_tree_users.map(&:family_tree_id)).find_by(id: params[:id])
              end
    @family_tree = @person&.family_tree
    @family_tree_user = @family_tree.family_tree_users.find { |ft| ft.family_tree_id == @person.family_tree_id && ft.user_id == current_user&.id } if @family_tree
  end

  def family_trees
    @family_trees = FamilyTree.where(id: current_user.family_tree_users.map(&:family_tree_id))
  end

  def mens_and_womens
    @person ||= Person.new(family_tree_id: params[:family_tree_id])
    @family_tree ||= FamilyTree.find(params[:family_tree_id]) if params[:family_tree_id]
    return unless @family_tree

    @mens = @family_tree.persons.where(sex_id: [Sex[:male].id]).where.not(id: [@person.id])
    @womens = @family_tree.persons.where(sex_id: Sex[:female].id).where.not(id: [@person.id])
  end

  def person_params
    params.require(:person).permit(
      :family_tree_id, :sex_id, :last_name, :first_name, :middle_name, :maiden_name, :father_id, :mother_id, :birthdate, :deathdate,
      :confirm_last_name, :confirm_first_name, :confirm_middle_name, :confirm_maiden_name, :confirm_birthdate, :avatar,
      :address, :contact, :document, :info, :link_vk, :link_fb, :link_ig, :link_ok, :link_tg, :link_tw, :link_tt, :link_ch
    )
  end
end
