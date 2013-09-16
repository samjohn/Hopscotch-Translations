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
