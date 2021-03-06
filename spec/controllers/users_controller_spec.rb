require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:expected_keys) { ["id", "first_name", "last_name", "email", "display_name",
                         "notify_reslyp", "notify_activity", "weekly_summary",
                         "searchable", "cc_on_reslyp_email_contact", "send_reslyp_email_from",
                         "referral_link", "send_new_friend_notification"] }
  describe "#index" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should successfully return" do
      get :index, format: :json
      expect(response.status).to eq 200
      expect(response.content_type).to eq(Mime::JSON)
    end

    it "should return all expected keys" do
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json.keys).to contain_exactly(*expected_keys)
    end

    it "should format name correctly" do
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["display_name"]).to eq "#{user.first_name} #{user.last_name}"
    end

    it "should handle no first_name gracefully" do
      user.update(first_name: "", last_name: "Bloggs")
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["display_name"]).to eq "Bloggs"
    end

    it "should handle no last_name gracefully" do
      user.update(first_name: "Joe", last_name: "")
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["display_name"]).to eq "Joe"
    end

    it "should handle no name gracefully" do
      user.update(first_name: "", last_name: "")
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["display_name"]).to eq user.email
    end
  end

  describe "#update" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should return expected keys after update" do
      put :update, user: { first_name: "Donald" }, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response.content_type).to eq(Mime::JSON)
      expect(response_body_json.keys).to contain_exactly(*expected_keys)
    end
    it "should not update to invalid first_name" do
      put :update, user: { first_name: nil }, format: :json
      expect(response.status).to eq 422
    end
    it "should not update to invalid last_name" do
      put :update, user: { last_name: nil }, format: :json
      expect(response.status).to eq 422
    end
    it "should not update to invalid email" do
      put :update, user: { email: "testexample.com" }, format: :json
      expect(response.status).to eq 422
    end
    it "should successfully update notify_reslyp" do
      expect(user.notify_reslyp).to eq true
      put :update, user: { notify_reslyp: false }, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["notify_reslyp"]).to eq false
    end
    it "should successfully update notify_activity" do
      expect(user.notify_activity).to eq true
      put :update, user: { notify_activity: false }, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["notify_activity"]).to eq false
    end
    it "should successfully update searchable" do
      expect(user.searchable).to eq true
      put :update, user: { searchable: false }, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["searchable"]).to eq false
    end
    it "should successfully update cc_on_reslyp_email_contact" do
      expect(user.cc_on_reslyp_email_contact).to eq true
      put :update, user: { cc_on_reslyp_email_contact: false }, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["cc_on_reslyp_email_contact"]).to eq false
    end
    it "should successfully update weekly_summary" do
      expect(user.weekly_summary).to eq true
      put :update, user: { weekly_summary: false }, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["weekly_summary"]).to eq false
    end
    it "should successfully update send_reslyp_email_from" do
      expect(user.send_reslyp_email_from).to eq user.email
      put :update, user: { send_reslyp_email_from: "test@example.com" }, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json["send_reslyp_email_from"]).to eq "test@example.com"
    end
  end
  describe "#beta_request" do
    context "email has already been submitted" do
      let(:user) { FactoryGirl.create(:user) }
      it "respond with a 201" do
        post :beta_request, email: user.email, format: :json
        expect(response.status).to eq(201)
      end
      it "responds with correct priority" do
        post :beta_request, email: user.email, format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json["priority"]).to eq user.id
      end
    end
    context "correct params not supplied" do
      it "respond with 400" do
        post :beta_request, format: :json
        expect(response.status).to eq(400)
      end
    end
    context "valid request" do
      let(:email) { "#{SecureRandom.hex(8)}@example.com" }
      it "respond with a 201 and priority" do
        post :beta_request, email: email, format: :json
        expect(response.content_type).to eq(Mime::JSON)
        expect(response.status).to eq(201)
      end
      it "responds with priority" do
        post :beta_request, email: email, format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json["priority"]).to be_kind_of Integer
      end
      it "creates the user as waitlisted?" do
        post :beta_request, email: email, format: :json
        user = User.find_by_email(email)
        expect(user.waitlisted?).to be true
      end
      it "should befriend support" do
        post :beta_request, email: email, format: :json
        user = User.find_by_email(email)
        expect(user.friends? User.support_user.id).to be true
      end
    end
  end
end
