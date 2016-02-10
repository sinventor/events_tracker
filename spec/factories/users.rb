FactoryGirl.define do
  sequence :email do |n|
    "address#{n}@gmail.com"
  end

  factory :user do
    email
    password 'securepassword'
    password_confirmation 'securepassword'

    factory :invalid_user do
      password_confirmation 'notmatchingpass'
    end

  end
end
