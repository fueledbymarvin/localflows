class UsersController < ApplicationController

    def index
      @users = User.all
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
        emails = params[:search][:users].scan(/\((.+?)\)/).collect {|x| x[0] }
        @nFriends = emails.length + 1

        events = current_user.eventful.call('events/search', {
            date: timeframe,
            location: "#{current_user.city}, #{current_user.state}",
            page_size: 100,
            sort_order: "popularity",
            keywords: params[:search][:keyword]
        })["events"]["event"]

        @events = current_user.group(Date.parse(params[:timeframe][:start]), Date.parse(params[:timeframe][:end]), emails, events)
    end
end