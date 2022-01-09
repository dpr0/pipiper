# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: :show
  invisible_captcha only: [:create_user], honeypot: :subtitle

  def new
    redirect_to user_path(current_user.id) if user_signed_in?
    @user = User.new

    @persons = FamilyTree.find(0).persons.order(:birthdate)
    @relations = Relation.where(person_id: @persons.ids).or(Relation.where(persona_id: @persons.ids)).all
    service = PersonsService.new(@persons, @relations)
    @hash = service.graph(Person.find(0))
  end

  def show
    @trees = FamilyTreeUser.where(user_id: current_user.id).group_by(&:role_id)
  end

  def create_user
    @user = User.create_user(create_user_params)

    if @user.phone && User.find_by(phone: @user.phone).present?
      redirect_to(new_user_path, notice: "Пользователь с номером #{@user.phone} уже зарегистрирован в системе") and return
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to welcome_users_path }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def welcome; end

  private

  def create_user_params
    params.require(:user).permit(:last_name, :first_name, :middle_name, :birthdate, :sex_id, :phone)
  end
end
