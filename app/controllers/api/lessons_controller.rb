module Api
  class  LessonsController < ApplicationController
    before_action :authenticate_api_user!
    before_action :require_admin!, only: [ :create, :update, :destroy ]

    # GET /api/lessons/:lesson_id/lessons
    def index
      course_module = Current.tenant.course_modules.find(params[:course_module_id])
      lessons = course_module.lessons.order(:position)

      render json: lessons
    end

    # GET /api/lessons/:id
    def show
      lesson = Current.tenant.lessons.find(params[:id])
      render json: lesson
    end

    # # POST /api/course_modules/:course_module_id/lessons
    def create
      course_module = Current.tenant.course_modules.find(params[:course_module_id])
      lesson = course_module.lesson.new(lesson_params.merge(tenant: Current.tenant))

      if lesson.save!
        render json: lesson, status: :created
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end

    # PATCH /api/lessons/:id
    def update
      lesson = Current.tenant.lessons.find(params[:id])

      if lesson.update(lesson_params)
        render json: lesson, status: :created
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end

    # DELETE /api/lessons/:id
    def destroy
      lesson = Current.tenant.lessons.find(params[:id])

      if lesson.destroy!
        render status: :ok
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end


    private
    def lesson_params
      params.permit(:title, :description, :duration_in_minutes, :lesson_type, :position)
    end
  end
end
