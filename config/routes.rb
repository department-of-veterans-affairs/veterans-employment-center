EmploymentPortal::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :veterans do
    member do
      get :word
    end
  end
  resources :employers, except: [:index]
  get "/commitments" => 'employers#commitments', as: :commitments
  get '/download_employers' => 'employers#download_employers'
  get "job-seekers/create-resume" => 'veterans#new', as: :resume_builder
  post 'veterans/new' => 'veterans#new'
  get 'employer-list' => 'employers#index', as: :employer_list
  root 'static_pages#home'
  get '/employers' => redirect('https://www.dol.gov/veterans/hireaveteran/') 
  get '/job-seekers' => redirect('https://www.dol.gov/veterans/findajob/')
  get '/veterans' => redirect { |params, request| Rails.application.config.action_controller.relative_url_root }
  get '/job-seekers/skills-translator' => redirect { |params, request| Rails.application.config.action_controller.relative_url_root }
  get '/job-seekers/search-jobs' => redirect { |params, request| Rails.application.config.action_controller.relative_url_root }
  match '/404' => 'errors#error404', via: [ :get, :post, :patch, :delete ]
end
