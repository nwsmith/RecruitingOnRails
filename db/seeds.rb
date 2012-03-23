# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
statuses = CandidateStatus.create([{code: 'HIRED', name: 'Hired'}, {code: 'FIRED', name: 'Fired'}])
source = CandidateSource.create({code: 'WEB', name: 'Website'})
experience_levels = ExperienceLevel.create([{code: 'NEWB', name: 'Noob'}, {code: 'NINJA', name: 'Ninja'}])

hired = Candidate.create({first_name: 'Johnny',
                          last_name: 'fever',
                          candidate_status: statuses.first,
                          candidate_source: source,
                          experience_level: experience_levels[0]})
fired = Candidate.create({first_name: 'Joey Joe Joe',
                          middle_name: 'Junior',
                          last_name: 'Shabadoo',
                          candidate_status: statuses[-1],
                          candidate_source: source,
                          experience_level: experience_levels[-1]})

chuck = User.create({first_name: 'Chuck', last_name: 'Norris', admin: true, active: true, auth_name: 'chuck.norris', user_name: 'chuck.norris'})
bruce = User.create({first_name: 'Bruce', last_name: 'Lee', admin: false, active: true, auth_name: 'bruce.lee', user_name: 'bruce.lee'})

groups = Group.create([{name: 'Supermen', active: true}, {name: 'Wimps', active: true}])

chuck.groups << groups.first
bruce.groups << groups[-1]

chuck.save
bruce.save

phone_interview = InterviewType.create({code: 'PHONE', name: 'Phone Interview'})

interview = Interview.create({interview_type: phone_interview, candidate: hired, notes: 'awesome dude'})

interview_review = InterviewReview.create({interview: interview, user: bruce, approved: true, notes: 'sweet interview'})