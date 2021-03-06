#
#
# == License:
# Fairnopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Fairnopoly.
#
# Fairnopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairnopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairnopoly.  If not, see <http://www.gnu.org/licenses/>.
#
module Article::FeesAndDonations
  extend ActiveSupport::Concern

  AUCTION_FEES = {
    :min => 0.1,
    :max_fair => 15.0,
    :max_default => 30.0,
    :fair => 0.03,
    :default => 0.06
  }

  included do

    before_create :set_friendly_percent_for_ngo, if: :seller_ngo

    # Fees and donations
    monetize :calculated_fair_cents, :allow_nil => true
    monetize :calculated_friendly_cents, :allow_nil => true
    monetize :calculated_fee_cents, :allow_nil => true

     ## friendly percent
    validates_presence_of :friendly_percent_organisation_id, :if => :friendly_percent_gt_0?
    validates_presence_of :friendly_percent

  end

   ## -------------- Calculate Fees And Donations ---------------

  def could_be_book_price_agreement?
    book_category_id = $exceptions_on_fairnopoly['book_price_agreement']['category'].to_i
    is_a_book = self.categories.map{|c| c.self_and_ancestors.map(&:id)}.flatten.include? book_category_id
    is_a_book && self.condition == "new"
  end

  def calculated_fees_and_donations
    self.calculated_fair + self.calculated_friendly + self.calculated_fee
  end

  def calculated_fees_and_donations_with_quantity
    self.calculated_fees_and_donations * self.quantity
  end

  def calculated_fees_and_donations_netto
    fee_cents = self.calculated_fair_cents + self.calculated_friendly_cents + self.calculated_fee_cents
    netto = Money.new((fee_cents / 1.19).ceil)
    netto
  end

  def calculated_fees_and_donations_netto_with_quantity
    self.calculated_fees_and_donations_netto * self.quantity
  end

  def calculate_fees_and_donations
    self.calculated_friendly = Money.new(friendly_percent_result_cents)
    if self.friendly_percent < 100 && self.price > 0
      self.calculated_fair  = fair_percent_result
      self.calculated_fee = fee_result
    else
      self.calculated_fair = 0
      self.calculated_fee = 0
    end
  end

  private

    def friendly_percent_gt_0?
      self.friendly_percent.present? &&
      self.friendly_percent > 0
    end

    def set_friendly_percent_for_ngo
      if self.seller.ngo
         self.friendly_percent = 100
         self.friendly_percent_organisation_id = self.seller.id
      end
    end

    def friendly_percent_result_cents
      # At the moment there is no friendly percent
      # for rounding -> always round up (e.g. 900,1 cents are 901 cents)
      #(self.price_cents * (self.friendly_percent / 100.0)).ceil
      # NGOs are not allowed to give donation to other NGO
      self.seller.ngo ? 0 : (self.price_cents * (self.friendly_percent / 100.0)).ceil
    end

    ## fees and donations

    def fair_percentage
      self.seller.ngo ? 0 : 0.01
    end

    def fair_percent_result
      # for rounding -> always round up (e.g. 900,1 cents are 901 cents)
      Money.new(((self.price_cents - friendly_percent_result_cents) * fair_percentage).ceil)
    end

    def fee_percentage
      if self.seller.ngo
        0
      elsif fair?
        AUCTION_FEES[:fair]
      else
        AUCTION_FEES[:default]
      end
    end

    def fee_result
      if self.seller.ngo
        0
      else
        # for rounding -> always round up (e.g. 900,1 cents are 901 cents)
        r = Money.new(((self.price_cents - friendly_percent_result_cents) * fee_percentage).ceil)
        max = fair? ? Money.new(AUCTION_FEES[:max_fair]*100) : Money.new(AUCTION_FEES[:max_default]*100)
        min = Money.new(AUCTION_FEES[:min]*100)
        r = min if r < min
        r = max if r > max
        r
      end
    end
end
