module Spree
  class ProductsController < Spree::StoreController
    include Spree::ProductsHelper

    before_action :load_product, only: :show
    before_action :load_taxon, only: :index

    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    helper 'spree/taxons'

    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products.includes(:possible_promotions)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    def show
      if stale?(etag: cache_key_for_product, last_modified: @product.updated_at.utc, public: true)
        @variants = @product.variants_including_master.
                             spree_base_scopes.
                             active(current_currency).
                             includes([:option_values, :images])
        @product_properties = @product.product_properties.includes(:property)
        @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]
      end
      redirect_if_legacy_path
    end

    private

      def accurate_title
        if @product
          @product.meta_title.blank? ? @product.name : @product.meta_title
        else
          super
        end
      end

      def load_product
        if try_spree_current_user.try(:has_spree_role?, "admin")
          @products = Product.with_deleted
        else
          @products = Product.active(current_currency)
        end
        @product = @products.includes(:variants_including_master).friendly.find(params[:id])
      end

      def load_taxon
        @taxon = Spree::Taxon.find(params[:taxon]) if params[:taxon].present?
      end

      def redirect_if_legacy_path
        # If an old id or a numeric id was used to find the record,
        # we should do a 301 redirect that uses the current friendly id.
        if params[:id] != @product.friendly_id
          params.merge!(id: @product.friendly_id)
          return redirect_to url_for(params), status: :moved_permanently
        end
      end
  end
end
