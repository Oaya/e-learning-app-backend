module Api
  class  CourseModulesController < ApplicationController
    before_action :authenticate_api_user!
    before_action :require_admin!, only: [ :create, :update, :destroy ]

    # GET /api/courses/:course_id/course_modules
    def index
      course = Current.tenant.courses.find(params[:course_id])
      course_modules =  course.course_modules.order(:position)

      render json: course_modules
    end

    # GET /api/course_modules/:id
    def show
      course_module = Current.tenant.course_modules.find(params[:id])
      render json: course_module
    end

    # # POST /api/courses/:course_id/course_modules
    def create
      course = Current.tenant.courses.find(params[:course_id])
      course_module = course.course_modules.new(course_module_params.merge(tenant: Current.tenant))

      if course_module.save!
        render json: course_module, status: :created
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end

    # PATCH /api/course_modules/:id
    def update
      course_module = Current.tenant.course_modules.find(params[:id])

      if course_module.update(course_module_params)
        render json: course_module, status: :created
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end

    # DELETE /api/course_modules/:id
    def destroy
      course_module = Current.tenant.course_modules.find(params[:id])

      if course_module.destroy!
        render status: :ok
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end


    private
    def course_module_params
      params.permit(:title, :description, :order)
    end
  end
end
