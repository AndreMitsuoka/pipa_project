Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "474083902612604","82e9a427746fae28dab39cbbb55be1b3",
  :scope => 'email,read_friendlists', :display => 'popup'

end