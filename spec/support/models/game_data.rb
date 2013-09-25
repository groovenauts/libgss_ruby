# -*- coding: utf-8 -*-

# このファイルは生成されたファイルです。
#
# このモデルはテストデータの登録のためのものであり、実際のサーバ上での
# データの操作に使用されるモデルとは異なります。
#
# このモデルをテストデータの登録以外の目的で使用しないでください。
#
class GameData
  include Mongoid::Document

  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  field :player_id, type: String, label: "プレイヤーID", default: nil
  field :content, type: Hash, label: "内容", default: nil
  field :greeting_points, type: Integer, label: "あいさつポイント", default: 0.0
  field :login_bonus, type: Object, label: "ログインボーナス", default: nil
  field :invitation_code, type: String, label: "招待コード", default: nil
  field :invite_player, type: String, label: "招待プレイヤーID", default: nil
  field :read_notifications, type: Object, label: "既読お知らせリスト", default: nil
  field :created_at, type: ActiveSupport::TimeWithZone, label: "登録日時", default: nil
  field :updated_at, type: ActiveSupport::TimeWithZone, label: "更新日時", default: nil
  field :gender, type: Integer, label: "性別", default: 0.0
  validates(:player_id, presence: true)
  validates(:gender, presence: true)
  index({"player_id"=>1}, :name => "主キー")
  index({"invitation_code"=>1}, :name => "idx_invitation")
end
