EmploymentPortal::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :veterans do
    member do
      put :favorite
      get :word
    end
  end
  resources :skills
  resources :employers, except: [:index]
  resources :experiences, only: [:destroy]
  namespace :api, defaults: {format: 'json'} do
    resources :employers, only: [:index]
  end
  get "/commitments" => 'employers#commitments'
  get '/download_employers' => 'employers#download_employers'
  get "job-seekers/create-resume" => 'veterans#new', as: :resume_builder
  get 'job-seekers/search-jobs' => 'search#search_jobs', as: :search_jobs
  post 'veterans/new' => 'veterans#new'
  get '/employers' => 'static_pages#employers', as: :employer_home
  get 'employer-list' => 'employers#index', as: :employer_list
  get 'job-seekers/skills-translator' => 'skills#index', as: :skills_translator
  post 'skills-translator/save_event' => 'skills#save_event'
  get  'skills-translator/get_skills/:prefix' => 'skills#get_skills', as: :skills_translator_get_skills
  get  'skills-translator/get_common_skills' => 'skills#get_common_skills'
  post 'skills-translator/add_skill' => 'skills#add_skill'
  post 'skills-translator/suggest_skills' => 'skills#suggest'
  root 'static_pages#home'
  get '/job-seekers' => redirect("https://www.vets.gov/employment/job-seekers/"), as: :job_seekers
  match '/404' => 'errors#error404', via: [ :get, :post, :patch, :delete ]
end
