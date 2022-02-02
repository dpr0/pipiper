# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable, :recoverable, :rememberable,
         :validatable, :omniauthable, omniauth_providers: [:telegram, :yandex]

  has_many :authorizations, dependent: :destroy
  has_many :family_tree_users
  has_many :family_trees, through: :family_tree_users, inverse_of: :users, dependent: :destroy
  belongs_to :person, required: false
  has_one_attached :avatar

  def self.find_for_oauth(auth)
    authorization = Authorization.where(provider: auth[:provider], uid: auth[:uid]).first
    return authorization.user if authorization

    user = User.where(email: auth[:email], provider: auth[:provider]).first
    if user
      user.uid ||= auth[:uid]
      user.name = auth[:name] if auth[:name].present?
      user.person ||= Person.create!(person_hash(user, auth[:phone]))
      user.save!
      if user.family_trees.count.zero?
        tree = user.family_trees.new(name: user.name, user_id: user.id)
        tree.save
        user.family_tree_users.create(role_id: 1, family_tree_id: tree.id, root_person_id: user.person.id)
        user.person.update(family_tree_id: tree.id)
      end
    else
      # user = User.new(auth.to_enum.to_h.merge(password: Devise.friendly_token[0, 20], email: "#{auth[:phone]}@#{auth[:provider]}"))
      # user.person = Person.create!(person_hash(user, auth[:phone]))
      # user.save!
      return
    end
    user.create_authorization(auth)
    user
  end

  def self.create_user(hash)
    hash[:birthdate] = hash[:birthdate]&.to_date
    phone = hash[:phone].gsub(/[^\d]/, '')
    hash[:phone] = phone.size == 10 ? "+7#{phone}" : nil
    hash[:email] = "+7#{phone}@phone" if phone
    hash[:provider] = 'phone'
    user = User.new(hash)
    user.name = user.full_name
    user.password = Devise.friendly_token[0, 20]
    user
  end

  def self.auth_by_token(headers)
    return unless headers['Authorization'].present?

    hash = JsonWebToken.decode(headers['Authorization'].split(' ').last)
    @current_user = User.find(hash[:user_id]) if hash && hash[:user_id]
  end

  def create_authorization(auth)
    authorizations.create(provider: auth[:provider], uid: auth[:uid])
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name}"
  end

  def self.person_hash(user, phone = nil)
    {
        sex_id: user.sex_id,
        last_name: user.last_name,
        first_name: user.first_name,
        middle_name: user.middle_name,
        birthdate: user.birthdate
    }.merge(phone ? { contact: phone } : {})
  end
end
