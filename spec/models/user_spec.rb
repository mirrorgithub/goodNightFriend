require 'rails_helper'

# rails db:rollback RAILS_ENV=test && rails db:rollback && rails db:rollback RAILS_ENV=test && rails db:rollback && rails db:rollback RAILS_ENV=test && rails db:rollback
# rails db:migrate RAILS_ENV=test && rails db:migrate && bundle exec rspec spec/models/user_spec.rb

# rails generate rspec:install

# rails generate rspec:model user
# bundle exec rspec spec/models/user_spec.rb

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  # test whether we can create user or not, and the charset
  it "create table test" do
    expect(User.create(name: "Ray")).to be_valid
    uu = User.create(name: "中文")
    expect(uu.name).to eql "中文"


    expect { User.create(name: "中文") }.to raise_error(ActiveRecord::RecordNotUnique)    
  end
end
