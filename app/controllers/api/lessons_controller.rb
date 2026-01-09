class  Api::LessonsController < ApplicationController
    before_action :authenticate_api_user!
    before_action :require_admin!, only: [ :create, :update, :destroy ]

    # GET /api/lessons/:lesson_id/lessons
    def index
      section = Current.tenant.sections.find(params[:section_id])
      lessons = section.lessons.order(:position)

      render json: lessons
    end

    # GET /api/lessons/:id
    def show
      lesson = Current.tenant.lessons.find(params[:id])
      render json: lesson
    end

    # # POST /api/sections/:section_id/lessons
    def create
      section = Current.tenant.sections.find(params[:section_id])
      lesson = section.lessons.new(lesson_params.merge(tenant: Current.tenant))

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

    def reorder
      section = Current.tenant.sections.find(params[:section_id])

      ordered_ids = params.require(:lesson_ids)  # Expecting an array of lesson IDs in the desired order

      ActiveRecord::Base.transaction do
        section.lessons.update_all("position = position + 1000000")
        ordered_ids.each_with_index do |lesson_id, index|
          section.lessons.where(id: lesson_id).update_all(position: index + 1)
        end
      end
    end


    private
    def lesson_params
      params.permit(:title, :description, :duration_in_minutes, :lesson_type,)
    end
end
