source 'https://rubygems.org'
ruby '2.2.4'

gem 'rails', '4.0.13'
gem "unicorn"
gem "unicorn-rails"
gem "puma"
gem 'formtastic'
gem 'will_paginate'
gem 'nokogiri'
gem 'json'
gem 'rdoc'
gem 'RedCloth'
gem 'country_select'
gem 'bcrypt-ruby'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-shibboleth'
gem 'omniauth-identity'
gem 'omniauth-windowslive'
gem 'omniauth-linkedin'
gem 'geocoder'
gem 'aes'
gem 'fastercsv'
gem 'mandrill-api'
gem 'ey_config'
gem "mime-types"
gem "carrierwave"
gem "fog"
gem "mini_magick"
gem "rubyzip"
gem 'axlsx'
gem "acts_as_xlsx"
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'apartment'
gem 'zip'
gem 'net-sftp'
gem 'rails_autolink'
gem 'rails3-jquery-autocomplete'
gem 'rollbar'
gem 'addressable'
gem 'sucker_punch'
gem 'sidekiq'
gem 'apartment-sidekiq'
gem "simple_calendar"
gem 'jquery-tablesorter'
gem 'le'
gem 'coderay', require: 'coderay'
gem 'acts_as_list'
gem 'fabrication'
gem 'faker'
gem 'acts-as-taggable-on'
gem 'select2-rails'
gem 'rails_12factor', group: :production
gem "rack-timeout"
gem 'aws-sdk'
gem 'rack-mini-profiler'
gem 'flamegraph'
gem 'stackprof'
gem 'memory_profiler'
gem 'activeresource', require: 'active_resource'
gem 'activerecord-session_store'

group :production do
  gem "pg", "0.18.4"
  gem "activerecord-postgresql-adapter"
end

group :staging do
end

group :development do
  gem "sqlite3"
  gem 'web-console'
end

group :development, :test do
  gem 'dotenv'
  gem 'dotenv-rails'
  gem 'brakeman', require: false
  gem 'bundler-audit'
  gem 'byebug'
  gem 'spring'
  gem 'awesome_print'
  gem 'pronto'
  gem 'pronto-rubocop', require: false
  gem 'pronto-brakeman', require: false
  gem 'pronto-flay', require: false
  gem 'pronto-rails_best_practices', require: false
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test do
  gem 'turn', require: false
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'minitest-ci', git: 'git@github.com:circleci/minitest-ci.git'
end
