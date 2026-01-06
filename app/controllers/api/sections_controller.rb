module Api
  class  SectionsController < ApplicationController
    before_action :authenticate_api_user!
    before_action :require_admin!, only: [ :create, :update, :destroy ]

    # GET /api/courses/:course_id/sections
    def index
      course = Current.tenant.courses.find(params[:course_id])
      sections =  course.sections.order(:position)

      render json: sections
    end

    # GET /api/sections/:id
    def show
      section = Current.tenant.sections.find(params[:id])
      render json: section
    end

    # # POST /api/courses/:course_id/sections
    def create
      course = Current.tenant.courses.find(params[:course_id])
      section = course.sections.new(section_params.merge(tenant: Current.tenant))

      if section.save!
        render json: section, status: :created
      else
        render_error(section.errors.full_messages, :unprocessable_entity)
      end
    end

    # PATCH /api/sections/:id
    def update
      section = Current.tenant.sections.find(params[:id])

      if section.update(section_params)
        render json: section, status: :created
      else
        render_error(section.errors.full_messages, :unprocessable_entity)
      end
    end

    # DELETE /api/sections/:id
    def destroy
      section = Current.tenant.sections.find(params[:id])

      if section.destroy!
        render status: :ok
      else
        render_error(course.errors.full_messages, :unprocessable_entity)
      end
    end


    private
    def section_params
      params.permit(:title, :description, :position)
    end
  end
end
