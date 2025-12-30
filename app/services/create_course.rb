class CreateCourse
  def initialize(tenant:, params:)
    @tenant = tenant
    @params = params
  end

  def call
    course = @tenant.courses.new(@params)

    max = @tenant.plan.features["max_courses"]

    # nil => unlimited
    if max && @tenant.courses.count >= max
      course.errors.add(:base, "Your plan allows only #{max} courses")
      return course
    end

    course.save
    course
  end
end
