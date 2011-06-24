# == Schema Information
# Schema version: 20110621150304
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
    attr_accessible :name, :email, :password, :password_confirmation
    attr_accessor :password
    
    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    validates :name,  :presence => true,
                      :length => { :maximum => 50 }
    validates :email, :presence => true,
                      :length => { :maximum => 100 },
                      :format => { :with => email_regex },
                      :uniqueness => { :case_sensitive => false }
    validates :password, :presence => true,
              :confirmation => true,
              :length => { :within => 6..40 }
           
    before_save :encrypt_password
       
    # Compare stored encrypted password to submitted encrypted password.
    # Return true if they are the same    
    def has_correct_password?(submitted_password)
      encrypted_password == encrypt(submitted_password)
    end
    
    def self.authenticate(email, password)
      user = find_by_email(email)
      if user.nil? == false
        user if user.has_correct_password?(password)
      end
    end
    
    def self.authenticate_with_salt(id, cookie_salt)
      user = find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil
    end

    private
      def encrypt_password
        self.salt = make_salt if new_record?
        self.encrypted_password = encrypt(password)
      end
      
      def encrypt(string)
        secure_hash("#{salt}--#{string}")
      end
      
      def make_salt
        secure_hash("#{Time.now.utc}--#{password}")
      end
      
      def secure_hash(string)
        Digest::SHA2.hexdigest(string)
      end
end
