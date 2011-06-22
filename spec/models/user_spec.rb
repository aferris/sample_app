require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => "Example User", :email => "user@example.com",
             :password => "foobar", :password_confirmation => "foobar" }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name = User.new(@attr.merge(:name => ""))
    no_name.should_not be_valid
  end

  it "should require an email address" do
    no_name = User.new(@attr.merge(:email => ""))
    no_name.should_not be_valid
  end
  
  it "should have a name length no more than 50" do
    long_name = "A" * 51
    user = User.new(@attr.merge(:name => long_name))
    user.should_not be_valid
  end

  it "should have an email length no more than 100" do
    long_email = "A" * 101
    user = User.new(@attr.merge(:email => long_email))
    user.should_not be_valid
  end
  
  it "should accept valid email formats" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email formats" do
    addresses = %w[user@foo,com THE_USER @ foo.bar.org first.last@foo.]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should_not be_valid
    end
  end
  
  it "should have a unique email" do
    User.create!(@attr)
    duplicate = User.new(@attr)
    duplicate.should_not be_valid
  end
  
  it "should reject emails identical except for case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_dup_email = User.new(@attr)
    user_with_dup_email.should_not be_valid
  end
  
  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end
    
    it "should require a matching confirmation" do
      User.new(@attr.merge(:password_confirmation => "goodbye1")).
        should_not be_valid
    end
    
    it "should reject short passwords" do
      short_pass = "a" * 5
      User.new(@attr.merge(:password => short_pass, :password_confirmation => short_pass)).
        should_not be_valid
    end      

    it "should reject long passwords" do
      long_pass = "a" * 41
      User.new(@attr.merge(:password => long_pass, :password_confirmation => long_pass)).
        should_not be_valid
    end      
  end
  
  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end
      
    it "should have an encrypted password" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_correct_password? method" do
      it "should be true if the passwords match" do
        @user.has_correct_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords differ" do
        @user.has_correct_password?("invalid").should be_false
      end
    end
    
    describe "user authentication" do
      it "should have a valid email/encrypted password pair" do
        match = User.authenticate(@attr[:email], @attr[:password])
        match.should == @user
      end
      
      it "should return nil for a wrong password" do
        match = User.authenticate(@attr[:email], "wrong")
        match.should be_nil
      end
      
      it "should return nil for an invalid email" do
        match = User.authenticate("foo@bar.com", @attr[:password])
        match.should be_nil
      end
    end
  end
end
