# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cart do
    user
    sold { false }
  end

  trait :with_line_item_groups do
    ignore do
      line_item_group_count 3
    end

    after(:create) do |cart, evaluator|
      if cart.sold?
        create_list(:line_item_group, evaluator.line_item_group_count, :with_business_transactions, :sold, cart: cart)
      else
        create_list(:line_item_group, evaluator.line_item_group_count, cart: cart)
      end
    end
  end


end