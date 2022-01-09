# frozen_string_literal: true

class FamilyTreesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_family_tree, only: %i[edit show update destroy]

  def index
    family_trees
  end

  def show
    (redirect_to family_trees_path and return) unless @family_tree
    @root_id = current_user.family_tree_users.find_by(user_id: current_user.id, family_tree_id: params[:id]).root_person_id
    @persons = @family_tree.persons.order(:birthdate)
    @relations = Relation.where(person_id: @persons.ids).or(Relation.where(persona_id: @persons.ids)).all
    predki = PersonsService.new(@persons, @relations).only_predki([@root_id])
    @predki = @persons.select { |p| predki.include? p.id }
  end

  def new
    @family_tree = FamilyTree.new
  end

  def edit
    redirect_to family_trees_path if @family_tree.nil? || @family_tree_user.role_id != Role[:owner].id
  end

  def create
    @family_tree = FamilyTree.new(family_tree_params)
    @family_tree.family_tree_users.new(user_id: current_user.id, role_id: Role[:owner].id)

    respond_to do |format|
      if @family_tree.save
        format.html { redirect_to family_trees_path, notice: 'Семейное дерево создано.' }
        format.json { render :show, status: :created, location: @family_tree }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @family_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if !@family_tree_user.owner?
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @family_tree.errors, status: :unprocessable_entity }
      elsif @family_tree.update(family_tree_params)
        format.html { redirect_to family_trees_path, notice: 'Семейное дерево обновлено.' }
        format.json { render :show, status: :ok, location: @family_tree }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @family_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @family_tree_user.owner?
        @family_tree.destroy
        format.html { redirect_to family_trees_url, notice: 'Семейное дерево удалено.' }
        format.json { head :no_content }
      else
        format.html { redirect_to family_trees_url, notice: 'Вы не владелец!' }
        format.json { render json: {error: 'you are not owner'}, status: :unprocessable_entity }
      end
    end
  end

  private

  def family_trees
    @family_tree_users ||= FamilyTreeUser.where(user_id: current_user.id).sort_by(&:role_id)
    @family_trees ||= FamilyTree.where(id: @family_tree_users.map(&:family_tree_id))
  end

  def find_family_tree
    @family_tree = family_trees.find { |ft| ft.id == params[:id].to_i }
    @family_tree_user = @family_tree_users.find { |ft| ft.family_tree_id == @family_tree&.id && ft.user_id == current_user.id }
  end

  def family_tree_params
    params.require(:family_tree).permit(:name, :user_id)
  end
end
