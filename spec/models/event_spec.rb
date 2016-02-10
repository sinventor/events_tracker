require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) { create(:event) }
  let!(:repeated_event1) { create(:periodic_event1) }
  let(:source_title) { repeated_event1.title }
  # it " rf " do
  #   expect(event.title).to eq("My cool event ##{1}")
  # end

  # describe 'dv v ' do
  #   it " df " do
  #     expect(event.end_date).to be >= DateTime.current + 2.hours
  #   end
  #   it 'fd' do
  #     expect(event.id).not_to eq(1)
  #   end
  # end

  describe 'new records generation' do
    it 'should generate new records until end date of series' do
      subject { Event.where(title: source_title) }
      puts subject
      # puts repeated_event1.repeat_interval
      # subject { Event.where(title: "It's a periodic event") }
      expect(Event.where(title: source_title).count).to eq 8
      # expect( Event.where(title: "It's a periodic event").count).to be >= 8
    end

    it 'should set base_id for repeated event' do
      expect(Event.where(base_id: repeated_event1.id).count).to eq(7)
    end
  end

  describe 'deleting one based records' do
    let(:sample_event) { Event.where(base_id: repeated_event1.id).sample }

    it 'should delete all one based when requested' do
      sample_event.is_requested_apply_for_all_one_based = true
      sample_event.destroy
      expect(Event.where(title: source_title).count).to eq(1)
    end
  end

end