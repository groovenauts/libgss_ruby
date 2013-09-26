
require 'factory_girl'

FactoryGirl.define do

  factory :client_release_device_type01, class: ClientRelease::DeviceType do
    cd   1
    name "iOS"
  end

  factory :client_release_device_type02, class: ClientRelease::DeviceType do
    cd   2
    name "Android"
  end
end
