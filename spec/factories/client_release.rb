
require 'factory_girl'

FactoryGirl.define do

  factory :client_release01, class: ClientRelease do
    status_cd      2
    device_type_cd 1
    version        '2013073101'
    url            "https://itunes.apple.com/jp/app/xxxxxxxxxx/id123456789?mt=8"
    created_at 1375364758
    updated_at 1375364758
  end
end
