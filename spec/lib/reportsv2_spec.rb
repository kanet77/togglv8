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
      @home = File.join(Dir.pwd, "tmp")
      Dir.mkdir(@home)

      @original_home = Dir.home
      ENV['HOME'] = @home
    end

    after :each do
      FileUtils.rm_rf(@home)
      ENV['HOME'] = @original_home
    end

    it 'initializes with .toggl file' do
      toggl_file = File.join(@home, '.toggl')
      File.open(toggl_file, 'w') { |file| file.write(Testing::API_TOKEN) }

      reports = TogglV8::ReportsV2.new
      env = reports.env
      expect(env).to_not be nil
      expect(env['user']['api_token']).to eq Testing::API_TOKEN
    end

    it 'initializes with custom toggl file' do
      toggl_file = File.join(@home, 'my_toggl')
      File.open(toggl_file, 'w') { |file| file.write(Testing::API_TOKEN) }

      reports = TogglV8::ReportsV2.new({toggl_api_file: toggl_file})
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

    it 'surfaces a Warning HTTP header in case of 500 error' do
      # https://github.com/toggl/toggl_api_docs/blob/master/reports.md#failed-requests
      expect { @reports.error500 }.to raise_error(RuntimeError,
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

  context 'revision' do
    it 'has not changed' do
      reports = TogglV8::ReportsV2.new(api_token: Testing::API_TOKEN)
      reports.workspace_id = @workspace_id
      expect(reports.revision).to eq("0.0.38\n-8a007ca")
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
    end

    after :all do
      @toggl.delete_time_entry(@time_entry['id'])
    end

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
    end

    after :all do
      @toggl.delete_time_entry(@time_entry['id'])
    end

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
end