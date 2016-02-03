EmploymentPortal::Application.routes.draw do

devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }
  resources :veterans do
    member do
      put :favorite
      get :word
    end
  end
  resources :skills
  resources :employers, except: [:index]
  resources :site_feedbacks, only: [:index, :new, :create, :edit]
  namespace :api, defaults: {format: 'json'} do
    resources :employers, only: [:index]
  end
  get "/commitments" => 'employers#commitments'
  get '/download_employers' => 'employers#download_employers'
  get '/download_veterans' => 'employers#download_veterans'
  post '/download_candidate_veterans' => 'veterans#download_candidate_veterans'
  get "/favorites" => 'veterans#favorites'
  get "/createresume" => 'veterans#new', as: :resume_builder
  get 'search_jobs' => 'search#search_jobs', as: :search_jobs
  post 'veterans/new' => 'veterans#new'
  get "/nlxsearch" => 'static_pages#nlxsearch'
  get 'job-resources' => 'static_pages#job_resources', as: :job_resources
  get 'job-resources-disability' => 'static_pages#job_resources_disability', as: :job_resources_disability
  get 'job-resources-assistive-tech' => 'static_pages#job_resources_assistive_tech', as: :job_resources_assistive_tech
  get 'job-resources-education-counseling' => 'static_pages#job_resources_education_counseling', as: :job_resources_education_counseling
  get 'job-resources-military-transcripts' => 'static_pages#job_resources_military_transcripts', as: :job_resources_military_transcripts
  get 'job-resources-federal-employment' => 'static_pages#job_resources_federal_employment', as: :job_resources_federal_employment
  get 'job-resources-military-spouses' => 'static_pages#job_resources_military_spouses', as: :job_resources_military_spouses
  get 'job-resources-partnered' => 'static_pages#job_resources_partnered', as: :job_resources_partnered
  get 'job-resources-small-business' => 'static_pages#job_resources_small_business', as: :job_resources_small_business
  get 'job-resources-training-vocational' => 'static_pages#job_resources_training_vocational', as: :job_resources_training_vocational
  get 'job-resources-transitioning-servicemembers' => 'static_pages#job_resources_transitioning_servicemembers', as: :job_resources_transitioning_servicemembers
  get 'job-resources-wounded-warrior' => 'static_pages#job_resources_wounded_warrior', as: :job_resources_wounded_warrior
  get 'about-employment-center' => 'static_pages#about', as: :about_page
  get 'interest-profiler' => 'static_pages#interest_profiler', as: :interest_profiler
  get 'employers' => 'static_pages#employers', as: :employer_home
  get 'employer-list' => 'employers#index', as: :employer_list
  get 'how-to-post-jobs' => 'static_pages#how_to_post_jobs', as: :how_to_post_jobs
  get 'workplace-support' => 'static_pages#workplace_support', as: :workplace_support
  get 'on-the-job-training' => 'static_pages#on_the_job_training', as: :on_the_job_training
  get 'career-fairs' => 'static_pages#career_fairs', as: :career_fairs
  get 'understanding-military-experience' => 'static_pages#understanding_military_experience', as: :understanding_military_experience
  get 'employer-resources' => 'static_pages#employer_resources', as: :employer_resources
  get 'employer-news' => 'static_pages#employer_news', as: :employer_news
  get 'microdata-test-data' => 'static_pages#microdata_test_data', as: :microdata_test_data
  get 'microdata-test2-data' => 'static_pages#microdata_test2_data', as: :microdata_test2_data
  get '/download_site_feedback' => 'site_feedbacks#download_site_feedback'
  get '/download_all_veterans' => 'veterans#download_all_veterans'
  get '/for_job_seekers' => 'static_pages#for_job_seekers'
  get 'skills-translator' => 'skills#index', as: :skills_translator
  post 'skills-translator/save_event' => 'skills#save_event'
  post 'skills-translator/suggest' => 'skills#suggest'
  get  'skills-translator/get_skills/:prefix' => 'skills#get_skills', as: :skills_translator_get_skills
  get  'skills-translator/get_common_skills' => 'skills#get_common_skills'
  post 'skills-translator/add_skill' => 'skills#add_skill'
  root 'static_pages#home'
  match '/404' => 'errors#error404', via: [ :get, :post, :patch, :delete ]

end
