ActionController::Routing::Routes.draw do |map|
  map.resources :trainings, :member => { :take => :get, :complete => :post }
  map.resources :notes
  map.resources :programs
  map.resources :test_types
  map.resources :customers
  map.resources :object_filters
  map.resources :locations, :collection => { :auto_complete_for_location_name => :any }
  map.resources :colleges, :controller => "locations", :collection => { :auto_complete_for_institution_name => :any }, :member => { :applications => :get }
  map.resources :terms, :member => { :sync => :put }
  map.resources :quarters, :path => :quarters, :as => :terms
  map.resources :clearinghouse_requests, :member => { :submit => :post, :retrieve => :post, :file => :get, :upload => :post }
  
  map.resources :events do |events|
    events.resources :event_attendances, :as => :attendees, :collection => { 
      :checkin => :get, :auto_complete_for_person_fullname => :any, :checkin_new_participant => :put, :checkin_new_volunteer => :put
    }
    events.resources :event_shifts, :as => :shifts
  end
  map.resources :event_types
  map.resources :event_groups
  map.resources :high_schools, 
    :member => { :survey_codes => :get, :survey_code_cards => :get, :stats => :get }, 
    :collection => { :stats => :get, :in_district => :get } do |high_schools|
    high_schools.resources :visits, 
      :collection => { :attendance => :get, :update_attendance => :post }, 
      :path_prefix  => "/high_schools/:high_school_id/:term_id"
  end

  map.resources :participants, 
    :has_many => [:college_applications, :scholarship_applications, :parents, :college_enrollments, :college_degrees], 
    :collection => { :auto_complete_for_participant_fullname => :any, :check_duplicate => :any, :add_to_group => :post, :fetch_participant_group_options => :any, :college_mapper_callback => :post },
    :member => { :note => [ :post, :put ], :fetch_participant_group_options => :any, :college_mapper_login => :post } do |participant|
    participant.resources :college_applications, :collection => { :auto_complete_for_institution_name => :any }
    participant.resources :test_scores, :collection => { :update_scores_fields => :post }, :member => { :update_scores_fields => :post }
  end  
    
  map.resources :students, :controller => :participants, :only => [:show]

  map.resources :participant_groups,
    :collection => { :high_school_cohort => :get, :high_school => :get }

  map.resources :users, :collection => { :auto_complete_for_user_login => :any, :admin => :get }

  map.resources :mentors, 
    :member => { :photo => :any, :remove_participant => :delete, :background_check_form_responses => :get, :generate_login_token => :put, :login_link => :get }, 
    :collection => { :auto_complete_for_mentor_fullname => :any, :onboarding => :any, :event_status => :any, :leads => :any, :van_drivers => :any, :check_if_valid_van_driver => :get }
  map.resources :mentor_term_groups, 
    :member => { :sync => :put, :photo_tile => :get }, 
    :collection => { :create_from_linked_sections => :put, :sync => :put },
    :has_many => :mentor_terms
  map.mentor_term_groups_term 'mentor_term_groups/term/:term_id', 
    :controller => 'mentor_term_groups', 
    :action => 'term'
  map.resources :volunteers, :controller => :mentors, :only => [:show, :background_check_responses]

  map.mentor_signup_schedule_add_my_courses 'mentor_signup/add_my_courses', :controller => 'mentor_signup', :action => 'add_my_courses'
  map.mentor_signup_basics 'mentor_signup/basics', :controller => 'mentor_signup', :action => 'basics'
  map.mentor_signup_risk_form 'mentor_signup/risk_form', :controller => 'mentor_signup', :action => 'risk_form'
  map.mentor_signup_background_check_form 'mentor_signup/background_check_form', :controller => 'mentor_signup', :action => 'background_check_form'
  map.mentor_signup_term_drop 'mentor_signup/:term_id/drop/:id', :controller => 'mentor_signup', :action => 'drop', :conditions => {:method => :delete}
  map.mentor_signup_term_volunteer 'mentor_signup/:term_id/volunteer/:id', :controller => 'mentor_signup', :action => 'volunteer', :conditions => {:method => :put}
  map.mentor_signup_term 'mentor_signup/:term_id', :controller => 'mentor_signup', :action => 'index'
  map.mentor_signup 'mentor_signup/', :controller => 'mentor_signup', :action => 'index'

  map.rsvp 'rsvp/rsvp/:id', :controller => 'rsvp', :action => 'rsvp', :conditions => { :method => :put }
  map.event_rsvp 'rsvp/event/:id', :controller => 'rsvp', :action => 'event', :conditions => { :method => :get }
  map.event_group_locations 'rsvp/event_group/:id/locations', :controller => 'rsvp', :action => 'event_group_locations', :conditions => { :method => :get }
  map.event_group_rsvp 'rsvp/event_group/:id', :controller => 'rsvp', :action => 'event_group', :conditions => { :method => :get }
  map.event_type_rsvp 'rsvp/event_type/:id', :controller => 'rsvp', :action => 'event_type', :conditions => { :method => :get }

  map.high_school_cohort '/participants/high_school/:high_school_id/cohort/:year.:format', 
    :controller => 'participants', 
    :action => 'high_school_cohort'
  map.cohort '/participants/cohort/:id.:format', :controller => 'participants', :action => 'cohort'
  map.participant_group_participants '/participants/groups/:id.:format', :controller => 'participants', :action => 'group'

  # Users and Sessions
  map.map_login 'map_login/:person_id/:token', :controller => 'session', :action => 'map_login'
  map.map_to_person 'map_to_person/:person_id/:token', :controller => 'session', :action => 'map_to_person'
  map.signup 'signup', :controller => 'session', :action => 'signup'
  map.login 'login', :controller => 'session', :action => 'new'
  map.logout 'logout', :controller => 'session', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'profile'
  map.choose_identity 'profile/choose_identity', :controller => 'users', :action => 'choose_identity'
  map.update_profile 'profile/update', :controller => 'users', :action => 'update_profile', :conditions => { :method => :post }
  map.update_identity 'profile/update_identity', :controller => 'users', :action => 'update_identity', :conditions => { :method => :post }
  # map.reset_password 'session/reset/:user_id/:token', :controller => 'session', :action => 'reset_password'
  # map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get }
  map.resource :session
  map.anonymous_login_callback "/auth/anonymous/", :controller => 'session', :action => 'create_anonymous'
  map.omniauth_callback "/auth/:provider/callback", :controller => 'session', :action => 'create'  

  map.connect "welcome/mentor", :controller => "welcome", :action => "mentor"
  map.root :controller => "welcome"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
