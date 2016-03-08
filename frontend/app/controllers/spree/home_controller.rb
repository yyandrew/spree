module Spree
  class HomeController < Spree::StoreController
    include Spree::ProductsHelper
    helper 'spree/products'
    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products.includes(:possible_promotions)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      fresh_when etag: home_etag, last_modified: home_last_modified, public: true
    end

    protected

    def home_etag
      'home/' + cache_key_for_products + '/' + @taxonomies.maximum(:updated_at).to_s
    end

    def home_last_modified
      [@taxonomies.maximum(:updated_at), @products.maximum(:updated_at)].compact.max.try(:utc) || Time.now.utc
    end
  end
end
