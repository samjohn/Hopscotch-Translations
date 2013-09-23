Translations::Application.routes.draw do
  resources :english_words do
    collection do
      get :localizable
    end
  end

  root to:"gengo_responses#index"
  resources :gengo_responses

end
