# frozen_string_literal: true

require "rails_helper"

RSpec.describe "StudentTeachers", type: :request do
  include_context "with authenticated_headers"

  let(:user) { create(:user) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "GET index" do
    subject(:get_index) { get "/student_teachers", headers: authenticated_headers }

    let(:response_ids) do
      parsed_body["student_teachers"].map { |record| record["id"] }
    end

    before do
      create_list(:student_teacher, 2, student: user)
      create_list(:student_teacher, 2, teacher: user)
    end

    it "responds with the StudentTeacher records " do
      get_index
      expect(response_ids).to match_array(StudentTeacher.ids)
    end
  end

  describe "DELETE destroy" do
    subject(:delete_destroy) { delete "/student_teachers/#{student_teacher.id}", headers: authenticated_headers }

    let!(:student_teacher) { create(:student_teacher, student: user) }

    it "destroys the requested StudentTeacher" do
      expect { delete_destroy }.to change(StudentTeacher, :count).by(-1)
    end
  end
end
