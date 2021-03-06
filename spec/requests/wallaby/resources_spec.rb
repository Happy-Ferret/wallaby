require 'rails_helper'

describe 'general routes' do
  describe '#healthy' do
    it 'returns healthy' do
      get '/admin/status'
      expect(response).to be_successful
      expect(response.body).to eq 'healthy'
    end
  end
end

describe 'Resources pages using postgresql table' do
  let(:string) { 'Vincent van Gogh' }
  let(:model_class) { AllPostgresType }
  let(:json_headers) do
    { 'ACCEPT' => 'application/json' }
  end

  describe '#index' do
    let!(:record) { model_class.create!(string: string) }

    it 'renders collections' do
      get '/admin/all_postgres_types'
      expect(response).to be_successful
      expect(response).to render_template :index
      expect(response.body).to include string
    end

    it 'renders collections in json' do
      get '/admin/all_postgres_types', headers: json_headers
      expect(response).to be_successful
      expect(response).to render_template :index
      expect(response.content_type).to eq 'application/json'
      expect(response.body).to include string
    end

    it 'renders collections in csv' do
      get '/admin/all_postgres_types', headers: { 'ACCEPT' => 'text/csv' }
      expect(response).to be_successful
      expect(response).to render_template :index
      expect(response.content_type).to eq 'text/csv'
      expect(response.body).to include string
    end

    context 'sorting' do
      it 'renders collections' do
        get '/admin/all_postgres_types?sort=string%20desc'
        expect(response).to be_successful
        expect(response).to render_template :index
        expect(response.body).to include string
      end
    end

    context 'keyword' do
      it 'renders collections' do
        get '/admin/all_postgres_types?q=van'
        expect(response).to be_successful
        expect(response).to render_template :index
        expect(response.body).to include string

        get '/admin/all_postgres_types?q=string:~van'
        expect(response).to be_successful
        expect(response).to render_template :index
        expect(response.body).to include string
      end

      context 'when not found' do
        it 'renders collections' do
          get '/admin/all_postgres_types?q=unknown'
          expect(response).to be_successful
          expect(response).to render_template :index
          expect(response.body).not_to include string
        end
      end
    end

    context 'pagination' do
      it 'renders collections' do
        get '/admin/all_postgres_types?per=100'
        expect(response).to be_successful
        expect(response).to render_template :index
        expect(response.body).to include string

        get '/admin/all_postgres_types?page=1'
        expect(response).to be_successful
        expect(response).to render_template :index
        expect(response.body).to include string
      end

      context 'when not found' do
        it 'renders collections' do
          get '/admin/all_postgres_types?page=100'
          expect(response).to be_successful
          expect(response).to render_template :index
          expect(response.body).not_to include string
        end
      end
    end
  end

  describe '#show' do
    let!(:record) { model_class.create!(string: string) }

    it 'renders show' do
      get "/admin/all_postgres_types/#{record.id}"
      expect(response).to be_successful
      expect(response).to render_template :show
      expect(response.body).to include string
    end

    it 'renders show in json' do
      get "/admin/all_postgres_types/#{record.id}", headers: json_headers
      expect(response).to be_successful
      expect(response).to render_template :show
      expect(response.content_type).to eq 'application/json'
      expect(response.body).to include string
    end
  end

  describe '#new' do
    it 'renders show' do
      get '/admin/all_postgres_types/new'
      expect(response).to be_successful
      expect(response).to render_template :new
      expect(response.body).to include 'name="all_postgres_type[string]"'
    end
  end

  describe '#create' do
    it 'creates the record' do
      expect(model_class.count).to eq 0
      post '/admin/all_postgres_types', params: { all_postgres_type: { string: string } }
      created = model_class.first
      expect(response).to redirect_to "/admin/all_postgres_types/#{created.id}"
      expect(flash[:notice]).to eq 'All postgres type was successfully created.'
      expect(model_class.count).to eq 1
      expect(created.string).to eq string
    end

    it 'creates the record in json' do
      expect(model_class.count).to eq 0
      post '/admin/all_postgres_types', params: { all_postgres_type: { string: string } }, headers: json_headers
      created = model_class.first
      expect(response).to be_successful
      expect(response).to render_template :form
      expect(response.body).to include string
      expect(model_class.count).to eq 1
      expect(created.string).to eq string
    end

    context 'when form error exists' do
      let(:string) { 'Vincent van Gogh' }
      let(:model_class) { Picture }

      it 'renders form and show error' do
        post '/admin/pictures', params: { picture: { string: string } }
        expect(flash[:notice]).to be_nil
        expect(response).to render_template :new
        expect(response.body).to include "can't be blank"
      end

      it 'renders errors in json' do
        expect(model_class.count).to eq 0
        post '/admin/pictures', params: { picture: { string: string } }, headers: json_headers
        expect(response.content_type).to eq 'application/json'
        expect(response.body).to include "can't be blank"
        expect(response.status).to eq 400
      end
    end
  end

  describe '#edit' do
    let!(:record) { model_class.create!(string: string) }
    it 'renders edit' do
      get "/admin/all_postgres_types/#{record.id}/edit"
      expect(response).to be_successful
      expect(response).to render_template :edit
      expect(response.body).to include "value=\"#{string}\""
    end
  end

  describe '#update' do
    let!(:record) { model_class.create!(string: string) }
    it 'updates the record' do
      a_string = 'Claude Monet'
      put "/admin/all_postgres_types/#{record.id}", params: { all_postgres_type: { string: a_string } }
      expect(flash[:notice]).to eq 'All postgres type was successfully updated.'
      expect(response).to redirect_to "/admin/all_postgres_types/#{record.id}"
      expect(record.reload.string).to eq a_string
    end

    it 'updates the record in json' do
      a_string = 'Claude Monet'
      put "/admin/all_postgres_types/#{record.id}", params: { all_postgres_type: { string: a_string } }, headers: json_headers
      expect(record.reload.string).to eq a_string
      expect(response).to be_successful
      expect(response).to render_template :form
      expect(response.body).to include a_string
    end

    context 'when form error exists' do
      let(:string) { 'Vincent van Gogh' }
      let(:model_class) { Picture }
      let!(:record) { model_class.create!(name: string) }

      it 'renders form and show error' do
        put "/admin/pictures/#{record.id}", params: { picture: { name: '' } }
        expect(flash[:notice]).to be_nil
        expect(response).to render_template :edit
        expect(response.body).to include "can't be blank"
      end

      it 'renders form error in json' do
        put "/admin/pictures/#{record.id}", params: { picture: { name: '' } }, headers: json_headers
        expect(response.content_type).to eq 'application/json'
        expect(response.body).to include "can't be blank"
        expect(response.status).to eq 400
      end
    end
  end

  describe '#destroy' do
    let!(:record) { model_class.create!(string: string) }
    it 'destroys the record' do
      expect(model_class.count).to eq 1
      delete "/admin/all_postgres_types/#{record.id}"
      expect(flash[:notice]).to eq 'All postgres type was successfully destroyed.'
      expect(response).to redirect_to '/admin/all_postgres_types'
      expect(model_class.count).to eq 0
    end

    it 'destroys the record in json' do
      expect(model_class.count).to eq 1
      delete "/admin/all_postgres_types/#{record.id}", headers: json_headers
      expect(response).to be_successful
      expect(response).to render_template :form
      expect(response.content_type).to eq 'application/json'
      expect(response.body).to include string
    end
  end
