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
require_relative '../test_helper'

describe LineItemGroupsController do
  let(:lig) { FactoryGirl.create :line_item_group, :sold, :with_business_transactions, traits: [:paypal, :transport_type1] }
  let(:buyer) { lig.buyer }


  before do
    sign_in buyer
  end

  describe "GET 'show'" do

    it "should show a success flash when redirected after paypal success" do
      get :show, id: lig.id, paid: 'true'
      flash[:notice].must_equal I18n.t('line_item_group.notices.paypal_success')
    end

    it "should show an error flash when redirected after paypal cancellation" do
      get :show, id: lig.id, paid: 'false'
      flash[:error].must_equal I18n.t('line_item_group.notices.paypal_cancel')
    end

  end
end
