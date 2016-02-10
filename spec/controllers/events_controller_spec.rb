require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  login_user
  let!(:event1) { create(:event, user: subject.current_user) }
  let!(:event2) { create(:event, user: subject.current_user) }

  it 'should have a current user' do
    expect(subject.current_user.email).to eq('address1@gmail.com')
  end

  describe 'POST #create' do
    context 'once (not periodic) events' do
      let(:event1) { build(:event) }
      let(:event1_title) { event1.title }
      it 'creates a new event' do
        post :create, event: event1.attributes, format: :json
        expect(response).to have_http_status(201)
        expect(Event.where(title: event1_title).count).to eq(1)
      end
    end

    context 'periodic events' do
      let(:periodic_event1) { build(:periodic_event1) }
      let(:event_title) { periodic_event1.title }
      it 'created a periodic events' do
        puts attributes_for(:periodic_event1)
        post :create, event: attributes_for(:periodic_event1), series_end: periodic_event1.end_date_of_series, format: :json

        expect(response).to have_http_status(201)
        expect(subject.current_user.events.where(title: event_title).count).to eq(8) 
      end
    end
  end

  describe 'GET #index' do
    it 'should have 200 http status' do
      get :index, format: :json
      expect(response).to have_http_status(200)
    end
  end

  context 'once events' do
    describe 'DELETE #destroy' do
      it 'deletes event' do
        expect {
          delete :destroy, id: event1.id, format: :json
        }.to change(Event, :count).by(-1)
      end
    end

    describe 'PUT #update' do
      let(:event1_title) { event1.title }
      let(:changed_title) { 'Go to the theatre!' }
      it 'updates event' do
        put :update, id: event1.id, event: { title: changed_title }, format: :json
        expect(response).to have_http_status(:ok)
        expect(Event.where(title: changed_title).count).to eq(1)
      end
    end
  end

  context 'periodic events' do
    let!(:periodic_event1) { create(:periodic_event1) }
    let(:event_title) { periodic_event1.title }

    describe 'DELETE #destroy' do
      it 'deletes event' do
        expect {
          delete :destroy, id: periodic_event1.id, delete_same: 'true', format: :json
        }.to change(Event, :count).by(-8)
      end
    end

    describe 'PUT #update' do
      let(:changed_title_for_all_one_based) { 'changed title' }
      let(:changed_title_only_instance) { 'changed title only this instance' }

      context 'when specified `update_same` param' do
        it 'should update title for all one based items' do
          put :update, id: periodic_event1.id, event: { title: changed_title_for_all_one_based }, update_same: 'true'
          expect(Event.where(title: changed_title_for_all_one_based).count).to eq(8)
        end
      end

      context 'when `update_same` not specified' do
        it 'should update title only this instance' do
          put :update, id: periodic_event1.id, event: { title: changed_title_only_instance }
          expect(Event.where(title: changed_title_only_instance).count).to eq(1)
          expect(Event.where(title: periodic_event1.title).count).to eq(7)
        end
      end
    end
  end


end