end

describe 'Resources pages using postgresql table' do
  let(:name) { 'Vincent van Gogh' }
  let(:model_class) { Product }
  let(:json_headers) do
    { 'ACCEPT' => 'application/json' }
  end

  before do
    stub_const 'ProductDecorator', (Class.new Wallaby::ResourceDecorator do
      def self.model_class
        Product
      end
      self.index_field_names = %i(id name tags)
    end)
    Tag.create! name: 'Mens'
    Tag.create! name: 'Women'
  end

  describe '#index' do
    let!(:record) { model_class.create!(name: name, tags: Tag.all) }

    it 'renders collections' do
      get '/admin/products'
      expect(response).to be_successful
      expect(response).to render_template :index
      expect(response.body).to include name
      expect(response.body).to include Tag.first.name
      expect(response.body).to include Tag.last.name
    end

    it 'renders collections in json' do
      get '/admin/products', headers: json_headers
      expect(response).to be_successful
      expect(response).to render_template :index
      expect(response.content_type).to eq 'application/json'
      expect(response.body).to include name
    end

    it 'renders collections in csv' do
      get '/admin/products', headers: { 'ACCEPT' => 'text/csv' }
      expect(response).to be_successful
      expect(response).to render_template :index
      expect(response.content_type).to eq 'text/csv'
      expect(response.body).to include name
      expect(response.body).to include Tag.first.name
      expect(response.body).to include Tag.last.name
    end
  end
end
