module Api
  class  CoursesController < ApplicationController
    before_action :authenticate_api_user!

    # GET /api/courses
    def index
      courses = Current.tenant.courses.order(created_at: :desc)
      render json: courses
    end

    # GET /api/courses/:id
    def show
      course = Current.tenant.courses.find(params[:id])
      render json: course
    end

    # POST /api/courses
    def create
      course = CreateCourse.new(tenant: Current.tenant, params: course_params).call

      if course.persisted?
        render json: course, status: :created
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end


    private
    def course_params
      params.permit(:title, :description, :published)
    end
  end
end
