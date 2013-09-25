class AsyncAction
  include Mongoid::Document

  field :player_id, type: Moped::BSON::ObjectId
  field :action_id , type: Object
  field :request_url, type: String
  field :request    # anything
  field :response   # anything, can be null
  field :attempts, type: Integer, default: 0

  index({ player_id: 1, action_id: 1 }, { unique: true })

  validates_presence_of :player_id
  validates_presence_of :action_id
  validates_presence_of :request_url
  validates_presence_of :request
  validates_uniqueness_of :action_id, scope: :player_id

  Player # in order to find with ActiveSupport::Dependency
  if defined? ::Player
    belongs_to :player # for Rails Admin
    class ::Player; has_many :async_actions end
  else
    raise "Player class not found!"
  end
end
