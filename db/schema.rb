# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160611174922) do

  create_table "activity_logs", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "mentor_id"
    t.integer  "direct_interaction_count"
    t.integer  "indirect_interaction_count"
    t.text     "student_time"
    t.text     "non_student_time"
    t.text     "highlight_note"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "changes", force: :cascade do |t|
    t.integer  "change_loggable_id"
    t.string   "change_loggable_type", limit: 255
    t.text     "changes"
    t.integer  "user_id"
    t.string   "action_type",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "restored_at"
    t.integer  "restored_user_id"
  end

  add_index "changes", ["change_loggable_id", "change_loggable_type"], name: "index_changes_on_changable"

  create_table "clearinghouse_requests", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "created_by"
    t.string   "submitted_filename",          limit: 255
    t.datetime "submitted_at"
    t.datetime "retrieved_at"
    t.text     "participant_ids"
    t.text     "ftp_password"
    t.integer  "number_of_records_submitted"
    t.integer  "number_of_records_returned"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "detail_report_filename",      limit: 255
    t.text     "filenames"
    t.string   "inquiry_type",                limit: 255
    t.text     "selection_criteria"
    t.datetime "closed_at"
  end

  create_table "college_applications", force: :cascade do |t|
    t.integer  "participant_id"
    t.integer  "institution_id"
    t.datetime "date_applied"
    t.datetime "date_notified"
    t.string   "decision",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "choice",                       limit: 255
    t.boolean  "personal_statement_started"
    t.boolean  "personal_statement_completed"
    t.datetime "date_deposit_sent"
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name",                                        limit: 255
    t.integer  "program_id"
    t.integer  "parent_customer_id"
    t.boolean  "link_to_uw"
    t.string   "term_system",                                 limit: 255
    t.text     "risk_form_content"
    t.boolean  "require_background_checks"
    t.string   "mentor_label",                                limit: 255
    t.string   "lead_label",                                  limit: 255
    t.string   "participant_label",                           limit: 255
    t.string   "workbook_label",                              limit: 255
    t.string   "intake_survey_label",                         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mentee_label",                                limit: 255
    t.boolean  "experimental"
    t.integer  "clearinghouse_customer_number"
    t.date     "clearinghouse_contract_start_date"
    t.integer  "clearinghouse_number_of_submissions_allowed"
    t.string   "url_shortcut",                                limit: 255
    t.text     "allowable_login_methods"
    t.string   "visit_label",                                 limit: 255
    t.text     "college_application_choice_options"
    t.text     "paperwork_status_options"
    t.string   "not_target_label",                            limit: 255
    t.text     "activity_log_student_time_categories"
    t.text     "activity_log_non_student_time_categories"
    t.integer  "background_check_validity_length"
    t.text     "conduct_form_content"
    t.text     "driver_form_content"
    t.boolean  "send_driver_form_emails"
    t.boolean  "display_nicknames_by_default"
    t.integer  "driver_training_validity_length"
    t.string   "clearinghouse_customer_name",                 limit: 255
    t.string   "clearinghouse_entity_type",                   limit: 255
    t.string   "stylesheet_url",                              limit: 255
    t.boolean  "require_parental_consent_for_minors"
    t.boolean  "allow_participant_login"
  end

  create_table "degrees", force: :cascade do |t|
    t.string   "type",                     limit: 255
    t.integer  "participant_id"
    t.integer  "institution_id"
    t.integer  "high_school_id"
    t.date     "graduated_on"
    t.string   "degree_title",             limit: 255
    t.string   "major_1",                  limit: 255
    t.string   "major_1_cip",              limit: 255
    t.string   "major_2",                  limit: 255
    t.string   "major_2_cip",              limit: 255
    t.string   "major_3",                  limit: 255
    t.string   "major_3_cip",              limit: 255
    t.string   "major_4",                  limit: 255
    t.string   "major_4_cip",              limit: 255
    t.string   "source",                   limit: 255
    t.integer  "clearinghouse_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "degrees", ["customer_id"], name: "index_degrees_on_customer_id"

  create_table "education_levels", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "description", limit: 255
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "education_levels", ["customer_id"], name: "index_education_levels_on_customer_id"

  create_table "enrollments", force: :cascade do |t|
    t.string   "type",                       limit: 255
    t.integer  "participant_id"
    t.integer  "institution_id"
    t.integer  "high_school_id"
    t.date     "began_on"
    t.date     "ended_on"
    t.string   "enrollment_status",          limit: 255
    t.string   "class_level",                limit: 255
    t.string   "major_1",                    limit: 255
    t.string   "major_1_cip",                limit: 255
    t.string   "major_2",                    limit: 255
    t.string   "major_2_cip",                limit: 255
    t.string   "source",                     limit: 255
    t.integer  "clearinghouse_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.boolean  "placed_in_remedial_math"
    t.boolean  "placed_in_remedial_english"
  end

  add_index "enrollments", ["customer_id"], name: "index_enrollments_on_customer_id"

  create_table "event_attendances", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "event_id"
    t.boolean  "rsvp"
    t.boolean  "attended"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_shift_id"
    t.boolean  "admin"
    t.integer  "customer_id"
    t.string   "attendance_option", limit: 255
    t.string   "audience",          limit: 255
  end

  add_index "event_attendances", ["customer_id"], name: "index_event_attendances_on_customer_id"
  add_index "event_attendances", ["event_id", "person_id"], name: "index_event_attendances_on_event_id_and_person_id", unique: true
  add_index "event_attendances", ["event_id"], name: "index_event_attendances_on_event_id"
  add_index "event_attendances", ["person_id"], name: "index_event_attendances_on_person_id"

  create_table "event_groups", force: :cascade do |t|
    t.string   "name",                                     limit: 255
    t.text     "description"
    t.integer  "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_external_students"
    t.boolean  "allow_external_volunteers"
    t.integer  "volunteer_training_id"
    t.integer  "mentor_training_id"
    t.boolean  "volunteer_training_optional"
    t.boolean  "mentor_training_optional"
    t.string   "stylesheet_url",                           limit: 255
    t.text     "student_description"
    t.text     "volunteer_description"
    t.text     "mentor_description"
    t.text     "footer_content"
    t.text     "student_confirmation_message"
    t.text     "volunteer_confirmation_message"
    t.text     "mentor_confirmation_message"
    t.boolean  "hide_description_in_confirmation_message"
    t.integer  "customer_id"
    t.boolean  "open_to_mentors"
    t.integer  "mentor_hours_prior_disable_cancel"
    t.integer  "student_hours_prior_disable_cancel"
    t.integer  "volunteer_hours_prior_disable_cancel"
    t.text     "mentor_disable_message"
    t.text     "student_disable_message"
    t.text     "volunteer_disable_message"
  end

  add_index "event_groups", ["customer_id"], name: "index_event_groups_on_customer_id"

  create_table "event_shifts", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "description",         limit: 255
    t.integer  "event_id"
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "show_for_volunteers"
    t.boolean  "show_for_mentors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "event_shifts", ["customer_id"], name: "index_event_shifts_on_customer_id"

  create_table "event_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "customer_id"
  end

  add_index "event_types", ["customer_id"], name: "index_event_types_on_customer_id"

  create_table "events", force: :cascade do |t|
    t.string   "name",                            limit: 255
    t.date     "date"
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "location_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                            limit: 255
    t.boolean  "show_for_participants",                       default: true
    t.boolean  "show_for_mentors",                            default: true
    t.boolean  "allow_rsvps"
    t.integer  "event_type_id"
    t.integer  "event_group_id"
    t.string   "location_text",                   limit: 255
    t.integer  "capacity"
    t.integer  "event_coordinator_id"
    t.boolean  "time_tba"
    t.text     "student_description"
    t.text     "volunteer_description"
    t.text     "mentor_description"
    t.integer  "student_capacity"
    t.integer  "mentor_capacity"
    t.integer  "volunteer_capacity"
    t.time     "student_start_time"
    t.time     "student_end_time"
    t.time     "volunteer_start_time"
    t.time     "volunteer_end_time"
    t.time     "mentor_start_time"
    t.time     "mentor_end_time"
    t.boolean  "show_for_students",                           default: true
    t.boolean  "show_for_volunteers",                         default: true
    t.integer  "customer_id"
    t.integer  "earliest_grade_level_level"
    t.integer  "latest_grade_level_level"
    t.boolean  "send_attendance_emails"
    t.boolean  "always_show_on_attendance_pages"
  end

  add_index "events", ["customer_id"], name: "index_events_on_customer_id"

  create_table "financial_aid_packages", force: :cascade do |t|
    t.integer  "participant_id"
    t.integer  "college_application_id"
    t.integer  "academic_year"
    t.integer  "cost_of_attendance_cents",                          default: 0,     null: false
    t.string   "cost_of_attendance_currency",           limit: 255, default: "USD", null: false
    t.string   "cost_of_attendance_source",             limit: 255
    t.integer  "expected_family_contribution_cents",                default: 0,     null: false
    t.string   "expected_family_contribution_currency", limit: 255, default: "USD", null: false
    t.integer  "grants_total_cents",                                default: 0,     null: false
    t.string   "grants_total_currency",                 limit: 255, default: "USD", null: false
    t.integer  "loans_total_cents",                                 default: 0,     null: false
    t.string   "loans_total_currency",                  limit: 255, default: "USD", null: false
    t.integer  "work_study_total_cents",                            default: 0,     null: false
    t.string   "work_study_total_currency",             limit: 255, default: "USD", null: false
    t.integer  "gap_total_cents",                                   default: 0,     null: false
    t.string   "gap_total_currency",                    limit: 255, default: "USD", null: false
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
  end

  create_table "financial_aid_source_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "financial_aid_sources", force: :cascade do |t|
    t.integer  "package_id"
    t.integer  "source_type_id"
    t.integer  "amount_cents",                           default: 0,     null: false
    t.string   "amount_currency",            limit: 255, default: "USD", null: false
    t.integer  "scholarship_application_id"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",               null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "grade_levels", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.integer  "level"
    t.string   "abbreviation", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "help_texts", force: :cascade do |t|
    t.string   "object_class",   limit: 255
    t.string   "attribute_name", limit: 255
    t.string   "title",          limit: 255
    t.text     "instructions"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "hint"
    t.string   "audience",       limit: 255
  end

  create_table "how_did_you_hear_options", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.boolean  "show_for_participants"
    t.boolean  "show_for_mentors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "how_did_you_hear_options", ["customer_id"], name: "index_how_did_you_hear_options_on_customer_id"

  create_table "how_did_you_hear_options_people", id: false, force: :cascade do |t|
    t.integer "person_id"
    t.integer "how_did_you_hear_option_id"
    t.integer "customer_id"
  end

  add_index "how_did_you_hear_options_people", ["customer_id"], name: "index_how_did_you_hear_options_people_on_customer_id"

  create_table "identities", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "password_digest", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "identities", ["customer_id"], name: "index_identities_on_customer_id"

  create_table "income_levels", force: :cascade do |t|
    t.float    "min_level"
    t.float    "max_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "income_levels", ["customer_id"], name: "index_income_levels_on_customer_id"

  create_table "institutions", id: false, force: :cascade do |t|
    t.integer  "unitid"
    t.string   "instnm",     limit: 255
    t.string   "addr",       limit: 255
    t.string   "city",       limit: 255
    t.string   "stabbr",     limit: 255
    t.string   "zip",        limit: 255
    t.integer  "fips"
    t.integer  "obereg"
    t.string   "chfnm",      limit: 255
    t.string   "chftitle",   limit: 255
    t.string   "gentele",    limit: 255
    t.string   "faxtele",    limit: 255
    t.integer  "ein"
    t.integer  "opeid"
    t.integer  "opeflag"
    t.string   "webaddr",    limit: 255
    t.string   "adminurl",   limit: 255
    t.string   "faidurl",    limit: 255
    t.string   "applurl",    limit: 255
    t.string   "npricurl",   limit: 255
    t.integer  "sector"
    t.integer  "iclevel"
    t.integer  "control"
    t.integer  "hloffer"
    t.integer  "ugoffer"
    t.integer  "groffer"
    t.integer  "hdegofr1"
    t.integer  "deggrant"
    t.integer  "hbcu"
    t.integer  "hospital"
    t.integer  "medical"
    t.integer  "tribal"
    t.integer  "locale"
    t.integer  "openpubl"
    t.string   "act",        limit: 255
    t.integer  "newid"
    t.integer  "deathyr"
    t.datetime "closedat"
    t.integer  "cyactive"
    t.integer  "postsec"
    t.integer  "pseflag"
    t.integer  "pset4flg"
    t.integer  "rptmth"
    t.text     "ialias"
    t.integer  "instcat"
    t.integer  "ccbasic"
    t.integer  "ccipug"
    t.integer  "ccipgrad"
    t.integer  "ccugprof"
    t.integer  "ccenrprf"
    t.integer  "ccsizset"
    t.integer  "carnegie"
    t.integer  "landgrnt"
    t.integer  "instsize"
    t.integer  "cbsa"
    t.integer  "cbsatype"
    t.integer  "csa"
    t.integer  "necta"
    t.integer  "f1systyp"
    t.string   "f1sysnam",   limit: 255
    t.integer  "f1syscod"
    t.integer  "countycd"
    t.string   "countynm",   limit: 255
    t.integer  "cngdstcd"
    t.float    "longitud"
    t.float    "latitude"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",                              limit: 255
    t.string   "street",                            limit: 255
    t.string   "city",                              limit: 255
    t.string   "state",                             limit: 255
    t.string   "zip",                               limit: 255
    t.string   "phone",                             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                              limit: 255
    t.boolean  "partner_school"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address",                           limit: 255
    t.string   "county",                            limit: 255
    t.string   "district",                          limit: 255
    t.string   "school_code",                       limit: 255
    t.integer  "institution_id"
    t.string   "country",                           limit: 255
    t.string   "website_url",                       limit: 255
    t.boolean  "enable_college_mapper_integration"
    t.integer  "customer_id"
    t.string   "slug",                              limit: 255
  end

  add_index "locations", ["customer_id"], name: "index_locations_on_customer_id"
  add_index "locations", ["slug"], name: "index_locations_on_slug", unique: true

  create_table "mentor_participants", force: :cascade do |t|
    t.integer  "mentor_id"
    t.integer  "participant_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "college_mapper_id"
  end

  create_table "mentor_term_groups", force: :cascade do |t|
    t.integer  "term_id"
    t.integer  "location_id"
    t.string   "title",              limit: 255
    t.string   "course_id",          limit: 255
    t.string   "times",              limit: 255
    t.time     "depart_time"
    t.time     "return_time"
    t.integer  "capacity"
    t.boolean  "none_option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mentor_terms_count",             default: 0
    t.integer  "linked_group_id"
    t.string   "day_of_week",        limit: 255
    t.integer  "customer_id"
    t.string   "permissions_level",  limit: 255
  end

  add_index "mentor_term_groups", ["customer_id"], name: "index_mentor_term_groups_on_customer_id"

  create_table "mentor_terms", force: :cascade do |t|
    t.integer  "mentor_id"
    t.integer  "mentor_term_group_id"
    t.boolean  "lead"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "volunteer"
    t.boolean  "driver"
    t.text     "notes"
    t.integer  "customer_id"
  end

  add_index "mentor_terms", ["customer_id"], name: "index_mentor_terms_on_customer_id"

  create_table "notes", force: :cascade do |t|
    t.text     "note"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
    t.integer  "notable_id"
    t.string   "notable_type",          limit: 255
    t.string   "creator_name",          limit: 255
    t.string   "category",              limit: 255
    t.string   "access_level",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.datetime "document_updated_at"
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size"
    t.string   "document_file_name",    limit: 255
    t.string   "title",                 limit: 255
    t.boolean  "needs_followup"
    t.string   "contact_type",          limit: 255
  end

  add_index "notes", ["customer_id"], name: "index_notes_on_customer_id"

  create_table "object_filters", force: :cascade do |t|
    t.string   "object_class",               limit: 255
    t.string   "title",                      limit: 255
    t.text     "criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "opposite_title",             limit: 255
    t.integer  "target_percentage"
    t.integer  "warning_threshold"
    t.date     "start_display_at"
    t.date     "end_display_at"
    t.integer  "earliest_grade_level"
    t.integer  "earliest_grade_level_level"
    t.integer  "latest_grade_level_level"
    t.integer  "customer_id"
    t.string   "category",                   limit: 255
    t.integer  "position"
    t.boolean  "warn_if_false"
  end

  add_index "object_filters", ["customer_id"], name: "index_object_filters_on_customer_id"

  create_table "participant_groups", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.integer  "grad_year"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participants_count",             default: 0
  end

  create_table "people", force: :cascade do |t|
    t.string   "firstname",                             limit: 255
    t.string   "middlename",                            limit: 255
    t.string   "lastname",                              limit: 255
    t.string   "suffix",                                limit: 255
    t.string   "nickname",                              limit: 255
    t.string   "street",                                limit: 255
    t.string   "city",                                  limit: 255
    t.string   "state",                                 limit: 255
    t.string   "zip",                                   limit: 255
    t.string   "email",                                 limit: 255
    t.string   "phone_home",                            limit: 255
    t.string   "phone_mobile",                          limit: 255
    t.string   "phone_work",                            limit: 255
    t.string   "screen_name",                           limit: 255
    t.string   "screen_name_type",                      limit: 255
    t.date     "birthdate"
    t.string   "sex",                                   limit: 255
    t.boolean  "free_reduced_lunch"
    t.boolean  "no_internet_at_home"
    t.boolean  "english_not_primary_at_home"
    t.string   "other_languages",                       limit: 255
    t.boolean  "english_second_language"
    t.integer  "grad_year"
    t.float    "gpa"
    t.date     "gpa_date"
    t.text     "after_school_activities"
    t.text     "time_conflicts"
    t.date     "fafsa_submitted_date"
    t.date     "binder_date"
    t.date     "photo_release_date"
    t.boolean  "photo_release_no_fullname"
    t.string   "relationship",                          limit: 255
    t.string   "type",                                  limit: 255
    t.integer  "high_school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "first_generation"
    t.boolean  "computer_at_home"
    t.string   "dietary_restrictions",                  limit: 255
    t.boolean  "vegetarian"
    t.boolean  "vegan"
    t.boolean  "hispanic"
    t.boolean  "african_american"
    t.boolean  "american_indian"
    t.boolean  "asian_american"
    t.boolean  "pacific_islander"
    t.boolean  "caucasian"
    t.string   "ethnicity_details",                     limit: 255
    t.boolean  "inactive"
    t.integer  "mother_education_level_id"
    t.integer  "father_education_level_id"
    t.string   "mother_education_country",              limit: 255
    t.string   "father_education_country",              limit: 255
    t.integer  "family_income_level_id"
    t.integer  "college_attending_id"
    t.integer  "household_size"
    t.boolean  "single_parent_household"
    t.boolean  "not_attending_college"
    t.date     "intake_survey_date"
    t.boolean  "received_binder"
    t.boolean  "live_the_dream_recipient"
    t.boolean  "live_the_dream_nominee"
    t.boolean  "address_is_invalid"
    t.boolean  "email_is_invalid"
    t.text     "other_programs"
    t.date     "college_graduation_date"
    t.boolean  "target_participant"
    t.boolean  "not_target_participant"
    t.text     "inactive_explanation"
    t.datetime "inactive_date"
    t.string   "parent_only_speaks_language",           limit: 255
    t.boolean  "kosher"
    t.boolean  "halal"
    t.boolean  "foster_youth"
    t.string   "postsecondary_goal",                    limit: 255
    t.boolean  "live_with_mother"
    t.boolean  "live_with_father"
    t.boolean  "parent_graduated_college"
    t.string   "family_members_who_went_to_college",    limit: 255
    t.boolean  "family_members_graduated"
    t.boolean  "attended_school_outside_usa"
    t.string   "countries_attended_school_outside_usa", limit: 255
    t.boolean  "attended_grade_1_outside_usa"
    t.boolean  "attended_grade_2_outside_usa"
    t.boolean  "attended_grade_3_outside_usa"
    t.boolean  "attended_grade_4_outside_usa"
    t.boolean  "attended_grade_5_outside_usa"
    t.boolean  "attended_grade_6_outside_usa"
    t.boolean  "attended_grade_7_outside_usa"
    t.boolean  "attended_grade_8_outside_usa"
    t.boolean  "attended_grade_9_outside_usa"
    t.boolean  "attended_grade_10_outside_usa"
    t.boolean  "attended_grade_11_outside_usa"
    t.boolean  "attended_grade_12_outside_usa"
    t.boolean  "african"
    t.boolean  "latino"
    t.boolean  "middle_eastern"
    t.boolean  "other_ethnicity"
    t.string   "african_american_heritage",             limit: 255
    t.string   "african_heritage",                      limit: 255
    t.string   "american_indian_heritage",              limit: 255
    t.string   "asian_american_heritage",               limit: 255
    t.string   "hispanic_heritage",                     limit: 255
    t.string   "latino_heritage",                       limit: 255
    t.string   "middle_eastern_heritage",               limit: 255
    t.string   "pacific_islander_heritage",             limit: 255
    t.string   "caucasian_heritage",                    limit: 255
    t.string   "other_heritage",                        limit: 255
    t.boolean  "bad_address"
    t.boolean  "bad_phone"
    t.boolean  "bad_email"
    t.integer  "previous_participant_id"
    t.datetime "ferpa_agreement_signed_at"
    t.datetime "background_check_run_at"
    t.string   "background_check_result",               limit: 255
    t.datetime "risk_form_signed_at"
    t.string   "risk_form_signature",                   limit: 255
    t.string   "reg_id",                                limit: 255
    t.string   "uw_student_no",                         limit: 255
    t.string   "uw_net_id",                             limit: 255
    t.datetime "resource_cache_updated_at"
    t.string   "display_name",                          limit: 255
    t.string   "survey_id",                             limit: 255
    t.string   "other_how_did_you_hear",                limit: 255
    t.boolean  "can_send_texts"
    t.boolean  "can_receive_texts"
    t.boolean  "unlimited_texting"
    t.boolean  "college_bound_scholarship"
    t.string   "other_college_programs",                limit: 255
    t.integer  "mentor_participant_count"
    t.integer  "other_location_id"
    t.text     "aliases"
    t.boolean  "crimes_against_persons_or_financial"
    t.boolean  "drug_related_crimes"
    t.boolean  "related_proceedings_crimes"
    t.boolean  "medicare_healthcare_crimes"
    t.text     "victim_crimes_explanation"
    t.boolean  "general_convictions"
    t.text     "general_convictions_explanation"
    t.datetime "background_check_authorized_at"
    t.datetime "van_driver_training_completed_at"
    t.string   "husky_card_rfid",                       limit: 255
    t.integer  "participant_group_id"
    t.string   "avatar_image_url",                      limit: 255
    t.string   "organization",                          limit: 255
    t.string   "shirt_size",                            limit: 255
    t.integer  "college_mapper_id"
    t.boolean  "fafsa_not_applicable"
    t.integer  "child_id"
    t.string   "relationship_to_child",                 limit: 255
    t.string   "occupation",                            limit: 255
    t.decimal  "annual_income"
    t.boolean  "needs_interpreter"
    t.text     "meeting_availability"
    t.string   "preferred_contact_method",              limit: 255
    t.string   "preferred_phone",                       limit: 255
    t.string   "facebook_id",                           limit: 255
    t.boolean  "check_email_regularly"
    t.integer  "student_id_number"
    t.string   "birthplace",                            limit: 255
    t.boolean  "married"
    t.integer  "number_of_children"
    t.boolean  "free_reduced_lunch_signed_up"
    t.string   "parent_type",                           limit: 255
    t.text     "filter_cache"
    t.string   "login_token",                           limit: 255
    t.datetime "login_token_expires_at"
    t.integer  "customer_id"
    t.string   "email2",                                limit: 255
    t.boolean  "gluten_free"
    t.boolean  "deceased"
    t.boolean  "incarcerated"
    t.integer  "highest_education_level_id"
    t.string   "migration_id",                          limit: 255
    t.boolean  "lives_with"
    t.string   "education_country",                     limit: 255
    t.string   "personal_statement_status",             limit: 255
    t.string   "resume_status",                         limit: 255
    t.string   "activity_log_status",                   limit: 255
    t.string   "avatar",                                limit: 255
    t.string   "postsecondary_plan",                    limit: 255
    t.boolean  "asian"
    t.string   "asian_heritage",                        limit: 255
    t.integer  "followup_note_count"
    t.datetime "sex_offender_check_run_at"
    t.string   "sex_offender_check_result",             limit: 255
    t.datetime "conduct_form_signed_at"
    t.string   "conduct_form_signature",                limit: 255
    t.string   "previous_residence_jurisdictions",      limit: 255
    t.string   "driver_form_signature",                 limit: 255
    t.datetime "driver_form_signed_at"
    t.string   "driver_form_offense_response",          limit: 255
    t.boolean  "has_previous_driving_convictions"
    t.string   "driver_form_remarks",                   limit: 255
    t.boolean  "driver_license_on_file"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "homeless"
    t.boolean  "subsidized_housing"
    t.boolean  "immigrant"
    t.datetime "uwfs_training_date"
    t.boolean  "clearinghouse_record_found"
    t.boolean  "parental_consent_on_file"
    t.string   "intake_form_signature",                 limit: 255
    t.boolean  "is_emergency_contact"
    t.boolean  "on_track_to_graduate",                              default: true
    t.string   "slug",                                  limit: 255
  end

  add_index "people", ["college_attending_id"], name: "index_people_on_college_attending_id"
  add_index "people", ["customer_id"], name: "index_people_on_customer_id"
  add_index "people", ["display_name"], name: "index_people_on_display_name"
  add_index "people", ["firstname"], name: "index_people_on_firstname"
  add_index "people", ["grad_year"], name: "index_people_on_grad_year"
  add_index "people", ["lastname"], name: "index_people_on_lastname"
  add_index "people", ["middlename"], name: "index_people_on_middlename"
  add_index "people", ["nickname"], name: "index_people_on_nickname"
  add_index "people", ["slug"], name: "index_people_on_slug", unique: true
  add_index "people", ["type"], name: "index_people_on_type"
  add_index "people", ["uw_net_id"], name: "index_people_on_uw_net_id"

  create_table "people_fafsas", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "year"
    t.datetime "fafsa_submitted_at"
    t.datetime "wasfa_submitted_at"
    t.boolean  "not_applicable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people_fafsas", ["person_id", "year"], name: "index_people_fafsas_on_person_id_and_year"

  create_table "people_programs", id: false, force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people_programs", ["person_id", "program_id"], name: "index_people_programs_on_person_id_and_program_id"

  create_table "programs", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.string   "abbreviation", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "website_url",  limit: 255
  end

  create_table "reports", force: :cascade do |t|
    t.string   "key",          limit: 255
    t.text     "object_ids"
    t.string   "format",       limit: 255
    t.string   "type",         limit: 255
    t.string   "file_path",    limit: 255
    t.string   "status",       limit: 255
    t.integer  "customer_id"
    t.datetime "generated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scholarship_applications", force: :cascade do |t|
    t.integer  "scholarship_id"
    t.integer  "participant_id"
    t.boolean  "awarded"
    t.boolean  "renewable"
    t.boolean  "accepted"
    t.decimal  "amount"
    t.date     "date_applied"
    t.text     "restrictions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.boolean  "nominated"
    t.integer  "renewable_years"
    t.boolean  "full_ride"
    t.boolean  "gap_funding"
    t.boolean  "living_stipend"
    t.integer  "institution_id"
    t.date     "application_due_date"
  end

  create_table "scholarships", force: :cascade do |t|
    t.string   "title",                   limit: 255
    t.string   "organization_name",       limit: 255
    t.text     "description"
    t.decimal  "default_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.integer  "default_renewable_years"
    t.boolean  "default_full_ride"
    t.boolean  "default_gap_funding"
    t.boolean  "default_living_stipend"
    t.boolean  "default_renewable"
  end

  add_index "scholarships", ["customer_id"], name: "index_scholarships_on_customer_id"

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "terms", force: :cascade do |t|
    t.integer  "year"
    t.integer  "quarter_code"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "course_ids"
    t.boolean  "allow_signups"
    t.string   "title",               limit: 255
    t.string   "type",                limit: 255
    t.integer  "customer_id"
    t.text     "course_dependencies"
    t.text     "signup_description"
  end

  add_index "terms", ["customer_id"], name: "index_terms_on_customer_id"

  create_table "test_scores", force: :cascade do |t|
    t.integer  "participant_id"
    t.integer  "test_type_id"
    t.datetime "registered_at"
    t.datetime "taken_at"
    t.decimal  "total_score"
    t.text     "section_scores"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.boolean  "passed"
  end

  add_index "test_scores", ["customer_id"], name: "index_test_scores_on_customer_id"

  create_table "test_types", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.decimal  "maximum_total_score"
    t.text     "sections"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.string   "score_calculation_method", limit: 255
    t.boolean  "passable"
  end

  add_index "test_types", ["customer_id"], name: "index_test_types_on_customer_id"

  create_table "training_completions", force: :cascade do |t|
    t.integer  "training_id"
    t.integer  "person_id"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "training_completions", ["customer_id"], name: "index_training_completions_on_customer_id"

  create_table "trainings", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.text     "description"
    t.string   "video_url",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chapters_url",   limit: 255
    t.string   "stylesheet_url", limit: 255
    t.integer  "customer_id"
  end

  add_index "trainings", ["customer_id"], name: "index_trainings_on_customer_id"

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "crypted_password",          limit: 255
    t.string   "salt",                      limit: 255
    t.string   "remember_token",            limit: 255
    t.string   "remember_token_expires_at", limit: 255
    t.string   "identity_url",              limit: 255
    t.string   "type",                      limit: 255
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.string   "provider",                  limit: 255
    t.string   "uid",                       limit: 255
    t.integer  "customer_id"
  end

  add_index "users", ["customer_id"], name: "index_users_on_customer_id"

end
