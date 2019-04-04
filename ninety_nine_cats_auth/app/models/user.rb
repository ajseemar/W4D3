# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  user_name       :string
#  password_digest :string           not null
#  session_token   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
    validates :user_name, :session_token, uniqueness: true
    validates :user_name, :password_digest, presence: true 
    after_initialize :session_token

    attr_reader :password

    has_many :cats,
        foreign_key: :user_id,
        class_name: :Cat
    
    has_many :rental_requests,
        foreign_key: :user_id,
        class_name: :CatRentalRequest

    def self.session_token
        self.session_token ||= SecureRandom::urlsafe_base64
    end 

    def self.find_by_credentials(user_name, password)
        user = User.find_by(user_name: user_name)
        if user && user.is_password?(password)
            return user
        end
        nil
    end

    def reset_session_token!
        self.session_token ||= SecureRandom::urlsafe_base64
        self.save!
        self.session_token
    end

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

end
