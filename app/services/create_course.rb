class CreateCourse
  def initialize(tenant:, params:)
    @tenant = tenant
    @course_data = params.except(:instructor_ids)
    @instructor_ids = params[:instructor_ids] || []
  end

  def call
    course = @tenant.courses.new(@course_data)
    max = @tenant.plan.features["max_courses"]

    # nil => unlimited
    if max && @tenant.courses.count >= max
      course.errors.add(:base, "Your plan allows only #{max} courses")
      return course
    end

    course.save



    # Find instructors and
    if @instructor_ids.any?
      instructors = User.where(id: @instructor_ids, tenant_id: @tenant.id)
      instructors.each do |instructor|
        CourseInstructor.find_or_create_by(course: course, instructor: instructor)
      end
    end

    # return the course and instructors
    return course, instructors
  end
end
