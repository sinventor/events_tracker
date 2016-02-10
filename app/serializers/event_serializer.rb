class EventSerializer < ActiveModel::Serializer
  attributes :id, :start, :end, :title, :repeat_interval, :base_id
  belongs_to :user

  def start
    object.start
  end

  def end
    object.end_date
  end
end
