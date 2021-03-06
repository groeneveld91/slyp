require "rails_helper"

RSpec.describe RepliesController, type: :controller do
  describe "#create" do
    context "user not signed in" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
      let(:user_slyp) { user.user_slyps.first }
      let(:reslyp) { user_slyp.reslyps.first }
      it "should respond with 401" do
        post :create, reslyp_id: reslyp.id, text: "this is a reply text", format: :json

        expect(response.status).to eq(401)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with missing params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
      let(:user_slyp) { user.user_slyps.first }
      let(:reslyp) { user_slyp.reslyps.first }
      before do
        sign_in user
      end

      it "should respond with 422" do
        post :create, reslyp_id: reslyp.id, format: :json

        expect(response.status).to eq(422)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should respond with 400" do
        post :create, text: "this is a reply text", format: :json

        expect(response.status).to eq(400)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end
    context "with invalid params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
      let(:lone_reslyp) { FactoryGirl.create(:reslyp) }
      before do
        sign_in user
      end

      it "should respond to unowned reslyp with 404" do
        post :create, reslyp_id: lone_reslyp.id, text: "this is a reply text", format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
      let(:user_slyp) { user.user_slyps.first }
      let(:reslyp) { user_slyp.reslyps.first }
      let(:reply_text) { "this is a reply text" }
      before do
        sign_in user
      end

      it "should respond with 201" do
        post :create, reslyp_id: reslyp.id, text: reply_text, format: :json

        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should respond with valid data" do
        post :create, reslyp_id: reslyp.id, text: reply_text, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response_body_json["id"]).not_to be_nil
        expect(response_body_json["sender"]).not_to be_nil
        expect(response_body_json["text"]).not_to be_nil
        expect(response_body_json["created_at"]).not_to be_nil
      end

      it "should set unseen_activity to true on other user_slyp" do
        user_slyp = nil
        if user.id == reslyp.sender_id
          user_slyp = reslyp.sender_user_slyp
        elsif user.id == reslyp.recipient_id
          user_slyp = reslyp.recipient_user_slyp
        end
        user_slyp.update_attribute(:unseen_activity, true)
        post :create, reslyp_id: reslyp.id, text: reply_text, format: :json
        expect(user_slyp.unseen_activity).to be true
      end

      it "should mark last reply as seen" do
        reply = reslyp.replies.create(sender_id: reslyp.recipient_id, text: reply_text)
        expect(reply.seen).to be false
        post :create, reslyp_id: reslyp.id, text: reply_text, format: :json
        expect(Reply.find(reply.id).seen).to be true
      end

      it "should not mark last reply as seen" do
        reply = reslyp.replies.create(sender_id: reslyp.recipient_id, text: reply_text)
        reslyp.replies.create(sender_id: user.id, text: reply_text)
        post :create, reslyp_id: reslyp.id, text: reply_text, format: :json
        expect(Reply.find(reply.id).seen).to be false
      end
    end
  end

  describe "#index" do
    context "invalid params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
      let(:reslyp) { FactoryGirl.create(:reslyp) }
      before do
        sign_in user
      end

      it "should respond to incorrect owner with 404" do
        get :index, id: reslyp.id, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
      let(:user_slyp) { user.user_slyps.first }
      let(:reslyp) { user_slyp.reslyps.first }
      before do
        sign_in user
      end
      it "should respond with 200" do
        get :index, id: reslyp.id, format: :json

        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should respond with correct data" do
        get :index, id: reslyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response_body_json.length).to eq(reslyp.replies.length)
        response_body_json.each do |reply|
          expect(reslyp.replies.find(reply["id"]).valid?).to be true
        end
      end

      it "should update unseen" do
        friend_id = reslyp.sender_id == user.id ? reslyp.recipient_id : reslyp.sender_id
        latest_reply = reslyp.replies.create(sender_id: friend_id, text: "valid text", seen: false)
        get :index, id: reslyp.id, format: :json
        expect(reslyp.replies.find(latest_reply.id).seen).to be true
      end
    end
  end

  describe "#update" do
    let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
    let(:user_slyp) { user.user_slyps.first }
    let(:reslyp) { user_slyp.reslyps.first }
    let(:reply) { reslyp.replies.first }

    before do
      sign_in user
    end
    context "invalid params" do
      let(:lone_reply) { FactoryGirl.create(:reply) }

      it "should respond to reply not owned by user with 404" do
        put :update, id: lone_reply.id, reply: { text: "Update text with this!" }, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should respond to missing text with 400" do
        put :update, id: reply.id, reply: {}, format: :json

        expect(response.status).to eq(400)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end
    context "valid params" do
      it "should respond with 200" do
        put :update, id: reply.id, reply: { text: "Update text with this!" }, format: :json

        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should update reply text" do
        text = "Update text with this!"
        put :update, id: reply.id, reply: { text:  text }, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response_body_json["text"]).to eq(text)
      end
    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
    let(:friend) { user.friends.last }
    let(:reply) { user.replies.first }
    let(:friend_reply) { friend.replies.first }
    before do
      sign_in user
    end

    it "should respond with 404" do
      expect(friend.id).not_to eq user.id
      delete :destroy, id: friend_reply.id, format: :json

      expect(response.status).to eq(404)
      expect(response.content_type).to eq(Mime::JSON)
    end

    it "should respond with 404" do
      expect(friend.id).not_to eq user.id
      delete :destroy, id: friend_reply.id, format: :json

      expect(response.status).to eq(404)
      expect(response.content_type).to eq(Mime::JSON)
    end

    it "should respond with 204" do
      delete :destroy, id: reply.id, format: :json

      expect(response.status).to eq(204)
      expect(response.content_type).to eq(Mime::JSON)
    end

    it "should delete the resource" do
      expect(Reply.find(reply.id)).not_to be_nil
      delete :destroy, id: reply.id, format: :json
      expect(Reply.find_by(id: reply.id)).to be_nil
    end
  end
end



