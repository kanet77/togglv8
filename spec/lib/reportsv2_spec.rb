require 'fileutils'

describe 'ReportsV2' do
  it 'initializes with api_token' do
    reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
    env = reports.env
    expect(env).to_not be nil
    expect(env['user']['api_token']).to eq Testing::API_TOKEN
  end

  it 'does not initialize with bogus api_token' do
    reports = TogglV8::ReportsV2.new(api_token: '4880nqor1orr9n241sn08070q33oq49s')
    expect { reports.env }.to raise_error(RuntimeError, "HTTP Status: 401")
  end

  context '.toggl file' do
    before :each do
      @tmp_home = mktemp_dir
      @original_home = Dir.home
      ENV['HOME'] = @tmp_home
    end

    after :each do
      FileUtils.rm_rf(@tmp_home)
      ENV['HOME'] = @original_home
    end

    it 'initializes with .toggl file' do
      toggl_file = File.join(@tmp_home, '.toggl')
      File.open(toggl_file, 'w') { |file| file.write(Testing::API_TOKEN) }

      reports = TogglV8::ReportsV2.new
      env = reports.env
      expect(env).to_not be nil
      expect(env['user']['api_token']).to eq Testing::API_TOKEN
    end

    it 'initializes with custom toggl file' do
      toggl_file = File.join(@tmp_home, 'my_toggl')
      File.open(toggl_file, 'w') { |file| file.write(Testing::API_TOKEN) }

      reports = TogglV8::ReportsV2.new(toggl_api_file: toggl_file)
      env = reports.env
      expect(env).to_not be nil
      expect(env['user']['api_token']).to eq Testing::API_TOKEN
    end

    it 'raises error if .toggl file is missing' do
      expect{ reports = TogglV8::ReportsV2.new }.to raise_error(RuntimeError)
    end
  end

  context 'handles errors' do
    before :all do
      @reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      @reports.workspace_id = @workspace_id
    end

    it 'surfaces a Warning HTTP header in case of 400 error' do
      # https://github.com/toggl/toggl_api_docs/blob/master/reports.md#failed-requests
      expect { @reports.error400 }.to raise_error(RuntimeError,
                                      "This URL is intended only for testing")
    end

    it 'retries a request up to 3 times if a 429 is received' do
      expect(@reports.conn).to receive(:get).exactly(3).times.and_return(
        MockResponse.new(429, {}, 'body'))
      expect { @reports.env }.to raise_error(RuntimeError, "HTTP Status: 429")
    end

    it 'retries a request after 429' do
      expect(@reports.conn).to receive(:get).twice.and_return(
        MockResponse.new(429, {}, 'body'),
        MockResponse.new(200, {}, 'rev1.2.3'))
      expect(@reports.revision).to eq('rev1.2.3')
    end
  end

  context 'miscellaneous' do
    it 'env returns environment' do
      reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      reports.workspace_id = @workspace_id
      env = reports.env
      expect(env['workspace']).to_not be nil
      expect(env['user']).to_not be nil
      expect(env['user']['id']).to eq Testing::USER_ID
    end

    it 'index returns empty string' do
      reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      reports.workspace_id = @workspace_id
      expect(reports.index).to eq ""
    end

    it 'revision has not changed' do
      reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      reports.workspace_id = @workspace_id
      expect(reports.revision).to start_with "0.0.38\n"
    end
  end

  context 'project', :pro_account do
    before :all do
      @toggl = TogglV8::API.new(Testing::API_TOKEN)
      @project_name = "Project #{Time.now.iso8601}"
      @project = @toggl.create_project({
        'name' => @project_name,
        'wid' => @workspace_id
      })
    end

    after :all do
      @toggl.delete_project(@project['id'])
    end

    it 'dashboard' do
      reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      reports.workspace_id = @toggl.workspaces.first['id']
      project_dashboard = reports.project(@project['id'])

      expect(project_dashboard['name']).to eq @project_name
    end
  end

  context 'blank reports' do
    before :all do
      @toggl = TogglV8::API.new(Testing::API_TOKEN)
      @workspaces = @toggl.workspaces
      @workspace_id = @workspaces.first['id']
      @reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      @reports.workspace_id = @workspace_id
    end

    it 'summary' do
      expect(@reports.summary).to eq []
    end

    it 'weekly' do
      expect(@reports.weekly).to eq []
    end

    it 'details' do
      expect(@reports.details).to eq []
    end
  end

  context 'reports' do
    before :all do
      @toggl = TogglV8::API.new(Testing::API_TOKEN)
      @workspaces = @toggl.workspaces
      @workspace_id = @workspaces.first['id']
      time_entry_info = {
        'wid' => @workspace_id,
        'start' => @toggl.iso8601(DateTime.now),
        'duration' => 77
      }

      @time_entry = @toggl.create_time_entry(time_entry_info)

      @reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      @reports.workspace_id = @workspace_id

      @tmp_home = mktemp_dir
      @original_home = Dir.home
      ENV['HOME'] = @tmp_home
    end

    after :all do
      @toggl.delete_time_entry(@time_entry['id'])

      FileUtils.rm_rf(@tmp_home)
      ENV['HOME'] = @original_home
    end

    context 'JSON reports' do
      it 'summary' do
        summary = @reports.summary
        expect(summary.length).to eq 1
        expect(summary.first['time']).to eq 77000
        expect(summary.first['items'].length).to eq 1
        expect(summary.first['items'].first['time']).to eq 77000
      end

      it 'weekly' do
        weekly = @reports.weekly
        expect(weekly.length).to eq 1
        expect(weekly.first['details'].first['title']['user']).to eq Testing::USERNAME
        expect(weekly.first['totals'][7]).to eq 77000
      end

      it 'details' do
        details = @reports.details
        expect(details.length).to eq 1
        expect(details.first['user']).to eq Testing::USERNAME
        expect(details.first['dur']).to eq 77000
      end
    end

    context 'CSV reports' do
      it 'summary' do
        filename = File.join(@tmp_home, 'summary.csv')
        summary = @reports.write_summary(filename)
        expect(file_contains(filename, /00:01:17/))
      end

      it 'weekly' do
        filename = File.join(@tmp_home, 'weekly.csv')
        weekly = @reports.write_weekly(filename)
        expect(file_contains(filename, /00:01:17/))
      end

      it 'details' do
        filename = File.join(@tmp_home, 'details.csv')
        details = @reports.write_details(filename)
        expect(file_contains(filename, /00:01:17/))
      end
    end

    context 'PDF reports' do
      it 'summary' do
        filename = File.join(@tmp_home, 'summary.pdf')
        summary = @reports.write_summary(filename)
        expect(file_is_pdf(filename))
      end

      it 'weekly' do
        filename = File.join(@tmp_home, 'weekly.pdf')
        weekly = @reports.write_weekly(filename)
        expect(file_is_pdf(filename))
      end

      it 'details' do
        filename = File.join(@tmp_home, 'details.pdf')
        details = @reports.write_details(filename)
        expect(file_is_pdf(filename))
      end
    end

    context 'XLS reports', :pro_account do
      it 'summary' do
        filename = File.join(@tmp_home, 'summary.xls')
        summary = @reports.write_summary(filename)
        expect(file_is_xls(filename))
      end

      it 'details' do
        filename = File.join(@tmp_home, 'details.xls')
        details = @reports.write_details(filename)
        expect(file_is_xls(filename))
      end
    end
  end
end
