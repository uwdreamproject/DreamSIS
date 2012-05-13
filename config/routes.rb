ActionController::Routing::Routes.draw do |map|
  map.resources :notes
  map.resources :object_filters
  map.resources :locations
  map.resources :quarters, :member => { :sync => :put }
  map.resources :events do |events|
    events.resources :event_attendances, :as => :attendees, :collection => { :checkin => :get, :auto_complete_for_person_fullname => :any, :checkin_new_participant => :put }
  end
  map.resources :event_types
  map.resources :event_groups
  map.resources :high_schools, :member => { :survey_codes => :get, :survey_code_cards => :get, :stats => :get }, :collection => { :stats => :get } do |high_schools|
    high_schools.resources :visits, 
      :collection => { :attendance => :get, :update_attendance => :post }, 
      :path_prefix  => "/high_schools/:high_school_id/:quarter_id"
  end

  map.resources :participants, 
    :has_many => [:college_applications, :scholarship_applications], 
    :collection => { :check_duplicate => :any, :add_to_group => :post, :fetch_participant_group_options => :any },
    :member => { :note => [ :post, :put ], :fetch_participant_group_options => :any }

  map.resources :participant_groups,
    :collection => { :high_school_cohort => :get, :high_school => :get }

  map.resources :users, :collection => { :auto_complete_for_user_login => :any }

  map.resources :mentors, 
    :member => { :photo => :any, :remove_participant => :delete, :background_check_form_responses => :get }, 
    :collection => { :auto_complete_for_mentor_fullname => :any, :onboarding => :any, :leads => :any, :van_drivers => :any, :check_if_valid_van_driver => :get }
  map.resources :mentor_quarter_groups, 
    :member => { :sync => :put, :photo_tile => :get }, 
    :collection => { :create_from_linked_sections => :put, :sync => :put },
    :has_many => :mentor_quarters
  map.mentor_quarter_groups_quarter 'mentor_quarter_groups/quarter/:quarter_id', 
    :controller => 'mentor_quarter_groups', 
    :action => 'quarter'

  map.mentor_signup_basics 'mentor_signup/basics', :controller => 'mentor_signup', :action => 'basics'
  map.mentor_signup_risk_form 'mentor_signup/risk_form', :controller => 'mentor_signup', :action => 'risk_form'
  map.mentor_signup_background_check_form 'mentor_signup/background_check_form', :controller => 'mentor_signup', :action => 'background_check_form'
  map.mentor_signup_quarter_drop 'mentor_signup/:quarter_id/drop/:id', :controller => 'mentor_signup', :action => 'drop', :conditions => {:method => :delete}
  map.mentor_signup_quarter_volunteer 'mentor_signup/:quarter_id/volunteer/:id', :controller => 'mentor_signup', :action => 'volunteer', :conditions => {:method => :put}
  map.mentor_signup_quarter 'mentor_signup/:quarter_id', :controller => 'mentor_signup', :action => 'index'
  map.mentor_signup 'mentor_signup/', :controller => 'mentor_signup', :action => 'index'

  map.rsvp 'rsvp/rsvp/:id', :controller => 'rsvp', :action => 'rsvp', :method => 'put'
  map.event_rsvp 'rsvp/event/:id', :controller => 'rsvp', :action => 'event', :method => :get
  map.event_group_rsvp 'rsvp/event_group/:id', :controller => 'rsvp', :action => 'event_group', :method => :get
  map.event_type_rsvp 'rsvp/event_type/:id', :controller => 'rsvp', :action => 'event_type', :method => :get

  map.high_school_cohort '/participants/high_school/:high_school_id/cohort/:year.:format', 
    :controller => 'participants', 
    :action => 'high_school_cohort'
  map.cohort '/participants/cohort/:id.:format', :controller => 'participants', :action => 'cohort'
  map.participant_group_participants '/participants/groups/:id.:format', :controller => 'participants', :action => 'group'

  # Users and Sessions
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'session', :action => 'new'
  map.logout 'logout', :controller => 'session', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'profile'
  map.reset_password 'session/reset/:user_id/:token', :controller => 'session', :action => 'reset_password'
  map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get }
  map.resource :session

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "welcome"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
