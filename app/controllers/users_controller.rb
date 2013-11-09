require 'eventful/api'

class UsersController < ApplicationController

    def index
      @users = User.where("name like ?", "%#{params[:q]}%")
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @users }
        format.json  { render :json => @users.map(&:attributes) }
      end
    end

    def update
        user = current_user

        user.city = params[:user][:city]
        user.state = params[:user][:state]

        user.save

        # raise params.to_yaml
        redirect_to :root
    end

    def eventful
        timeframe = params[:timeframe][:start].delete('-') +
                    '00-' + params[:timeframe][:end].delete('-') + '00'

        # timeframe must be in the form 'YYYYMMDD00-YYYYMMDD00'
        # timeframe = "2013111000-2013111100"
        eventful = Eventful::API.new ENV['eventful_key']

        @events = eventful.call 'events/search',
            date: timeframe, location: current_user.city

        # raise .to_yaml
        
    end
end