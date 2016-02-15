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

    factory :user_with_full_name do
      full_name 'Jack Brew'
    end

    factory :user_without_full_name do
      full_name nil
    end
  end
end
