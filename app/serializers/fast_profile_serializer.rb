class FastProfileSerializer
  def initialize(profiles, parent_name)
    @profiles = profiles
    @parent_name = parent_name
  end

  def call
    @profiles.pluck("#{@parent_name}.id", 'profiles.id', 'profiles.name').map do |parent_id, profile_id, name|
      {
        parent_id: parent_id,
        profile_id: profile_id,
        name: name
      }
    end
  end

  def by_parent_id
    @by_parent_id ||= call.each_with_object({}) do |serialized_profile, acc|
      acc[serialized_profile[:parent_id]] = serialized_profile
    end
  end
end