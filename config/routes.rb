RecruitingOnRails::Application.routes.draw do
  resources :associated_budgets


  get "reports/hire_leaver_count_by_month/index"

  get "reports/hire_leaver_count_by_month/run"

  get "reports/hires_by_year/index"

  get "reports/hires_by_year/run"

  get "reports/candidate_by_leave_type/index"

  get "reports/candidate_by_leave_type/run"

  resources :leave_reasons

  get "reports/team_by_year/index"

  get "reports/team_by_year/run"

  get "reports/candidates_by_source/index"

  get "reports/candidates_by_source/run"

  get "reports/cycle_time_report/index"

  get "reports/cycle_time_report/run"

  get "reports/index"

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

  match "/candidates/__history__.html" => 'candidates#noop' # <- because the timeline plugin does stupid shit

  resources :candidates do
    collection do
      get 'list'
      get 'timeline'
      get 'events'
    end
  end



  resources :candidate_sources

  resources :candidate_statuses

  resources :groups

  resources :users

  # The priority is based upon order of creation:
  # first created -> highest priority.
  match ":controller(/:action)"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#index'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
   root :to => 'login#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
