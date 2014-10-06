# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
Registry.create([{key: 'dashboard.default_status', value: 'PEND'}])

chuck = User.create({first_name: 'Chuck', last_name: 'Norris', admin: true, active: true, auth_name: 'chuck.norris', user_name: 'chuck.norris'})
bruce = User.create({first_name: 'Bruce', last_name: 'Lee', admin: false, active: true, auth_name: 'bruce.lee', user_name: 'bruce.lee'})

groups = Group.create([{name: 'Supermen', active: true}, {name: 'Wimps', active: true}])

chuck.groups << groups.first
bruce.groups << groups[-1]

chuck.save
bruce.save

office_location = OfficeLocation.create({code: "YYC", name: "Calgary"})

school = School.create({code: 'UofC', name: 'University of Calgary'})
bsc = EducationLevel.create({code: 'BSC_CS', name: 'B.Sc. (Comp Sci)'})

developer = Position.create({code: 'DEV', name: 'Developer'})
tester = Position.create({code: 'QA', name: 'Tester'})

fired = CandidateStatus.create({code: 'HIRED', name: 'Hired'})
hired = CandidateStatus.create({code: 'FIRED', name: 'Fired'})
pending = CandidateStatus.create({code: 'PEND', name: 'Pending'})

source = CandidateSource.create({code: 'WEB', name: 'Website'})
experience_levels = ExperienceLevel.create([{code: 'NEWB', name: 'Noob', color: 'blue'}, {code: 'NINJA', name: 'Ninja', color: 'gold'}])
code_problem = CodeProblem.create({code: 'HELLO', name: 'Hello World'})

hired_candidate = Candidate.create({first_name: 'Johnny',
                                    last_name: 'fever',
                                    candidate_status: hired,
                                    candidate_source: source,
                                    office_location: office_location,
                                    experience_level: experience_levels[0],
                                    education_level: bsc,
                                    position: developer,
                                    school: school})

code_submission = CodeSubmission.create({candidate: hired_candidate,
                                         code_problem: code_problem})

CodeSubmissionReview.create({code_submission: code_submission, user: bruce, notes: 'nice code'})

Candidate.create({first_name: 'Joey Joe Joe',
                  middle_name: 'Junior',
                  last_name: 'Shabadoo',
                  office_location: office_location,
                  education_level: bsc,
                  candidate_status: fired,
                  candidate_source: source,
                  experience_level: experience_levels[-1],
                  position: tester})

Candidate.create({first_name: 'Pending',
                  last_name: 'Guy',
                  office_location: office_location,
                  education_level: bsc,
                  candidate_status: pending,
                  candidate_source: source,
                  experience_level: experience_levels[0],
                  position: developer})

phone_interview = InterviewType.create({code: 'PHONE', name: 'Phone Interview'})

interview = Interview.create({interview_type: phone_interview, candidate: hired_candidate, notes: 'awesome dude'})

InterviewReview.create({interview: interview, user: bruce, notes: 'sweet interview'})
InterviewReview.create({interview: interview, user: chuck, notes: 'yeah right'})