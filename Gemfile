source :gemcutter
gem "rails", "2.3.5"
gem "i18n", '0.4.2'
gem 'formtastic', '~> 1.1.0'
gem "mongrel"
gem "capistrano"
gem "mongrel_cluster"
gem "will_paginate", '~> 2.3.11'
gem 'nokogiri'
gem 'json'
gem 'exceptional'
gem 'rdoc'
gem 'RedCloth'

# bundler requires these gems in all environments
# gem "nokogiri", "1.4.2"
# gem "geokit"

group :production do
  gem "mysql"
end

group :development do
  # bundler requires these gems in development
  gem "sqlite3-ruby", :require => "sqlite3"
end

group :test do
  # bundler requires these gems while running tests
  # gem "rspec"
  # gem "faker"
end
