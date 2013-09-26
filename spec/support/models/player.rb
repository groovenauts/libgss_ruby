# -*- coding: utf-8 -*-

# このファイルは生成されたファイルです。
#
# このモデルはテストデータの登録のためのものであり、実際のサーバ上での
# データの操作に使用されるモデルとは異なります。
#
# このモデルをテストデータの登録以外の目的で使用しないでください。
#
class Player
  include Mongoid::Document

  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  field :player_id, type: String, label: "プレイヤーID", default: nil
  field :nickname, type: String, label: "ニックネーム", default: nil
  field :level, type: Integer, label: "レベル", default: 1.0
  field :authentication_token, type: String, label: "認証トークン", default: nil
  field :signature_key, type: String, label: "署名キー", default: nil
  field :pf_player_id, type: String, label: "プラットフォームプレイヤーID", default: nil
  field :pf_player_info, type: Hash, label: "プラットフォームプレイヤー情報", default: nil
  field :first_login_at, type: ActiveSupport::TimeWithZone, label: "初回ログイン日時", default: nil
  field :current_login_at, type: ActiveSupport::TimeWithZone, label: "現在ログイン日時", default: nil
  field :last_login_at, type: ActiveSupport::TimeWithZone, label: "最終ログイン日時", default: nil
  field :first_paid_at, type: ActiveSupport::TimeWithZone, label: "初回課金日時", default: nil
  field :last_paid_at, type: ActiveSupport::TimeWithZone, label: "最終課金日時", default: nil
  field :login_days, type: Integer, label: "ログイン日数", default: 0.0
  field :login_count_this_day, type: Integer, label: "当日ログイン回数", default: 0.0
  field :continuous_login_days, type: Integer, label: "連続ログイン日数", default: 0.0
  field :banned, type: Boolean, label: "アカウント停止フラグ", default: nil
  field :created_at, type: ActiveSupport::TimeWithZone, label: "登録日時", default: nil
  field :updated_at, type: ActiveSupport::TimeWithZone, label: "更新日時", default: nil
  validates(:player_id, presence: true)
  index({"player_id"=>1}, :name => "主キー")
  index({"authentication_token"=>1}, :name => "idx_auth")
  index({"pf_player_id"=>1}, :name => "idx_switch_login")
end
