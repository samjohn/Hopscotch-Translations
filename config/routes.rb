Translations::Application.routes.draw do
  resources :english_words

  root to:"gengo_responses#index"
  resources :gengo_responses

end
