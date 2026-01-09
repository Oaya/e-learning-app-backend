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

    # GET /api/courses/:id/details
    def overview
      course = Course.includes(sections: :lessons).find(params[:id])

      render json: {
        id: course.id,
        title: course.title,
        description: course.description,
        level: Course.levels[course.level],
        category: Course.categories[course.category],
        thumbnail: course.thumbnail,
        published: course.published,
        created_at: course.created_at,
        updated_at: course.updated_at,
        sections: course.sections.order(:position).map { |m|
          {
            id: m.id,
            title: m.title,
            description: m.description,
            position: m.position,
            lessons: m.lessons.order(:position).map { |l|
              {
                id: l.id,
                title: l.title,
                description: l.description,
                position: l.position,
                lesson_type: Lesson.lesson_types[l.lesson_type],
                duration_in_minutes: l.duration_in_minutes,
                content_url: l.content_url
              }
            }
          }
        }
      }
    end


    private
    def course_params
      params.permit(:title, :description, :category, :level, :thumbnail, :published)
    end
  end
end
