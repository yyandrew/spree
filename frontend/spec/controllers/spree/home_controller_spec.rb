require 'spec_helper'

describe Spree::HomeController, :type => :controller do
  it "provides current user to the searcher class" do
    user = mock_model(Spree.user_class, :last_incomplete_spree_order => nil, :spree_api_key => 'fake')
    allow(controller).to receive_messages :try_spree_current_user => user
    expect_any_instance_of(Spree::Config.searcher_class).to receive(:current_user=).with(user)
    spree_get :index
    expect(response.status).to eq(200)
  end

  context "layout" do
    it "renders default layout" do
      spree_get :index
      expect(response).to render_template(layout: 'spree/layouts/spree_application')
    end

    context "different layout specified in config" do
      before { Spree::Config.layout = 'layouts/application' }

      it "renders specified layout" do
        spree_get :index
        expect(response).to render_template(layout: 'layouts/application')
      end
    end
  end

  context 'http caching' do
    let!(:product) { create(:product) }
    let!(:taxonomy) { create(:taxonomy) }

    context 'on the first request' do
      it 'returns a 200' do
        spree_get :index
        expect(response.status).to eq(200)
      end
    end

    context 'on a subsequent request' do
      before do
        spree_get :index
        expect(response.status).to eq(200)
        expect(response.headers['ETag']).to be_present
        expect(response.headers['Last-Modified']).to be_present
        @etag = response.headers['ETag']
        @last_modified = response.headers['Last-Modified']
      end

      context "if it is not stale" do
        before do
          request.env['HTTP_IF_NONE_MATCH'] = @etag
          request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
        end

        it 'returns a 304' do
          spree_get :index
          expect(response.status).to eq(304)
        end
      end

      context 'if product has been updated' do
        before do
          sleep 1 # To ensure the product.updated_at has a delta of at least 1 sec
          product.touch
          request.env['HTTP_IF_NONE_MATCH'] = @etag
          request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
        end

        it 'returns a 200' do
          spree_get :index
          expect(response.status).to eq(200)
        end

        it 'returns product updated_at as last modified' do
          spree_get :index
          expect(Time.parse(response.headers['Last-Modified']).utc.to_i).to eq(product.updated_at.utc.to_i)
        end
      end

      context 'if taxonomy has been updated' do
        before do
          sleep 1 # To ensure the product.updated_at has a delta of at least 1 sec
          taxonomy.touch
          request.env['HTTP_IF_NONE_MATCH'] = @etag
          request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
        end

        it 'returns a 200' do
          spree_get :index
          expect(response.status).to eq(200)
        end

        it 'returns product updated_at as last modified' do
          spree_get :index
          expect(Time.parse(response.headers['Last-Modified']).utc.to_i).to eq(taxonomy.updated_at.utc.to_i)
        end
      end
    end
  end
end
