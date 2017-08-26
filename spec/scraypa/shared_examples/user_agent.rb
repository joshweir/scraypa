RSpec.shared_examples "a user agent customizer" do |params|
  if params && params[:driver] == :poltergeist
    it_behaves_like "a user agent customizer (using :poltergeist)", params
  elsif params && params[:driver] == :headless_chromium
    it_behaves_like "a user agent customizer (using :headless_chromium)", params
  else
    it_behaves_like "a user agent customizer (using RestClient)", params
  end
end