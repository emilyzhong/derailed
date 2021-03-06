class SubmissionsController < ApplicationController
	before_action :authenticate!

	def index
		# Shows submissions that are assigned to the grader
		authenticate_admin!
		@semester = Semester.find(params[:semester_id])
		@submissions = Submission.where(admin_id: @current_user.id).where.not(graded: true).select { |s| s.semester.id == @semester.id}

	end

	def create
		puts params
		assignment = Assignment.find(params[:assignment_id])
		submission = Submission.create(submission_params)
		submission.assignment = assignment
		submission.date = DateTime.now
		submission.admin = Admin.where(active: true).sample
		student = Student.find(params[:student_id])
		submission.students.push(student)
		semester_id = Week.find(assignment.week_id).semester_id
		if submission.save
			flash[:notice] = "Assignment submitted!"
			redirect_to semester_assignments_path semester_id: semester_id
		else
			flash[:alert] = submission.errors.full_messages.to_sentence
			redirect_back fallback_location: root_path
		end
	end

	def update
		submission = Submission.find(params[:id])
		submission.update! submission_params
		semester = submission.assignment.week.semester

		if params[:submission][:score] != nil
			submission.graded = true

			flash[:notice] = "Submission graded!"
		else
			submission.date = DateTime.now
			flash[:notice] = "Submission updated"
		end
		submission.save

		redirect_back fallback_location: root_path
	end

	def destroy
		Submission.find(params[:id]).destroy

		flash[:alert] = "Submission deleted"
		semester_id = Week.find_by(assignment_id: params[:assignment_id]).semester_id
		redirect_to semester_assignments_path semester_id: semester_id
	end

	private
	def submission_params
		params.require(:submission).permit(:link, :score, :comment)
	end

end
