FactoryGirl.define do
  sequence :email do |n|
    "address#{n}@gmail.com"
  end

  factory :user do
    email
    password 'securepassword'
    password_confirmation 'securepassword'
  end
end
