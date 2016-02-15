class Event < ActiveRecord::Base
  
  validates_presence_of :title, :start

  belongs_to :user

  # virtual attributes
  attr_accessor :is_requested_apply_for_all_one_based
  attr_accessor :is_requested_delete_one_based
  attr_accessor :end_date_of_series
  attr_accessor :needed_recompute_end_date

  # callbacks
  before_save :update_one_based_records, on: :update, if: :is_requested_apply_for_all_one_based
  after_destroy :delete_one_based_records, if: :is_requested_apply_for_all_one_based
  after_commit :generate_serial_records, on: :create, if: :end_date_of_series
  before_validation :recompute_end_date_by_start_delta, if: :needed_recompute_end_date

  after_validation :ensure_end_date_greater_than_start

  # repeat_interval
  enum repeat_interval: {
    daily: 'd',
    weekly: 'w',
    monthly: 'm',
    yearly: 'y'
  }

  # scopes
  scope :with_same_base, -> (base) { where("base_id = :item_id OR base_id IS NOT NULL AND base_id = :base_id OR id = :base_id", item_id: base.id, base_id: base.base_id) }
  scope :with_same_base_except_self, -> (base) { with_same_base(base).where.not(id: base.id) }

  def generate_serial_records
    return if !repeat_interval || base_id.present? || !end_date_of_series
    case
    when daily?
      generate_records_until(self, end_date_of_series, :day)
    when weekly?
      generate_records_until(self, end_date_of_series, :week)
    when monthly?
      generate_records_until(self, end_date_of_series, :month)
    else
      generate_records_until(self, end_date_of_series, :year)
    end
  end

  private

  def recompute_end_date_by_start_delta
    if self.start_changed?
      self.end_date = self.end_date + (self.start - self.start_was)
    end
  end

  def ensure_end_date_greater_than_start
    if !end_date.present? || end_date < start
      self.end_date = start.end_of_day
    end
  end

  def generate_records_until(base, end_date_of_series, incr_period)
    current_start_date = base.start + get_next_period(incr_period)
    current_end_date = base.end_date + get_next_period(incr_period)

    while current_end_date < end_date_of_series
      Event.create(attributes.with_indifferent_access.except(:id).merge(start: current_start_date, base_id: id, end_date: current_end_date))
      current_start_date = current_start_date + get_next_period(incr_period)
      current_end_date = current_end_date + get_next_period(incr_period)
    end
  end

  def delete_one_based_records
    Event.with_same_base(self).destroy_all
  end

  def update_one_based_records
    one_based_events = Event.with_same_base_except_self(self)

    one_based_events.each do |evt|
      evt.start = recompute_start(evt, self.start_was, self.start) if self.start_changed?

      if self.end_date_changed?
        evt.end_date = recompute_end(evt, self.end_date_was, self.end_date)
      elsif evt.start_changed? && !self.end_date_changed?
        evt.end_date = evt.end_date + (self.start - self.start_was)
      end
      evt.update(self.attributes.with_indifferent_access.except(:id, :start, :end_date, :base_id))
    end
  end

  def recompute_start(target, source_start_was, curr_source_start)
    target.start + (curr_source_start - source_start_was)
  end

  def recompute_end(target, source_end_was, curr_source_end)
    target.end_date + (curr_source_end - source_end_was)
  end

  def get_next_period(period)
    case period
    when :day then 1.day
    when :week then 1.week
    when :month then 1.month
    else 1.year
    end
  end

  def get_one_based_records
    Event.with_same_base(self).where.not(id: self.id)
  end
end
