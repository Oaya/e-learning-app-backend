module Api
  class  CoursesController < ApplicationController
    before_action :authenticate_api_user!
    before_action :require_admin!, only: [ :create, :update, :destroy ]

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

    # PATCH /api/courses/:id
    def update
      course = Current.tenant.courses.find(params[:id])

      if course.update(course_params)
        render json: course, status: :created
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end

    # DELETE /api/courses/:id
    def destroy
      course = Current.tenant.courses.find(params[:id])

      if course.destroy!
        render status: :ok
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
