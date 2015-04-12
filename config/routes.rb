# require 'sidekiq/web'
require 'sidekiq/api'

Dreamsis::Application.routes.draw do

  # Top-level or Customer-level Objects
  # ---------------------------------------
  resources :customers
  resources :object_filters do
    member do
      post :formatted_criteria
    end
  end
  resources :terms do
    collection do
      match :check_export_status
    end
    member do
      put :update
      put :sync
      match :show
    end
  end
  resources :quarters, :controller => 'terms'
  resources :notes do  
    member do
      get :document
    end
  end
  resources :trainings do  
    member do
      get :take
      post :complete
    end  
  end
  resources :programs
  resources :test_types
  resources :scholarships do
    collection do
      match :auto_complete_for_scholarship_title
      post :merge
    end
    member do
      get :applications
    end  
  end
  match 'changes/for/:model_name/:id' => 'changes#for_object', :as => :changes_for_object
  match 'changes/trash' => 'changes#deleted', :as => :deleted_records
  match 'changes/undelete/:id' => 'changes#undelete', :as => :undelete_change, :via => :delete

  
  # Locations
  # ---------------------------------------
  resources :high_schools do
    collection do
      get :stats
      get :in_district
    end
    member do
      get :survey_codes
      get :survey_code_cards
      get :stats
    end
    resources :visits do
      collection do
        get 'attendance'
      end
    end
  end
  resources :locations do
    collection do
      match :auto_complete_for_location_name
    end
  end
  resources :colleges, :controller => "locations" do
    collection do
      match :auto_complete_for_institution_name
    end
    member do
      get :applications
    end  
  end
  
  
  # Events
  # ---------------------------------------
  resources :events do
    resources :event_attendances do
      collection do
        get :checkin
        match :auto_complete_for_person_fullname
        put :checkin_new_participant
        put :checkin_new_volunteer
      end
    end
    resources :event_shifts
  end
  resources :event_types
  resources :event_groups
  match 'rsvp/rsvp/:id' => 'rsvp#rsvp', :as => :rsvp, :via => [:get, :put, :delete, :post]
  match 'rsvp/event/:id' => 'rsvp#event', :as => :event_rsvp, :via => :get
  match 'rsvp/event_group/:id/locations' => 'rsvp#event_group_locations', :as => :event_group_locations, :via => :get
  match 'rsvp/event_group/:id' => 'rsvp#event_group', :as => :event_group_rsvp, :via => :get
  match 'rsvp/event_type/:id' => 'rsvp#event_type', :as => :event_type_rsvp, :via => :get
  match 'rsvp/upcoming' => 'rsvp#mentor_available', :as => :mentor_available_rsvp, :via => :get


  # Participants
  # ---------------------------------------
  resources :participants do
    collection do
      match :auto_complete_for_participant_fullname
      match :check_duplicate
      match :fetch_participant_group_options
      match :check_export_status
      # match :cohort
      # match '/participants/cohort/:id.:format' => 'participants#cohort', :as => :cohort
      
      post :add_to_group
      post :college_mapper_callback
      post :bulk
    end
    member do
      match :fetch_participant_group_options
      post :college_mapper_login
      post :refresh_filter_cache
      get :event_attendances
    end
    resources :college_applications do
      collection do
        match :auto_complete_for_institution_name
      end
    end
    resources :college_enrollments
    resources :college_degrees
    resources :scholarship_applications
    resources :parents
    resources :test_scores do
      collection do
        post :update_scores_fields
      end
      member do
        post :update_scores_fields
      end    
    end
  end
  resources :students, :only => [:show]
  resources :participant_groups do
    collection do
      get :high_school_cohort
      get :high_school
    end
  end
  resources :clearinghouse_requests do
    member do
      post :submit
      post :retrieve
      get :file
      post :upload
    end
  end
  match '/my/mentees' => 'participants#mentor', :as => :my_participants, :mentor_id => 'me'
  match '/participants/:id/avatar/:size' => 'participants#avatar', :as => :participant_avatar
  match 'participants/all' => 'participants#index', :as => :all_participants
  match '/participants/mentor/:mentor_id' => 'participants#mentor', :as => :mentor_participants
  match '/participants/college/:college_id/cohort/:year' => 'participants#college_cohort', :as => :college_participants_cohort
  match '/participants/college/:college_id' => 'participants#college', :as => :college_participants
  match '/participants/program/:program_id' => 'participants#program', :as => :program_participants
  match '/participants/high_school/:high_school_id/cohort/:year' => 'participants#high_school_cohort', :as => :high_school_cohort
  match '/participants/high_school/:high_school_id' => 'participants#high_school', :as => :high_school_participants
  match '/participants/cohort/:id' => 'participants#cohort', :as => :cohort
  match '/participants/groups/:id' => 'participants#group', :as => :participant_group_participants


  # Mentors
  # ---------------------------------------
  resources :mentors do
    collection do
      get :auto_complete_for_mentor_fullname
      match :onboarding
      get :onboarding_textblocks
      match :event_status
      match :leads
      match :van_drivers
      get :check_if_valid_van_driver
    end
    member do
      match :photo
      delete :remove_participant
      get :background_check_form_responses
      put :send_login_link
      get :login_link
      get :onboarding_form
      match :onboarding_update, :action => "sidebar_form_update", :row_partial => "mentor_onboarding"
      get :driver_edit_form
      match :driver_update, :action => "sidebar_form_update", :row_partial => "mentor_driver"
      post :driver_training_status
    end
  end
  resources :mentor_term_groups do
    resources :mentor_terms
    collection do
      put :create_from_linked_sections
      put :sync
    end
    member do
      put :sync
      get :photo_tile
    end
  end
  match 'mentor_term_groups/:group_id/van_drivers' => 'mentors#van_drivers', :as => :van_drivers_mentor_term_group
  match 'mentor_term_groups/term/:term_id' => 'mentor_term_groups#term', :as => :mentor_term_groups_term
  resources :volunteers, :only => [:show, :background_check_responses], :controller => 'mentors'
  resources :activity_logs
  match '/activity_logs/summary/week/:year/:month/:day' => 'activity_logs#weekly_summary', :as => :activity_log_weekly_summary
  match '/activity_logs/summary/week' => 'activity_logs#weekly_summary', :as => :activity_log_current_week_summary
  match '/my/week/:year/:month/:day' => 'activity_logs#my_week', :as => :my_activity_log
  match '/my/week' => 'activity_logs#my_current_week', :as => :my_current_activity_log
  match 'mentor_signup/add_my_courses' => 'mentor_signup#add_my_courses', :as => :mentor_signup_schedule_add_my_courses
  match 'mentor_signup/basics' => 'mentor_signup#basics', :as => :mentor_signup_basics
  match 'mentor_signup/risk_form' => 'mentor_signup#risk_form', :as => :mentor_signup_risk_form
  match 'mentor_signup/conduct_form' => 'mentor_signup#conduct_form', :as => :mentor_signup_conduct_form
  match 'mentor_signup/driver_form' => 'mentor_signup#driver_form', :as => :mentor_signup_conduct_form
  match 'mentor_signup/background_check_form' => 'mentor_signup#background_check_form', :as => :mentor_signup_background_check_form
  match 'mentor_signup/:term_id/drop/:id' => 'mentor_signup#drop', :as => :mentor_signup_term_drop, :via => :delete
  match 'mentor_signup/:term_id/volunteer/:id' => 'mentor_signup#volunteer', :as => :mentor_signup_term_volunteer, :via => :put
  match 'mentor_signup/:term_id' => 'mentor_signup#index', :as => :mentor_signup_term
  match 'mentor_signup/' => 'mentor_signup#index', :as => :mentor_signup
  match 'my/dashboard' => 'welcome#mentor', :as => :my_dashboard
  

  # Users
  # ---------------------------------------
  resources :users do
    collection do
      match :auto_complete_for_user_login
      get :admin
    end
  end
  match 'map_login/:person_id/:token' => 'session#map_login', :as => :map_login
  match 'map_to_person/:person_id/:token' => 'session#map_to_person', :as => :map_to_person
  match 'locator' => 'session#locator', :as => :locator
  match 'login' => 'session#new', :as => :login
  match 'logout' => 'session#destroy', :as => :logout
  match 'profile' => 'users#profile', :as => :profile
  match 'profile/choose_identity' => 'users#choose_identity', :as => :choose_identity
  match 'profile/update' => 'users#update_profile', :as => :update_profile, :via => :post
  match 'profile/update_identity' => 'users#update_identity', :as => :update_identity, :via => :post
  match '/auth/anonymous/' => 'session#create_anonymous', :as => :anonymous_login_callback
  match '/auth/:provider/callback' => 'session#create', :as => :omniauth_callback
  match '/auth/failure' => 'session#failure'
  resource :session  

  # Other
  # ---------------------------------------
  # mount Sidekiq::Web, at: "/sidekiq"
  match 'sidekiq/status' => 'application#sidekiq_status'
  match '/' => 'welcome#index'
  match 'ping' => 'application#ping'
  root :to => 'welcome#index'
  
end
