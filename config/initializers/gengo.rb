GENGO_API_KEY=ENV["GENGO_API_KEY"]
GENGO_SECRET_KEY=ENV["GENGO_SECRET_KEY"]
GENGO = Gengo::API.new({
  :public_key => GENGO_API_KEY,
  :private_key => GENGO_SECRET_KEY,
  :sandbox => true, # Or false, depending on your work
})
