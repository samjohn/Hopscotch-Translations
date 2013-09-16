Translations::Application.routes.draw do
  root to:"gengo_responses#index"
  resources :gengo_responses
end
