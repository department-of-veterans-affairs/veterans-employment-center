class LocationsController < ApplicationController
  def destroy
    @id = params[:id]
    Location.find(params[:id]).destroy unless params[:id].blank? || !Location.exists?(params[:id])
    respond_to do |format|
      format.js
    end
  end
end
