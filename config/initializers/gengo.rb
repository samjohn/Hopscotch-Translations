GENGO_API_KEY=ENV["GENGO_API_KEY"]
GENGO_SECRET_KEY=ENV["GENGO_SECRET_KEY"]
GENGO_SANDBOX = Gengo::API.new({
  :public_key => ENV["GENGO_SANDBOX_API_KEY"],
  :private_key => ENV["GENGO_SANDBOX_SECRET_KEY"],
  :sandbox => true, # Or false, depending on your work
})
GENGO = Gengo::API.new({
  :public_key => ENV["GENGO_API_KEY"],
  :private_key => ENV["GENGO_SECRET_KEY"],
  :sandbox => false
})

LANGUAGES = %w(cs da de el es fr ja ko nl pt ru sv zh zh-tw)
LANGUAGE_FOLDER_MAPPINGS = {"zh" => "zh-Hans", "zh-tw" => "zh-Hant"}
