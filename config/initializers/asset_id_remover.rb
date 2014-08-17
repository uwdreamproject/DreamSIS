# Override ActionView::Helpers::AssetTagHelper.rewrite_asset_path so that we don't append cache-busting timestamps at the end of asset URLs in development.
module ActionView
  module Helpers
    module AssetTagHelper
      def rewrite_asset_path(source, path = nil)
        if path && path.respond_to?(:call)
          return path.call(source)
        elsif path && path.is_a?(String)
          return path % [source]
        end

        asset_id = rails_asset_id(source)
        return source if Rails.env == 'development'
        if asset_id.blank?
          source
        else
          source + "?#{asset_id}"
        end
      end
    end
  end
end