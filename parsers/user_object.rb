class UserObject
  attr_accessor :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end

  def browsers
    @browsers ||= sessions.map { |s| s['browser'] }
  end
end