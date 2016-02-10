module Responders
  module JsonResponder
    protected

    def api_behaviour(error)
      if post?
        display resource, status: :created
      elsif put?
        display resource, status: :ok
      else
        super
      end
    end
  end
end
