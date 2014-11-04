module Apartment
  module Adapters
    class AbstractAdapter

      # Replaces Apartment's default method for returning a multitenanted configuration.
      #
      def multi_tenantify(tenant)
        @config.clone.tap do |config|
          config[:database] = environmentify(tenant)
          
          # database: <%= ENV['RDS_DB_NAME'] %>
          # username: <%= ENV['RDS_USERNAME'] %>
          # password: <%= ENV['RDS_PASSWORD'] %>
          # host: <%= ENV['RDS_HOSTNAME'] %>
          # port: <%= ENV['RDS_PORT'] %>

          config[:host] = "test.local"
          
        end
      end

    end
  end
end