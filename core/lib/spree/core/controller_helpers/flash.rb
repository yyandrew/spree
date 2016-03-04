# based on the https://github.com/leonid-shevtsov/unobtrusive_flash
# authors https://github.com/leonid-shevtsov/unobtrusive_flash/graphs/contributors

module Spree
  module Core
    module ControllerHelpers
      module Flash
        extend ActiveSupport::Concern

        included do
          after_action :prepare_unobtrusive_flash
        end

        protected

        def prepare_unobtrusive_flash
          if flash.any?
            cookie_flash = []
            if cookies['flash']
              cookie_flash = JSON.parse(cookies['flash']) rescue nil
              cookie_flash = [] unless cookie_flash.is_a? Array
            end

            cookie_flash += sanitize_flash(flash)
            cookies[:flash] = { value: cookie_flash.to_json, domain: unobtrusive_flash_domain }
          end
        end

        # Setting cookies for :all domains is broken for Heroku apps, read this article for details
        # https://devcenter.heroku.com/articles/cookies-and-herokuapp-com
        # You can also override this method in your controller if you need to customize the cookie domain
        def unobtrusive_flash_domain
          if request.host =~ /\.herokuapp\.com$/
            request.host
          else
            :all
          end
        end

        def sanitize_flash(flash)
          flash.to_a.map { |key, value|
            next if key == 'order_completed'
            html_safe_value = value.html_safe? ? value : ERB::Util.html_escape(value)
            flash.discard(key.to_sym)
            [key, html_safe_value]
          }.compact
        end
      end
    end
  end
end
