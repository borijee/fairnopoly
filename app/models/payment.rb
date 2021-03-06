class Payment < ActiveRecord::Base

  has_many :business_transactions, inverse_of: :payment #multiple bt can have one payment, if unified
  belongs_to :line_item_group, inverse_of: :payments
  # # all bts will have the same line_item_group, so it's actually has_one, but rails doesn't understand that
  # def line_item_group; line_item_groups.first; end # simulate the has_one

  delegate :buyer, :buyer_id, :seller, :seller_email, :buyer_email, :purchase_id,
           :seller_paypal_account,
           to: :line_item_group, prefix: true

  validates :pay_key, uniqueness: true, on: :create
  validates :line_item_group_id, uniqueness: true, on: :create

  state_machine initial: :pending do

    state :pending, :initialized, :errored, :succeeded

    event :init do
      transition :pending => :initialized, if: :initialize_payment
      transition :pending => :errored
    end

    # event :success do
    #   transition :initialized => :succeeded
    # end
  end

  def total_price
    Abacus.new(line_item_group).payment_listing.payments[:paypal][:total]
  end

  def self.parse_type selected_payment
    case selected_payment
    when 'paypal', :paypal
      'PaypalPayment'
    else
      nil
    end
  end

  protected
    # called within init
    def initialize_payment
      true
    end
end
