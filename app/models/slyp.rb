require "uri"
class Slyp < ActiveRecord::Base
  has_many :user_slyps
  has_many :users, through: :user_slyps
  has_many :reslyps

  validates :url, presence: true, :format => URI::regexp(%w(http https))

  def self.fetch(params)
    url = params[:url]
    slyp = fetch_from_db(url) || create_from_url(url)
  end

  private

  def self.fetch_from_db(url)
    Slyp.find_by(url: url)
  end

  def self.create_from_url(url)
    parsed_response = DiffbotService.fetch(url)
    Slyp.create(parsed_response)
  end
end
