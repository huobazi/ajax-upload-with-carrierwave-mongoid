class Screenshot
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Rails.application.routes.url_helpers

  attr_accessible :image 
  field :image 

  mount_uploader :image, ScreenshotUploader 

end
