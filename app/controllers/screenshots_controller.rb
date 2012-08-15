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
