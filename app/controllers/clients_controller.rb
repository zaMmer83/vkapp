class ClientsController < ApplicationController
  before_filter :authenticate  
	
	def index
    @title = "Clients"
    @clients = Client.scoped;
    @clients = @clients.search(params[:search]) unless params[:search].blank?
    @clients = @clients.paginate(:page => params[:page], :per_page => 50)    
  end
end
