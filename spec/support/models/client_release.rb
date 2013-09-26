# -*- coding: utf-8 -*-
class ClientRelease
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Userstamps
  # include SelectableAttr::Base

  field :device_type_cd  , type: Integer            , label: "デバイス種別コード"
  field :version         , type: String             , label: "クライアントバージョン"
  field :status_cd       , type: Integer, default: 0, label: "ステータス"
  field :url             , type: String             , label: "ダウンロードページURL"
  field :plan_released_at, type: Time               , label: "予定リリース日時" # どこにも使われていません。メモ扱いです。

  index({status_cd: 1, device_type_cd: 1, plan_released_at: -1})

  validates :device_type_cd, presence: true
  validates :version       , presence: true
  validates :status_cd     , presence: true
  # validates :url           , presence: true

  # selectable_attr :status_cd do
  #   entry 0, :develop    , "開発中"
  #   entry 1, :ready      , "リリース可能"
  #   entry 2, :enabled    , "有効" # リリース済み
  #   entry 3, :disabled   , "無効" # リリース済み
  # end

  class DeviceType
    include Mongoid::Document
    field :cd  , type: Integer, label: "デバイス種別コード"
    field :name, type: String , label: "デバイス種別名"

    validates :cd  , presence: true
    validates :name, presence: true

    # has_many :client_releases, class_name: "ClientRelease", foreign_key: "device_type_cd", inverse_of: "device_type"

    DEFAULTS = [
      {cd: 1, name: "iOS"}.freeze,
      {cd: 2, name: "Android"}.freeze,
    ].freeze

    class << self
      def create_defaults
        DEFAULTS.map{|attrs| ClientRelease::DeviceType.create!(attrs) }
      end
    end
  end

end
