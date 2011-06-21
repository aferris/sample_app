require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => "Example User", :email => "user@example.com"}
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
end
