== Ajax Upload With Carrierwave and Mongoid
使用[file-uploader](https://github.com/valums/file-uploader)是一个用javascrit编写的文件上传libary,在这里我使用[CarrierWave](https://github.com/jnicklas/carrierwave)和mongoid来完成这个功能.


== RubyGems

`
gem 'mongoid', '3.0.4'
gem 'carrierwave', '0.6.2'
gem 'carrierwave-mongoid', :github => 'jnicklas/carrierwave-mongoid', :branch => 'mongoid-3.0' 
gem 'mini_magick', '3.4'
gem 'rack-raw-upload', '1.1.0'
`

== Model 

`
class Screenshot
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Rails.application.routes.url_helpers

  attr_accessible :image 
  field :image 

  mount_uploader :image, ScreenshotUploader 

end
`
== Controller

`
class ScreenshotsController < ApplicationController

  def index
    @screenshots = Screenshot.all.desc(:created_at)

    respond_to do |format|
      format.html # index.html.erb    
      format.js{ render :layout => false}
    end
  end

  def create
    file = params[:qqfile].is_a?(ActionDispatch::Http::UploadedFile) ? params[:qqfile] : params[:file]
    @screenshot = Screenshot.new
    @screenshot.image = file
    if @screenshot.save
      render json: { success: true, src: @screenshot.to_json }
    else
      render json: @screenshot.errors.to_json
    end
  end

  def destroy
    @screenshot = Screenshot.find(params[:id])
    @screenshot.destroy

    respond_to do |format|
      format.html { redirect_to screenshots_path }
      format.js{ 
        @screenshots = Screenshot.all.desc(:created_at)
        render :layout => false
      }
    end

  end

end
`
== Uploader

`
# encoding: utf-8
require "digest/md5"
require 'carrierwave/processing/mini_magick'

class ScreenshotUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end


  process :convert => 'png'

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fill => [120, 120]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # see http://huacnlee.com/blog/carrierwave-upload-store-file-name-config/
  def filename
    if super.present?
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记，所以它将是唯一的
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{file.extension.downcase}"
    end
  end
end
`

== Javascript

`
  $(document).ready(function(){

    var uploader = new qq.FileUploader({
      debug: true,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      sizeLimit: 1048576, // max size: 1MB
      minSizeLimit: 0, // min size
      multiple: true,
      element: document.getElementById('file-uploader'),
      action: '<%= screenshots_path %>',
      onComplete: function(id, fileName, responseJSON){
        $.getScript("<%= screenshots_path %>");
      },
      onSubmit: function(id, fileName) {
        uploader.setParams({
          xx: "xx",
          yy: 'yy',
          zz: 'zz',       
          authenticity_token: "<%= form_authenticity_token.to_s %>"
        });
      }
    });

});
`
