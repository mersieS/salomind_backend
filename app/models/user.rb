class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::JTIMatcher

  has_many :stress_records, dependent: :destroy

  before_create :ensure_jti

  private

  def ensure_jti
    self.jti = SecureRandom.uuid if jti.blank?
  end
end
