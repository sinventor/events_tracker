FactoryGirl.define do
  sequence :title do |n|
    "My cool event ##{n}"
  end

  specified_date = DateTime.new(2016, 2, 10, 14, 20)

  factory :event do
    user
    title
    start specified_date
    end_date specified_date + 3.hours

    factory :periodic_event1 do
      end_date_of_series Date.new(2016, 4, 2)
      repeat_interval 'w'
      title 'It\'s a periodic event #1'
      end_date specified_date + 3.hours
    end

    factory :periodic_event2 do
      end_date_of_series Date.new(2016, 4, 5)
      repeat_interval 'w'
      title 'It\'s a periodic event #1'
      end_date specified_date + 3.hours
    end
  end
end