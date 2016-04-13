module Spree
  module ApplyCouponCode
    extend ActiveSupport::Concern

    def apply_coupon_code
      if params[:order] && params[:order][:coupon_code]
        @order.coupon_code = params[:order][:coupon_code]

        handler = PromotionHandler::Coupon.new(@order).apply

        if handler.error.present?
          flash.now[:error] = handler.error
          respond_with(@order) { |format| format.html { render :edit } } and return
        elsif handler.success
          flash[:success] = handler.success
        end
      end
    end
  end
end
