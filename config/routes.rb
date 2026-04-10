RecruitingOnRails::Application.routes.draw do
  root :to => 'login#index'

  get  "login",               to: "login#index"
  post "login/attempt_login", to: "login#attempt_login"
  get  "dashboard",           to: "dashboard#index"

  resources :diary_entries
  resources :diary_entry_types
  resources :candidate_attachments

  get "reports/candidates_by_status/index"
  get "reports/candidates_by_status/run"
  get "reports/budget_report/index"
  get "reports/budget_report/run"
  get "reports/hire_leaver_count_by_month/index"
  get "reports/hire_leaver_count_by_month/run"
  get "reports/hires_by_year/index"
  get "reports/hires_by_year/run"
  get "reports/candidate_by_leave_type/index"
  get "reports/candidate_by_leave_type/run"
  get "reports/team_by_year/index"
  get "reports/team_by_year/run"
  get "reports/candidates_by_source/index"
  get "reports/candidates_by_source/run"
  get "reports/cycle_time_report/index"
  get "reports/cycle_time_report/run"
  get "reports/index"

  resources :associated_budgets
  resources :leave_reasons
  resources :budgeting_types
  resources :auth_configs
  resources :auth_config_types
  resources :genders
  resources :office_locations
  resources :work_history_rows
  resources :previous_employers
  resources :reference_checks
  resources :review_results
  resources :education_levels
  resources :schools
  resources :positions
  resources :code_submission_reviews
  resources :code_submissions
  resources :code_problems
  resources :registries
  resources :interview_reviews
  resources :interviews
  resources :interview_types
  resources :experience_levels

  resources :candidates do
    collection do
      get 'list'
      get 'timeline'
      get 'events'
      get 'calendar'
      get 'search'
    end
  end

  resources :candidate_sources
  resources :candidate_statuses
  resources :groups
  resources :users
end
