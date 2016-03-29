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
  get '/download_veterans' => 'employers#download_veterans'
  post '/download_candidate_veterans' => 'veterans#download_candidate_veterans'
  get "/favorites" => 'veterans#favorites'
  get "job-seekers/create-resume" => 'veterans#new', as: :resume_builder
  get 'job-seekers/search_jobs' => 'search#search_jobs', as: :search_jobs
  post 'veterans/new' => 'veterans#new'
  get '/employers' => 'static_pages#employers', as: :employer_home
  get 'employer-list' => 'employers#index', as: :employer_list
  get '/download_all_veterans' => 'veterans#download_all_veterans'
  get 'job-seekers/skills-translator' => 'skills#index', as: :skills_translator
  post 'skills-translator/save_event' => 'skills#save_event'
  post 'skills-translator/suggest' => 'skills#suggest'
  get  'skills-translator/get_skills/:prefix' => 'skills#get_skills', as: :skills_translator_get_skills
  get  'skills-translator/get_common_skills' => 'skills#get_common_skills'
  post 'skills-translator/add_skill' => 'skills#add_skill'
  root 'static_pages#home'
  match '/404' => 'errors#error404', via: [ :get, :post, :patch, :delete ]
end