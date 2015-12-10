module TogglV8
  class API

    ##
    # ---------
    # :section: Users
    #
    # api_token                 : (string)
    # default_wid               : default workspace id (integer)
    # email                     : (string)
    # jquery_timeofday_format   : (string)
    # jquery_date_format        : (string)
    # timeofday_format          : (string)
    # date_format               : (string)
    # store_start_and_stop_time : whether start and stop time are saved on time entry (boolean)
    # beginning_of_week         : (integer, Sunday=0)
    # language                  : user's language (string)
    # image_url                 : url with the user's profile picture(string)
    # sidebar_piechart          : should a piechart be shown on the sidebar (boolean)
    # at                        : timestamp of last changes
    # new_blog_post             : an object with toggl blog post title and link

    def me(all=nil)
      # NOTE: response['since'] is discarded because it is outside response['data']
      #       (See TogglV8::API#get in lib/togglv8.rb)
      get "me%s" % [all.nil? ? "" : "?with_related_data=#{all}"]
    end

    def my_clients(user=nil)
      user = me(all=true) if user.nil?
      user['clients'] || {}
    end

    def my_projects(user=nil)
      user = me(all=true) if user.nil?
      return {} unless user['projects']
      projects = user['projects']
      projects.delete_if { |p| p['server_deleted_at'] }
    end

    def my_deleted_projects(user=nil)
      user = me(all=true) if user.nil?
      return {} unless user['projects']
      projects = user['projects']
      projects.keep_if { |p| p['server_deleted_at'] }
    end

    def my_tags(user=nil)
      user = me(all=true) if user.nil?
      user['tags'] || {}
    end

    def my_tasks(user=nil)
      user = me(all=true) if user.nil?
      user['tasks'] || {}
    end

    def my_time_entries(user=nil)
      user = me(all=true) if user.nil?
      user['time_entries'] || {}
    end

    def my_workspaces(user=nil)
      user = me(all=true) if user.nil?
      user['workspaces'] || {}
    end

    def create_user(params)
      params['created_with'] = 'TogglV8' unless params.has_key?('created_with')
      requireParams(params, ['email', 'password', 'timezone', 'created_with'])
      post "signups", { 'user' => params }
    end
  end
end