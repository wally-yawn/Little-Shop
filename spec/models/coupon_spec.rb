require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe "relationships" do
    it { should have_many(:invoices)}
    it { should belong_to(:merchant)}
  end
end