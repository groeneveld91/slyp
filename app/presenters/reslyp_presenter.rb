class ReslypPresenter < BasePresenter
  attr_accessor :reslyp

  delegate :id, :sender, :recipient, :comment, :replies, :created_at, to: :reslyp

  def initialize(reslyp)
    @reslyp = reslyp
  end
end
