require 'rails_helper'

describe "Veterans" do

  describe "GET /veterans" do
    it "should not load for an anonymous visitor" do
      get veterans_path
      expect(response.status).to eq 302
    end
  end
end
