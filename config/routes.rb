Translations::Application.routes.draw do
  resources :english_words do
    collection do
      get :localizable
    end
  end

  resources :foreign_words do
    collection do
      get "language/:language", to:"foreign_words#language", as: "language"
    end

  end

  root to: "english_words#index"
  resources :gengo_responses

end
