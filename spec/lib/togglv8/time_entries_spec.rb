describe 'Time Entries' do
  before :all do
    sleep(0.5)
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
  end

  context 'CRUD time entry' do
    before :each do
      time_entry_info = {
        'wid' => @workspace_id,
        'start' => @toggl.iso8601(DateTime.now),
        'duration' => 77
      }

      @expected = time_entry_info.clone

      @time_entry = @toggl.create_time_entry(time_entry_info)
    end

    after :each do
      @toggl.delete_time_entry(@time_entry['id'])
    end

    it 'creates a time entry' do
      expect(@time_entry).to include(@expected)
    end

    it 'requires a workspace, project, or task to create' do
      time_entry_info = {
        'start' => @toggl.iso8601(DateTime.now),
        'duration' => 77
      }

      expect {
        @toggl.create_time_entry(time_entry_info)
      }.to raise_error(ArgumentError)
    end

    it 'gets a time entry' do
      retrieved_time_entry = @toggl.get_time_entry(@time_entry['id'])

      ['start', 'stop'].each do |key|
        expect(retrieved_time_entry[key]).to eq_ts @time_entry[key]
        retrieved_time_entry.delete(key)
        @time_entry.delete(key)
      end

      expect(retrieved_time_entry).to eq @time_entry
    end

    it 'updates a time entry' do
      time_entry_info = {
        'start' => '2010-02-13T23:31:30+00:00',
        'duration' => 42
      }

      expected = time_entry_info.clone

      time_entry_updated = @toggl.update_time_entry(@time_entry['id'], time_entry_info)
      expect(time_entry_updated).to include(expected)
    end

    it 'deletes a time entry' do
      existing_time_entry = @toggl.get_time_entry(@time_entry['id'])
      expect(existing_time_entry.has_key?('server_deleted_at')).to eq false

      deleted_time_entry = @toggl.delete_time_entry(@time_entry['id'])
      expect(deleted_time_entry).to eq "[#{ @time_entry['id'] }]"

      zombie_time_entry = @toggl.get_time_entry(@time_entry['id'])
      expect(zombie_time_entry.has_key?('server_deleted_at')).to eq true
    end
  end

  context 'start and stop time entry' do
    it 'starts and stops a time entry' do
      time_entry_info = {
        'wid' => @workspace_id,
        'description' => 'time entry description'
      }

      # start time entry
      running_time_entry = @toggl.start_time_entry(time_entry_info)

      # get current time entry by '/current'
      time_entry_current = @toggl.get_current_time_entry
      # get current time entry by id
      time_entry_by_id = @toggl.get_time_entry(running_time_entry['id'])

      # compare two methods of getting current time entry
      expect(time_entry_current).to eq time_entry_by_id

      # compare current time entry with running time entry
      expect(time_entry_by_id['start']).to eq_ts running_time_entry['start']
      time_entry_by_id.delete('start')
      running_time_entry.delete('start')

      expect(time_entry_by_id).to eq running_time_entry
      expect(time_entry_by_id.has_key?('stop')).to eq false

      # stop time entry
      stopped_time_entry = @toggl.stop_time_entry(running_time_entry['id'])
      expect(stopped_time_entry.has_key?('stop')).to eq true

      @toggl.delete_time_entry(stopped_time_entry['id'])
    end

    it 'returns nil if there is no current time entry' do
      time_entry = @toggl.get_current_time_entry
      expect(time_entry).to be nil
    end

    it 'requires a workspace, project, or task to start' do
      time_entry_info = {
        'description' => 'time entry description'
      }

      expect {
        @toggl.start_time_entry(time_entry_info)
      }.to raise_error(ArgumentError)
    end
  end

  RSpec::Matchers.define :eq_ts do |expected|
    # Matching actual time is necessary due to differing formats.
    # Example:
    # 1) POST time_entries/start returns 2015-08-21T07:28:20Z
    #    when GET time_entries/{time_entry_id} returns 2015-08-21T07:28:20+00:00
    # 2) 2015-08-21T03:20:30-05:00 and 2015-08-21T08:20:30+00:00 refer to
    #    the same moment in time, but one is in local time and the other in UTC
    match do |actual|
      DateTime.parse(actual) == DateTime.parse(expected)
    end
  end
end